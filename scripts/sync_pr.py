#!/usr/bin/env python3
"""Synchronize a GitHub PR to a Notion database. Standard library only."""
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone

GITHUB_API = 'https://api.github.com'
NOTION_API = 'https://api.notion.com/v1'


def request(method, url, token, payload=None, notion=False):
    headers = {'Authorization': ('Bearer ' if notion else 'Bearer ') + token,
               'Accept': 'application/json', 'User-Agent': 'eatery-pr-tracker'}
    if notion:
        headers['Notion-Version'] = '2022-06-28'
    if payload is not None:
        headers['Content-Type'] = 'application/json'
    data = json.dumps(payload).encode() if payload is not None else None
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            return json.load(response)
    except urllib.error.HTTPError as e:
        print(f'HTTP {e.code} on {method} {url}: {e.read().decode()[:600]}', file=sys.stderr)
        raise


def gh(path):
    return request('GET', GITHUB_API + path, os.environ['GITHUB_TOKEN'])


def notion(method, path, payload=None):
    return request(method, NOTION_API + path, os.environ['NOTION_TOKEN'], payload, True)


def pages(path):
    result = []
    while path:
        response = gh(path)
        result += response
        if len(response) < 100:
            break
        sep = '&' if '?' in path else '?'
        page = int(urllib.parse.parse_qs(urllib.parse.urlsplit(path).query).get('page', ['1'])[0]) + 1
        path = path.split('&page=')[0].split('?page=')[0] + sep + f'page={page}'
    return result


def rich(value):
    return [{'text': {'content': str(value)[:2000]}}]


def prop_select(value):
    return {'select': {'name': value}}


def sync(repo, number):
    prefix = '/repos/' + repo
    pr = gh(f'{prefix}/pulls/{number}')
    reviews = pages(f'{prefix}/pulls/{number}/reviews?per_page=100&page=1')
    # Latest non-comment review per reviewer determines their current decision.
    decisions = {}
    for review in reviews:
        state = review['state']
        if state in ('APPROVED', 'CHANGES_REQUESTED', 'DISMISSED'):
            decisions[review['user']['login']] = state
    requested = [r['login'] for r in pr.get('requested_reviewers', [])]
    requested += ['team:' + r['slug'] for r in pr.get('requested_teams', [])]
    if pr['state'] == 'closed':
        status = 'Merged' if pr.get('merged_at') else 'Closed'
    elif pr.get('draft'):
        status = 'Draft'
    else:
        status = 'Open'
    if 'CHANGES_REQUESTED' in decisions.values():
        review_status = 'Changes Requested'
    elif requested:
        review_status = 'Awaiting Review'
    elif 'APPROVED' in decisions.values():
        review_status = 'Approved'
    else:
        review_status = 'Not Requested'
    created = datetime.fromisoformat(pr['created_at'].replace('Z', '+00:00'))
    age = (datetime.now(timezone.utc) - created).total_seconds() / 3600
    stale = status == 'Open' and review_status == 'Awaiting Review' and age >= 48
    key = f'{repo}#{number}'
    props = {
        'PR': {'title': rich(pr['title'])},
        'PR Key': {'rich_text': rich(key)},
        'Repository': prop_select(repo.split('/')[-1]),
        'Author': {'rich_text': rich(pr['user']['login'])},
        'Status': prop_select(status),
        'Review Status': prop_select(review_status),
        'Reviewers': {'rich_text': rich(', '.join(requested)) if requested else []},
        'Approvals': {'number': sum(v == 'APPROVED' for v in decisions.values())},
        'Needs Attention': {'checkbox': stale},
        'Created': {'date': {'start': pr['created_at']}},
        'Updated': {'date': {'start': pr['updated_at']}},
        'Merged': {'date': {'start': pr['merged_at']} if pr.get('merged_at') else None},
        'GitHub URL': {'url': pr['html_url']},
    }
    database_id = os.environ['NOTION_DATABASE_ID']
    cursor = None
    existing = None
    while True:
        query = {'filter': {'property': 'PR Key', 'rich_text': {'equals': key}}, 'page_size': 100}
        if cursor:
            query['start_cursor'] = cursor
        response = notion('POST', f'/databases/{database_id}/query', query)
        if response['results']:
            existing = response['results'][0]['id']
            break
        cursor = response.get('next_cursor')
        if not cursor:
            break
    if existing:
        notion('PATCH', f'/pages/{existing}', {'properties': props})
        print('Updated', key)
    else:
        notion('POST', '/pages', {'parent': {'database_id': database_id}, 'properties': props})
        print('Created', key)


def main():
    for name in ('GITHUB_TOKEN', 'NOTION_TOKEN', 'NOTION_DATABASE_ID', 'GITHUB_REPOSITORY'):
        if not os.environ.get(name):
            raise RuntimeError(f'Missing {name}')
    repo = os.environ['GITHUB_REPOSITORY']
    number = os.environ.get('PR_NUMBER')
    if number:
        sync(repo, int(number))
    else:
        # Backfill and reconcile all open and recently closed PRs.
        prs = pages(f'/repos/{repo}/pulls?state=all&sort=updated&direction=desc&per_page=100&page=1')
        for pr in prs:
            sync(repo, pr['number'])


if __name__ == '__main__':
    main()
