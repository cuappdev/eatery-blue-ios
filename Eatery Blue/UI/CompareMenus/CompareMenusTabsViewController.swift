//
//  CompareMenusTabsView.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/26/24.
//

import EateryModel
import UIKit

class CompareMenusTabsViewController: UIViewController {

    // MARK: - Properties (data)

    private var categoryViews: [UIView] = []
    private let eateries: [Eatery]
    private var index = 0

    // MARK: - Properties (view)

    private let hitView: ScrollHitView
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    // MARK: - Init

    init(eateries: [Eatery]) {
        self.eateries = eateries
        self.hitView = ScrollHitView(scrollView: scrollView)

        super.init(nibName: nil, bundle: nil)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setUpView() {
        view.backgroundColor = UIColor.Eatery.gray00

        view.addSubview(hitView)
        view.addSubview(scrollView)

        setUpStackView()
        scrollView.addSubview(stackView)

        eateries.forEach { addCategory(name: $0.name) }
        highlightCategoryAtIndex(0)

        setUpConstraints()
    }

    func setUpScrollView(delegate: UIScrollViewDelegate) {
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = delegate
        scrollView.isPagingEnabled = true
        scrollView.clipsToBounds = false
    }

    private func setUpStackView() {
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
    }

    private func setUpConstraints() {
        hitView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.snp.makeConstraints { make in
            make.centerX.height.equalToSuperview()
            make.width.equalTo(207)
        }

        stackView.snp.makeConstraints { make in
            make.edges.centerY.equalToSuperview()
        }
    }

    private func addCategory(name: String) {
        let container = UIView()
        let background = UIView()
        background.backgroundColor = .white
        background.layer.shadowColor = UIColor.Eatery.black.cgColor
        background.layer.shadowOpacity = 0.25
        background.layer.shadowOffset = .zero
        background.layer.shadowRadius = 2
        background.layer.cornerRadius = 7

        let categoryLabel = UILabel()
        categoryLabel.text = name
        categoryLabel.lineBreakMode = .byTruncatingTail
        categoryLabel.textAlignment = .center
        categoryLabel.font = .systemFont(ofSize: 16, weight: .medium)

        background.addSubview(categoryLabel)
        container.addSubview(background)
        stackView.addArrangedSubview(container)

        container.snp.makeConstraints { make in
            make.width.equalTo(207)
            make.height.equalToSuperview()
        }

        background.snp.makeConstraints { make in
            make.height.equalToSuperview().inset(12)
            make.width.equalToSuperview().inset(8)
            make.center.equalToSuperview()
        }

        categoryLabel.snp.makeConstraints { make in
            make.height.equalToSuperview().inset(8)
            make.width.equalToSuperview().inset(12)
            make.center.equalToSuperview()
        }

        let containerIndex = index
        container.tap { [weak self] _ in
            guard let self else { return }

            self.scrollToIndex(containerIndex)
        }

        index += 1

        categoryViews.append(background)
    }

    func highlightFromScrollPercentage(_ percentage: Double) {
        let index = Int((percentage * Double(categoryViews.count)).rounded(.toNearestOrAwayFromZero))
        highlightCategoryAtIndex(index)
    }

    private func highlightCategoryAtIndex(_ index: Int) {
        let boundedIndex = max(min(index, categoryViews.count - 1), 0)
        categoryViews.indices.forEach { i in
            let opacity: Float = i == boundedIndex ? 1 : 0.4
            categoryViews[i].layer.opacity = opacity
        }
    }

    func offsetScrollBy(percentage: CGFloat) {
        if percentage.isNaN { return }
        let trueOffsetX = scrollView.contentSize.width * percentage
        var scrollBounds = scrollView.bounds;
        scrollBounds.origin = CGPoint(x: trueOffsetX, y: scrollView.bounds.origin.y);
        scrollView.bounds = scrollBounds;
    }

    func scrollToIndex(_ index: Int) {
        scrollView.setContentOffset(.init(x: scrollView.contentSize.width * CGFloat(index) / CGFloat(eateries.count), y: 0), animated: true)
    }

}
