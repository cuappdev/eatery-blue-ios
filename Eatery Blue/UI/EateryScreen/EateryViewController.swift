//
//  EateryViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import Combine
import CoreLocation
import EateryModel
import Hero
import MapKit
import UIKit

class EateryViewController: UIViewController {

    private static let priceNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .eatery
        return formatter
    }()

    private var cancellables: Set<AnyCancellable> = []
    var categoryViews: [MenuCategoryView] = []
    let fadeModifiers: [HeroModifier] = [.fade, .whenPresenting(.delay(0.20)), .useGlobalCoordinateSpace]
    var headerView: UIView?
    var navigationTriggerView: UIView?
    let navigationView = EateryNavigationView()
    let scrollView = UIScrollView()
    let spinner = UIActivityIndicatorView(style: .large)
    let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()
        hero.isEnabled = true
    
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        RootViewController.setStatusBarStyle(.lightContent)
    }

    private func setUpView() {
        view.addSubview(scrollView)
        setUpScrollView()

        view.addSubview(navigationView)
        setUpNavigationView()
    }

    private func setUpScrollView() {
        scrollView.backgroundColor = UIColor.Eatery.gray00
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.scrollIndicatorInsets = .zero
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self

        scrollView.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.backgroundColor = .white
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12
        stackView.hero.isEnabled = true
        stackView.hero.modifiers = fadeModifiers
    }

    private func setUpNavigationView() {
        navigationView.backButton.tap { [self] _ in
            navigationController?.popViewController(animated: true)
        }

        navigationView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        navigationView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 12, right: 16)
    }

    private func setUpConstraints() {
        navigationView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
    }

    func setCustomSpacing(_ spacing: CGFloat) {
        guard let last = stackView.arrangedSubviews.last else {
            return
        }
        stackView.setCustomSpacing(spacing, after: last)
    }
    
    func addSpinner() {
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
                
        view.addSubview(spinner)
        
        spinner.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(10)
            make.width.height.equalTo(stackView.snp.width).multipliedBy(0.25)
            make.centerX.equalTo(stackView.snp.centerX)
        }
    }
    
    func deleteSpinner() {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }

    func addHeaderImageView(imageUrl: URL?) {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.kf.setImage(with: imageUrl)

        imageView.snp.makeConstraints { make in
            make.width.equalTo(imageView.snp.height).multipliedBy(375.0 / 240.0)
        }
        
        imageView.hero.id = imageUrl?.absoluteString
        imageView.heroModifiers = [.translate(y:100), .useGlobalCoordinateSpace]
        stackView.addArrangedSubview(imageView)

        headerView = imageView
    }

    func addPaymentMethodsView(headerView: UIView?, paymentMethods: Set<PaymentMethod>) {
        guard let headerView = headerView, !paymentMethods.isEmpty else {
            return
        }

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fill
        stack.alignment = .fill

        if paymentMethods.contains(.mealSwipes) {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "MealSwipes")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIColor.Eatery.blue
            imageView.contentMode = .scaleAspectFit

            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(24)
            }

            stack.addArrangedSubview(imageView)
        }

        if paymentMethods.contains(.brbs) {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "BRBs")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIColor.Eatery.red
            imageView.contentMode = .scaleAspectFit

            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(24)
            }

            stack.addArrangedSubview(imageView)
        }

        if paymentMethods.contains(.cash), paymentMethods.contains(.credit) {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "Cash")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIColor.Eatery.green
            imageView.contentMode = .scaleAspectFit
            
            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(24)
            }

            stack.addArrangedSubview(imageView)
        }

        let container = ContainerView(pillContent: stack)

        // We add the payment methods as a regular subview of the stackView since it does not obey the regular layout
        // of a stack view.
        stackView.addSubview(container)

        container.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        container.cornerRadiusView.backgroundColor = .white
        container.shadowColor = UIColor.Eatery.black
        container.shadowOffset = CGSize(width: 0, height: 4)
        container.shadowOpacity = 0.25
        container.shadowRadius = 4

        container.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(headerView).offset(-16)
        }

        container.tap { [self] _ in
            let viewController = PaymentMethodsSheetViewController()
            viewController.setUpSheetPresentation()
            viewController.setPaymentMethods(paymentMethods)
            tabBarController?.present(viewController, animated: true)
        }
    }

    func addPlaceDecorationIcon(headerView: UIView?) {
        guard let headerView = headerView else {
            return
        }

        let imageView = UIImageView()
        imageView.image = UIImage(named: "Place")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.Eatery.gray05

        let container = ContainerView(pillContent: imageView)
        container.cornerRadiusView.backgroundColor = .white
        container.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        stackView.addSubview(container)

        container.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(40)
            make.centerY.equalTo(headerView.snp.bottom)
        }
    }

    func addNameLabel(_ name: String) {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = name
        label.font = .preferredFont(for: .largeTitle, weight: .semibold)
        label.textColor = UIColor.Eatery.black

        let container = ContainerView(content: label)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)
    }

    func addShortDescriptionLabel(_ eatery: Eatery) {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = "\(eatery.locationDescription ?? "--") · \(eatery.menuSummary ?? "--")"
        label.textColor = UIColor.Eatery.gray05
        label.font = .preferredFont(for: .subheadline, weight: .semibold)

        let container = ContainerView(content: label)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)
    }

    func addButtons(
        orderOnlineAction: (() -> Void)?,
        directionsAction: (() -> Void)?
    ) {
        let buttons = UIStackView()
        buttons.axis = .horizontal
        buttons.alignment = .fill
        buttons.distribution = .fillEqually
        buttons.spacing = 12

        if let orderOnlineAction = orderOnlineAction {
            let content = PillButtonView()
            content.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            content.backgroundColor = UIColor.Eatery.blue
            content.imageView.image = UIImage(named: "iPhone")
            content.imageView.tintColor = .white
            content.titleLabel.textColor = .white
            content.titleLabel.text = "Order online"

            let button = ButtonView(content: content)
            button.buttonPress { _ in
                orderOnlineAction()
            }
            buttons.addArrangedSubview(button)
        }

        if let directionsAction = directionsAction {
            let content = PillButtonView()
            content.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            content.backgroundColor = UIColor.Eatery.gray00
            content.imageView.image = UIImage(named: "Walk")?.withRenderingMode(.alwaysTemplate)
            content.imageView.tintColor = UIColor.Eatery.black
            content.titleLabel.textColor = UIColor.Eatery.black
            content.titleLabel.text = "Get directions"

            let button = ButtonView(content: content)
            button.buttonPress { _ in
                directionsAction()
            }
            buttons.addArrangedSubview(button)
        }

        if !buttons.arrangedSubviews.isEmpty {
            let container = ContainerView(content: buttons)
            container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            stackView.addArrangedSubview(container)
        }
    }

    func addAlertInfoView(_ message: String) {
        let alertView = AlertMessageView()
        alertView.setStyleInfo()
        alertView.messageLabel.text = message

        let containerView = ContainerView(content: alertView)
        containerView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        stackView.addArrangedSubview(containerView)
    }

    func addTimingView(_ eatery: Eatery) {
        let timingView = TimingDataView()
        timingView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        timingView.addCellView(createHoursCell(eatery))
        
        // TODO: Temporarily removed wait times.
//        timingView.addCellView(createWaitTimeCell(eatery))

        stackView.addArrangedSubview(timingView)
    }

    private func createHoursCell(_ eatery: Eatery) -> TimingCellView {
        let cell = TimingCellView()
        cell.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        cell.titleLabel.textColor = UIColor.Eatery.gray05
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(
            attachment: NSTextAttachment(image: UIImage(named: "Clock"), scaledToMatch: cell.titleLabel.font))
        )
        text.append(NSAttributedString(string: " Hours"))
        cell.titleLabel.attributedText = text

        cell.statusLabel.attributedText = EateryFormatter.default.formatStatus(eatery.status)

        cell.tap { [self] _ in
            let viewController = HoursSheetViewController()
            viewController.setUpSheetPresentation()
            viewController.setUp(eatery.id, eatery.events)
            tabBarController?.present(viewController, animated: true)
        }

        return cell
    }

    private func createWaitTimeCell(_ eatery: Eatery) -> TimingCellView {
        let cell = TimingCellView()
        cell.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        cell.titleLabel.textColor = UIColor.Eatery.gray05
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(
            attachment: NSTextAttachment(image: UIImage(named: "Watch"), scaledToMatch: cell.titleLabel.font))
        )
        text.append(NSAttributedString(string: " Wait Time"))
        cell.titleLabel.attributedText = text

        if let waitTimes = eatery.waitTimesByDay[Day()], let sample = waitTimes.sample(at: Date()) {
            cell.statusLabel.textColor = UIColor.Eatery.black
            let low = Int(round(sample.low / 60))
            let high = Int(round(sample.high / 60))
            cell.statusLabel.text = low < high ? "\(low)-\(high) minutes" : "\(low) minutes"

            let events = eatery.events
            cell.tap { [self] _ in
                let viewController = WaitTimesSheetViewController()
                viewController.setUpSheetPresentation()
                viewController.setUp(eatery.id, waitTimes, events: events)
                tabBarController?.present(viewController, animated: true)
            }

        } else {
            cell.statusLabel.textColor = UIColor.Eatery.gray05
            cell.statusLabel.text = "-- minutes"
        }

        return cell
    }

    func addSpacer(height: CGFloat, color: UIColor? = UIColor.Eatery.gray00) {
        let spacer = UIView()
        spacer.backgroundColor = color
        stackView.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
    }

    func addViewProportionalSpacer(multiplier: CGFloat, color: UIColor? = UIColor.Eatery.gray00) {
        let spacer = UIView()
        spacer.backgroundColor = color
        stackView.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { make in
            make.height.equalTo(view).multipliedBy(multiplier)
        }
    }

    func addMenuHeaderView(title: String, subtitle: String, dropDownButtonAction: (() -> Void)? = nil) {
        let menuHeaderView = MenuHeaderView()
        menuHeaderView.titleLabel.text = title
        menuHeaderView.subtitleLabel.text = subtitle
        menuHeaderView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        menuHeaderView.buttonImageView.tap { _ in
            dropDownButtonAction?()
        }
        stackView.addArrangedSubview(menuHeaderView)
    }

    func addSearchBar() {
        let searchBar = UISearchBar()
        searchBar.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = "Search the menu..."
        stackView.addArrangedSubview(searchBar)
    }

    func addThinSpacer() {
        let spacer = HDivider()
        let container = ContainerView(content: spacer)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)
    }

    func addMenuCategory(_ menuCategory: MenuCategory) {
        let categoryView = MenuCategoryView()
        categoryView.titleLabel.text = menuCategory.category
        categoryView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        for item in menuCategory.items {
            let itemView = MenuItemView()
            itemView.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            itemView.titleLabel.text = item.name

            if let price = item.price {
                itemView.priceLabel.text = EateryViewController
                    .priceNumberFormatter
                    .string(from: NSNumber(value: Double(price) / 100))
            } else {
                itemView.priceLabel.text = ""
            }

            if let description = item.description {
                itemView.descriptionLabel.isHidden = false
                itemView.descriptionLabel.text = description
            } else {
                itemView.descriptionLabel.isHidden = true
            }

            categoryView.addItemView(itemView)
        }

        categoryViews.append(categoryView)
        stackView.addArrangedSubview(categoryView)
    }

    func addReportIssueView(eateryId: Int64? = nil) {
        let view = ReportIssueView()
        view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.button.tap { [self] _ in
            let viewController = ReportIssueViewController(eateryId: eateryId)
            tabBarController?.present(viewController, animated: true)
        }
        stackView.addArrangedSubview(view)
    }

    func scrollToCategoryView(at index: Int) {
        let offset = categoryViews[index].frame.minY - navigationView.frame.height - 50
        scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: view.safeAreaInsets.bottom,
            right: 0
        )
    }
}

