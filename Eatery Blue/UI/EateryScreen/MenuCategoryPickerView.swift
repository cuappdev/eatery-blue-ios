//
//  MenuCategoryPickerView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/24/24.
//

import UIKit

protocol MenuCategoryPickerDelegate: AnyObject {

    func menuCategoryPicker(buttonPressedAtIndex idx: Int)

}

class MenuCategoryPickerView: UIView {

    // MARK: - Properties (data)

    weak var delegate: MenuCategoryPickerDelegate?
    private var highlightedCategoryIndex: Int?
    private var index = 0

    // MARK: - Properties (view)

    private let categoriesBackground = UIStackView()
    private let categoriesForeground = UIStackView()
    private let foregroundMask = PillView()
    private let menuCategoryContainer = UIView()
    private let menuCategoryScrollView = UIScrollView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setUpSelf() {
        self.backgroundColor = .white
        addSubview(menuCategoryContainer)
        menuCategoryContainer.addSubview(menuCategoryScrollView)
        setUpMenuCategoryViews()
    }

    private func setUpConstraints() {
        menuCategoryContainer.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(52)
        }

        menuCategoryScrollView.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
        }

        setUpCategoriesStackViewConstraints(categoriesBackground)
        setUpCategoriesStackViewConstraints(categoriesForeground)
    }

    private func setUpMenuCategoryViews() {
        menuCategoryScrollView.bounces = false
        menuCategoryScrollView.showsHorizontalScrollIndicator = false

        menuCategoryScrollView.addSubview(categoriesBackground)
        self.setUpCategoriesStackView(categoriesBackground)
        categoriesBackground.isUserInteractionEnabled = true

        menuCategoryScrollView.addSubview(categoriesForeground)

        self.setUpCategoriesStackView(categoriesForeground)
        categoriesForeground.isUserInteractionEnabled = false
        categoriesForeground.backgroundColor = UIColor.Eatery.black

        foregroundMask.backgroundColor = .white
        categoriesForeground.mask = foregroundMask
    }

    private func setUpCategoriesStackViewConstraints(_ stackView: UIStackView) {
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(menuCategoryScrollView.contentLayoutGuide)
            make.height.equalTo(menuCategoryScrollView.frameLayoutGuide)
        }
    }

    private func setUpCategoriesStackView(_ stackView: UIStackView) {
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
    }

    func addMenuCategory(categoryName: String) {
        let backgroundContainer = ContainerView(content: UILabel())
        let foregroundContainer = ContainerView(content: UILabel())

        backgroundContainer.content.text = categoryName
        foregroundContainer.content.text = backgroundContainer.content.text

        backgroundContainer.content.font = .preferredFont(for: .footnote, weight: .semibold)
        foregroundContainer.content.font = .preferredFont(for: .footnote, weight: .medium)

        backgroundContainer.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        foregroundContainer.layoutMargins = backgroundContainer.layoutMargins

        backgroundContainer.content.textColor = UIColor.Eatery.gray05
        foregroundContainer.content.textColor = .white

        categoriesBackground.addArrangedSubview(backgroundContainer)
        categoriesForeground.addArrangedSubview(foregroundContainer)

        backgroundContainer.snp.makeConstraints { make in
            make.width.equalTo(foregroundContainer)
        }

        let index = self.index
        backgroundContainer.tap { [weak self] _ in
            guard let self else { return }
            delegate?.menuCategoryPicker(buttonPressedAtIndex: index)
        }

        self.index += 1
        foregroundContainer.isUserInteractionEnabled = false
    }

    func highlightCategory(atIndex i: Int, animated: Bool) {
        if highlightedCategoryIndex != nil, animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .curveEaseOut]) {
                self.highlightCategory(atIndex: i, animateScrollView: false)
            }
        } else {
            highlightCategory(atIndex: i)
        }
    }

    func highlightCategory(atIndex i: Int, animateScrollView: Bool = false) {
        if i >= index { return }

        highlightedCategoryIndex = i
        foregroundMask.frame = categoriesForeground.arrangedSubviews[i].frame

        menuCategoryScrollView.scrollRectToVisible(foregroundMask.frame, animated: animateScrollView)
    }

}
