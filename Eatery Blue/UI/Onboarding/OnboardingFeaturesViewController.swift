//
//  OnboardingFeaturesViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/4/22.
//

import UIKit

class OnboardingFeaturesViewController: UIViewController {

    struct OnboardingPage {
        let title: String
        let subtitle: String
        let image: UIImage?
    }

    private let backButton = ContainerView(content: UIImageView())
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let nextButton = ContainerView(pillContent: UILabel())

    private var pages: [OnboardingPage] = []
    private var pageViews: [OnboardingFeatureView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()

        setUpPages([
            OnboardingPage(
                title: "Upcoming Menus",
                subtitle: "See menus by date and plan ahead",
                image: UIImage(named: "OnboardingUpcomingMenus")
            ),
            OnboardingPage(
                title: "Wait Times",
                subtitle: "Check for crowds in real time to avoid lines",
                image: UIImage(named: "OnboardingWaitTimes")
            ),
            OnboardingPage(
                title: "Favorites",
                subtitle: "Save and quickly find eateries and items",
                image: UIImage(named: "OnboardingFavorites")
            )
        ])

        view.layoutIfNeeded()
        updatePageTransforms()
    }

    private func setUpView() {
        view.backgroundColor = .white

        view.addSubview(backButton)
        setUpBackButton()

        view.addSubview(scrollView)
        setUpScrollView()

        view.addSubview(nextButton)
        setUpNextButton()
    }

    private func setUpBackButton() {
        backButton.content.image = UIImage(named: "ArrowLeft")?.withRenderingMode(.alwaysTemplate)
        backButton.content.tintColor = UIColor(named: "Black")
        backButton.content.contentMode = .scaleAspectFit
        backButton.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)

        backButton.on(UITapGestureRecognizer()) { [self] _ in
            navigationController?.popViewController(animated: true)
        }
    }

    private func setUpScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self

        scrollView.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .horizontal
    }

    private func setUpNextButton() {
        nextButton.content.text = "Next"
        nextButton.content.textColor = UIColor(named: "EateryBlack")
        nextButton.content.font = .preferredFont(for: .body, weight: .semibold)
        nextButton.content.textAlignment = .center
        nextButton.backgroundColor = UIColor(named: "Gray00")
        nextButton.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)

        nextButton.on(UITapGestureRecognizer()) { [self] _ in
            didTapNextButton()
        }
    }

    private func setUpConstraints() {
        backButton.topToSuperview(offset: 12, usingSafeArea: true)
        backButton.leadingToSuperview(offset: 16, usingSafeArea: true)
        backButton.width(34)
        backButton.height(34)

        scrollView.topToBottom(of: backButton)
        scrollView.leadingToSuperview()
        scrollView.trailingToSuperview()

        stackView.edgesToSuperview()
        stackView.heightToSuperview()

        nextButton.topToBottom(of: scrollView)
        nextButton.leadingToSuperview(offset: 16, usingSafeArea: true)
        nextButton.trailingToSuperview(offset: 16, usingSafeArea: true)
        nextButton.bottomToSuperview(offset: -12, usingSafeArea: true)
        nextButton.content.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    func setUpPages(_ pages: [OnboardingPage]) {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }

        self.pages = pages

        for page in pages {
            let view = OnboardingFeatureView()
            view.titleLabel.text = page.title
            view.subtitleLabel.text = page.subtitle
            view.imageView.image = page.image

            view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            view.imageView.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
            view.imageView.setContentCompressionResistancePriority(.defaultHigh - 1, for: .vertical)

            stackView.addArrangedSubview(view)
            pageViews.append(view)

            view.width(to: scrollView)
        }
    }

    private func didTapNextButton() {
        let currentIndex = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        let clampedIndex = max(0, min(pages.count - 1, currentIndex))
        let nextIndex = clampedIndex + 1

        if nextIndex == pages.count {
            // We've reached the last page

            // Transition back to main page for now
            // TODO: Onboarding Login Page

            NotificationCenter.default.post(name: RootModelController.didFinishOnboardingNotification, object: nil)

        } else {
            // Move to the next page

            let offset = CGPoint(x: CGFloat(nextIndex) * scrollView.bounds.width, y: 0)
            scrollView.setContentOffset(offset, animated: true)
        }
    }

    private func updatePageTransforms() {
        let contentOffset = scrollView.contentOffset.x
        let pageWidth = scrollView.bounds.width
        let progress = contentOffset / pageWidth

        for (i, pageView) in pageViews.enumerated() {
            // 0 when this page is front-and-center
            // 1 when this page is one to the right
            // -1 when this page is one to the left
            let pageProgress = progress - CGFloat(i)

            // Parallax: When the previous page is front-and-center, we want the left-side of the image view to be
            // peeking out. Therefore, the image view has to be translated by
            //   + the distance from the leading edge of the image view to the leading edge of the page
            //   + some fixed margin

            // Assuming that the image view is fixed in the middle of the page view, the margins are equal on both sides
            // Therefore we can take the width of the page view (equal to the width of the scroll view), subtract off
            // the width of the image view to be left with just the margins, and divide by 2 to get the margins on just
            // one side. We make sure to use the bounds of the image view since we'll be applying a transform to the
            // view itself.
            let distanceFromImageViewLeadingToPageLeading = (pageWidth - pageView.imageView.bounds.width) / 2

            let fixedMargin: CGFloat = 48

            let parallaxTransform = CGAffineTransform(
                translationX: pageProgress * (distanceFromImageViewLeadingToPageLeading + fixedMargin),
                y: 0
            )

            // Scale: We want the current page to be scaled down proportional to its progress away from being the
            // front-and-center page.
            //   - We only care about the magnitude of pageProgress, since it being -1 or 1 should have the same scale
            //     on the view.

            let minScale = 0.95

            let scale = max(minScale, min(1, 1 - (1 - minScale) * abs(pageProgress)))
            let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)

            // To understand the scroll effect, comment out one or more of the transforms below
            pageView.imageView.transform = .identity
                .concatenating(parallaxTransform)
                .concatenating(scaleTransform)
        }
    }

}

extension OnboardingFeaturesViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updatePageTransforms()
    }

}