extension EateryViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        false
    }

}

extension EateryViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleHeaderImageScaling()
        handleNavigationViewTrigger()
        handleNavigationViewCategory()
    }

    private func handleHeaderImageScaling() {
        guard let header = headerView, header.bounds != .zero else { return }

        let offset = scrollView.contentOffset.y

        // We want to scale the header about its bottom center.
        // 1. Translate bottom center point to the center of the view
        // 2. Apply scale about new center
        // 3. Translate center back to bottom center

        let translateTransform = CGAffineTransform(translationX: 0, y: -header.bounds.height / 2)

        // Uniform scale such that the top of the image is at the top of the screen
        let bottomOfImageViewToTopOfView = -offset + header.bounds.height
        let scale = max(1, bottomOfImageViewToTopOfView / header.bounds.height)
        let scaleTransfom = CGAffineTransform(scaleX: scale, y: scale)

        let transform = translateTransform
            .concatenating(scaleTransfom)
            .concatenating(translateTransform.inverted())

        header.transform = transform
    }

    private func handleNavigationViewTrigger() {
        // Use trigger.bounds != zero as a proxy for whether it has been laid out
        guard let trigger = navigationTriggerView, trigger.bounds != .zero else { return }

        let offset = scrollView.contentOffset.y + scrollView.contentInset.top
        let criticalPoint = trigger.convert(trigger.bounds, to: scrollView).minY

        let shouldFadeIn = offset > criticalPoint
        if shouldFadeIn != (navigationView.fadeInProgress == 1) {
            navigationView.setFadeInProgress(shouldFadeIn ? 1 : 0, animated: true)
            RootViewController.setStatusBarStyle(shouldFadeIn ? .darkContent : .lightContent)
        }
    }

    private func handleNavigationViewCategory() {
        let offset = scrollView.contentOffset.y + scrollView.contentInset.top

        // We define a cursor that the user is looking at 55px below the navigation view in the scroll view's
        // coordinate system.
        let cursorPosition = offset + navigationView.frame.height + 55

        // The selected category is the menu category view that is under the cursor position
        let categoryView = stackView.arrangedSubviews.first { view in
            guard let categoryView = view as? MenuCategoryView else { return false }
            return categoryView.frame.minY <= cursorPosition && cursorPosition <= categoryView.frame.maxY
        } as? MenuCategoryView

        if let categoryView = categoryView {
            guard let index = categoryViews.firstIndex(of: categoryView) else {
                logger.error("\(self): Could not find index of \(categoryView) in categoryViews")
                return
            }

            navigationView.highlightCategory(atIndex: index, animated: true)
        }
    }

}
