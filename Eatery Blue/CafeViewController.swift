//
//  CafeViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import os.log
import UIKit

class CafeViewController: UIViewController {

    private static let priceNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()

    private let navigationView = CafeMenuNavigationView()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var categoryViews: [CafeMenuCategoryView] = []

    private var headerView: UIView?
    private var navigationTriggerView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setUpView() {
        hero.isEnabled = true

        view.addSubview(scrollView)
        setUpScrollView()

        view.addSubview(navigationView)
        setUpNavigationView()
    }

    private func setUpScrollView() {
        scrollView.backgroundColor = .white
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.scrollIndicatorInsets = .zero
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self

        scrollView.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12
    }

    private func setUpNavigationView() {
        navigationView.favoriteButton.content.image = Bool.random()
            ? UIImage(named: "FavoriteSelected")
            : UIImage(named: "FavoriteUnselected")

        navigationView.backButton.on(UITapGestureRecognizer()) { [self] _ in
            navigationController?.popViewController(animated: true)
        }

        navigationView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        navigationView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 12, right: 16)
    }

    private func setUpConstraints() {
        navigationView.edgesToSuperview(excluding: .bottom)

        scrollView.edgesToSuperview()

        stackView.edgesToSuperview()
        stackView.width(to: scrollView)
    }

    func setUp(cafe: Cafe) {
        addHeaderImageView(imageUrl: cafe.imageUrl)
        addPaymentMethodsView(headerView: stackView.arrangedSubviews.last, paymentMethods: [.credit, .brbs, .cash])
        addPlaceDecorationIcon(headerView: stackView.arrangedSubviews.last)
        addNameLabel(cafe.name)
        navigationTriggerView = stackView.arrangedSubviews.last
        stackView.setCustomSpacing(8, after: stackView.arrangedSubviews.last!)
        addShortDescriptionLabel(cafe)
        addButtons(cafe)
        addTimingView(cafe)
        addThickSpacer()
        addMenuHeaderView()
        stackView.setCustomSpacing(0, after: stackView.arrangedSubviews.last!)
        addSearchBar()
        addThinSpacer()

        for menuCategory in cafe.menu.categories[..<(cafe.menu.categories.count - 1)] {
            addMenuCategory(menuCategory)
            addMediumSpacer()
        }

        if let last = cafe.menu.categories.last {
            addMenuCategory(last)
        }

        addHugeSpacer()

        navigationView.titleLabel.text = cafe.name
        for (i, menuCategory) in cafe.menu.categories.enumerated() {
            navigationView.addCategory(menuCategory.category) { [self] in
                let offset = categoryViews[i].frame.minY - navigationView.frame.height - 50
                scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }
        }
    }

    private func addHeaderImageView(imageUrl: URL?) {
        let imageView = UIImageView()
        imageView.hero.id = "headerImageView"
        imageView.aspectRatio(375 / 240)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.kf.setImage(with: imageUrl)

        stackView.addArrangedSubview(imageView)

        headerView = imageView
    }

    private func addPaymentMethodsView(headerView: UIView?, paymentMethods: Set<PaymentMethod>) {
        guard let headerView = headerView else {
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
            imageView.tintColor = UIColor(named: "EateryBlue")
            imageView.contentMode = .scaleAspectFit
            imageView.width(24)
            imageView.height(24)
            stack.addArrangedSubview(imageView)
        }

        if paymentMethods.contains(.brbs) {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "BRBs")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIColor(named: "EateryRed")
            imageView.contentMode = .scaleAspectFit
            imageView.width(24)
            imageView.height(24)
            stack.addArrangedSubview(imageView)
        }

        if paymentMethods.contains(.cash), paymentMethods.contains(.credit) {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "Cash")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIColor(named: "EateryGreen")
            imageView.contentMode = .scaleAspectFit
            imageView.width(24)
            imageView.height(24)
            stack.addArrangedSubview(imageView)
        }

        let container = ContainerView(pillContent: stack)

        // We add the payment methods as a regular subview of the stackView since it does not obey the regular layout
        // of a stack view.
        stackView.addSubview(container)

        container.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        container.clippingView.backgroundColor = .white
        container.shadowColor = UIColor(named: "Black")
        container.shadowOffset = CGSize(width: 0, height: 4)
        container.shadowOpacity = 0.25
        container.shadowRadius = 4

        container.trailingToSuperview(offset: 16)
        container.bottom(to: headerView, offset: -16)

        container.on(UITapGestureRecognizer()) { [self] _ in
            let viewController = PaymentMethodsViewController()
            viewController.setUpSheetPresentation()
            viewController.setPaymentMethods(paymentMethods)
            present(viewController, animated: true)
        }
    }

    private func addPlaceDecorationIcon(headerView: UIView?) {
        guard let headerView = headerView else {
            return
        }

        let imageView = UIImageView()
        imageView.image = UIImage(named: "Place")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(named: "Gray05")

        let container = ContainerView(pillContent: imageView)
        container.clippingView.backgroundColor = .white

        stackView.addSubview(container)

        container.leadingToSuperview(offset: 20)
        container.width(40)
        container.height(40)
        container.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        container.centerY(to: headerView, headerView.bottomAnchor)
    }

    private func addNameLabel(_ name: String) {
        let label = UILabel()
        label.text = name
        label.font = .preferredFont(for: .largeTitle, weight: .semibold)
        label.textColor = UIColor(named: "Black")

        let container = ContainerView(content: label)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)
    }

    private func addShortDescriptionLabel(_ cafe: Cafe) {
        let label = UILabel()
        label.text = "\(cafe.building ?? "--") · \(cafe.menuSummary ?? "--")"
        label.textColor = UIColor(named: "Gray05")
        label.font = .preferredFont(for: .subheadline, weight: .regular)

        let container = ContainerView(content: label)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)
    }

    private func addButtons(_ cafe: Cafe) {
        let buttonStackView = CafePillButtonStackView()
        buttonStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let buttonOrderOnline = CafePillButtonView()
        buttonStackView.addPillButton(buttonOrderOnline)
        buttonOrderOnline.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        buttonOrderOnline.backgroundColor = UIColor(named: "EateryBlue")
        buttonOrderOnline.imageView.image = UIImage(named: "iPhone")
        buttonOrderOnline.imageView.tintColor = .white
        buttonOrderOnline.titleLabel.textColor = .white
        buttonOrderOnline.titleLabel.text = "Order online"

        let buttonDirections = CafePillButtonView()
        buttonStackView.addPillButton(buttonDirections)
        buttonDirections.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        buttonDirections.backgroundColor = UIColor(named: "Gray00")
        buttonDirections.imageView.image = UIImage(named: "Walk")
        buttonDirections.imageView.tintColor = UIColor(named: "Black")
        buttonDirections.titleLabel.textColor = UIColor(named: "Black")
        buttonDirections.titleLabel.text = "Get directions"

        stackView.addArrangedSubview(buttonStackView)
    }

    private func addTimingView(_ cafe: Cafe) {
        let timingView = TimingDataView()
        timingView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        timingView.addCellView(createHoursCell(cafe))
        timingView.addCellView(createWaitTimeCell(cafe))

        stackView.addArrangedSubview(timingView)
    }

    private func createHoursCell(_ cafe: Cafe) -> TimingCellView {
        let cell = TimingCellView()
        cell.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        cell.titleLabel.textColor = UIColor(named: "Gray05")
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(
            attachment: NSTextAttachment(image: UIImage(named: "Clock"), scaledToMatch: cell.titleLabel.font))
        )
        text.append(NSAttributedString(string: " Hours"))
        cell.titleLabel.attributedText = text

        cell.statusLabel.textColor = UIColor(named: "EateryGreen")
        cell.statusLabel.text = "Open until 5:30 PM"

        cell.on(UITapGestureRecognizer()) { [self] _ in
            let viewController = HoursSheetViewController()
            viewController.setUpSheetPresentation()
            present(viewController, animated: true)
        }

        return cell
    }

    private func createWaitTimeCell(_ cafe: Cafe) -> TimingCellView {
        let cell = TimingCellView()
        cell.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        cell.titleLabel.textColor = UIColor(named: "Gray05")
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(
            attachment: NSTextAttachment(image: UIImage(named: "Watch"), scaledToMatch: cell.titleLabel.font))
        )
        text.append(NSAttributedString(string: " Wait Time"))
        cell.titleLabel.attributedText = text

        cell.statusLabel.textColor = UIColor(named: "Black")
        cell.statusLabel.text = "12-15 minutes"

        cell.on(UITapGestureRecognizer()) { [self] _ in
            let viewController = WaitTimeSheetViewController()
            viewController.setUpSheetPresentation()
            present(viewController, animated: true)
        }

        return cell
    }

    private func addThickSpacer() {
        let spacer = UIView()
        spacer.height(16)
        spacer.backgroundColor = UIColor(named: "Gray00")
        stackView.addArrangedSubview(spacer)
    }

    private func addMediumSpacer() {
        let spacer = UIView()
        spacer.height(8)
        spacer.backgroundColor = UIColor(named: "Gray00")
        stackView.addArrangedSubview(spacer)
    }

    private func addMenuHeaderView() {
        let menuHeaderView = CafeMenuHeaderView()
        menuHeaderView.titleLabel.text = "Full Menu"
        menuHeaderView.subtitleLabel.text = "7:00 AM - 8:30 PM"
        menuHeaderView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(menuHeaderView)
    }

    private func addSearchBar() {
        let searchBar = UISearchBar()
        searchBar.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = "Search the menu..."
        stackView.addArrangedSubview(searchBar)
    }

    private func addThinSpacer() {
        let spacer = HDivider()
        let container = ContainerView(content: spacer)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)
    }

    private func addMenuCategory(_ menuCategory: MenuCategory) {
        let categoryView = CafeMenuCategoryView()
        categoryView.titleLabel.text = menuCategory.category
        categoryView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        for item in menuCategory.items {
            let itemView = CafeMenuItemView()
            itemView.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            itemView.titleLabel.text = item.name

            if let price = item.price {
                itemView.priceLabel.text = CafeViewController
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

    private func addHugeSpacer() {
        let spacer = UIView()
        stackView.addArrangedSubview(spacer)
        spacer.height(to: view)
    }

}

extension CafeViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        false
    }

}

extension CafeViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleHeaderImageScaling(scrollView)
        handleNavigationViewTrigger(scrollView)
        handleNavigationViewCategory(scrollView)
    }

    private func handleHeaderImageScaling(_ scrollView: UIScrollView) {
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

    private func handleNavigationViewTrigger(_ scrollView: UIScrollView) {
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

    private func handleNavigationViewCategory(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.contentInset.top

        // We define a cursor that the user is looking at 50px below the navigation view in the scroll view's
        // coordinate system.
        let cursorPosition = offset + navigationView.frame.height + 50

        // The selected category is the menu category view that is under the cursor position
        let categoryView = stackView.arrangedSubviews.first { view in
            guard let categoryView = view as? CafeMenuCategoryView else { return false }
            return categoryView.frame.minY <= cursorPosition && cursorPosition <= categoryView.frame.maxY
        } as? CafeMenuCategoryView

        if let categoryView = categoryView {
            guard let index = categoryViews.firstIndex(of: categoryView) else {
                os_log("%@: could not find index of %@ in categoryViews", self, categoryView)
                return
            }

            navigationView.highlightCategory(atIndex: index, animated: true)
        }
    }

}
