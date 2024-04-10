//
//  PillFiltersView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

class PillFiltersView: UIView {

    let scrollView = UIScrollView()
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(scrollView)
        setUpScrollView()
    }

    private func setUpScrollView() {
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false

        scrollView.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
    }

    private func setUpConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.height.equalTo(scrollView.frameLayoutGuide)
        }
    }

    func addButton(_ buttonView: PillFilterButtonView) {
        stackView.addArrangedSubview(buttonView)
    }

    func addButton(_ buttonView: PillFilterButtonView, at: Int) {
        stackView.insertArrangedSubview(buttonView, at: at)
    }
    
    func moveButton(from: Int, to: Int) {
        var boundedFrom = max(min(from, stackView.arrangedSubviews.count - 1), 0)
        var boundedTo = max(min(to, stackView.arrangedSubviews.count - 1), 0)
        let movedView = stackView.arrangedSubviews[boundedFrom]
        stackView.arrangedSubviews[boundedFrom].removeFromSuperview()
        if boundedTo >= stackView.arrangedSubviews.count {
            stackView.addArrangedSubview(movedView)
        } else {
            stackView.insertArrangedSubview(movedView, at: boundedTo)
        }
    }
}
