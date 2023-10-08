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
    private let nextButton = ButtonView(pillContent: UILabel())
    private let scrollView = UIScrollView()
    private let skipButton = ContainerView(content: UILabel())
    private let stackView = UIStackView()

    private var pages: [OnboardingPage] = []
    private var pageViews: [OnboardingFeatureView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()
        
        setUpPages([
            OnboardingPage(
                title: "Home",
                subtitle: "View the eateries Cornell offers",
                image: UIImage(named: "OnboardingHomeTab")
            ),
            OnboardingPage(
                title: "Home",
                subtitle: "View the eateries Cornell offers",
                image: UIImage(named: "OnboardingHomeScreen")
            ),
            OnboardingPage(
                title: "Upcoming Menus",
                subtitle: "See menus by date and plan ahead",
                image: UIImage(named: "OnboardingUpcomingTab")
            ),
            OnboardingPage(
                title: "Upcoming Menus",
                subtitle: "See menus by date and plan ahead",
                image: UIImage(named: "OnboardingUpcomingScreen")
            ),
            OnboardingPage(
                title: "Favorites",
                subtitle: "Save and quickly find eateries",
                image: UIImage(named: "OnboardingFavoritesTab")
            ),
            OnboardingPage(
                title: "Favorites",
                subtitle: "Save and quickly find eateries",
                image: UIImage(named: "OnboardingFavoritesScreen")
            ),
            OnboardingPage(
                title: "Log in with Eatery",
                subtitle: "See your meal swipes, BRBs, and more",
                image: UIImage(named: "OnboardingLogIn")
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
        
        view.addSubview(skipButton)
        setUpSkipButton()
    }

    private func setUpBackButton() {
        backButton.content.image = UIImage(named: "ArrowLeft")?.withRenderingMode(.alwaysTemplate)
        backButton.content.tintColor = UIColor.Eatery.black
        backButton.content.contentMode = .scaleAspectFit
        backButton.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)

        backButton.tap { [self] _ in
            navigationController?.popViewController(animated: true)
        }
    }

    private func setUpSkipButton() {
        skipButton.content.font = .preferredFont(for: .body, weight: .semibold)
        skipButton.content.text = "Skip"
        skipButton.isHidden = true

        skipButton.tap { [self] _ in
            didTapSkipButton()
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
        nextButton.content.textColor = UIColor.Eatery.black
        nextButton.content.font = .preferredFont(for: .body, weight: .semibold)
        nextButton.content.textAlignment = .center
        nextButton.backgroundColor = UIColor.Eatery.gray00
        nextButton.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)

        nextButton.buttonPress { [self] _ in
            didTapNextButton()
        }
    }

    private func setUpConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.width.height.equalTo(34)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.height.equalTo(scrollView.frameLayoutGuide)
        }

        nextButton.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(12)
        }
        nextButton.content.setContentCompressionResistancePriority(.required, for: .vertical)
        
        skipButton.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.top)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(backButton.snp.height)
        }
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

            view.snp.makeConstraints { make in
                make.width.equalTo(scrollView)
            }
        }
    }

    private func didTapNextButton() {
        let currentIndex = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        let clampedIndex = max(0, min(pages.count - 1, currentIndex))
        let nextIndex = clampedIndex + 1
        
        if nextIndex == pages.count - 1 {
            skipButton.isHidden = false
            nextButton.content.text = "Log in"
            nextButton.content.font = .preferredFont(for: .body, weight: .semibold)
            nextButton.content.textAlignment = .center
            nextButton.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
            nextButton.content.textColor = .white
            nextButton.backgroundColor = UIColor.Eatery.blue
            nextButton.buttonPress({ [self] _ in
                AppDevAnalytics.shared.logFirebase(AccountLoginPayload())
                Task {
                    let vc = GetLoginWebViewController()
                    vc.delegate = self
                    self.present(vc, animated: true)
                    finishOnboarding()
                }
            })
        }

        if nextIndex == pages.count {
            // We've reached the last page
            
            navigationController?.pushViewController(HomeModelController(), animated: true)

        } else {
            // Move to the next page

            let offset = CGPoint(x: CGFloat(nextIndex) * scrollView.bounds.width, y: 0)
            scrollView.setContentOffset(offset, animated: true)
        }
    }

    private func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.didOnboard)
        NotificationCenter.default.post(name: RootModelController.didFinishOnboardingNotification, object: nil)
    }
    
    private func didTapSkipButton() {
        NotificationCenter.default.post(name: RootModelController.didFinishOnboardingNotification, object: nil)
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

extension OnboardingFeaturesViewController: GetLoginWebViewControllerDelegate {

    func setSessionId(_ sessionId: String, _ completion: (() -> Void)) {
        KeychainAccess.shared.saveToken(sessionId: sessionId)
        if !Networking.default.sessionId.isEmpty {
            completion()
        }
    }

}
