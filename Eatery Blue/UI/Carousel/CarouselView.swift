//
//  CarouselView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit

class CarouselView: UIView {

    let titleLabel = UILabel()
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let buttonImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        insetsLayoutMarginsFromSafeArea = false

        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(buttonImageView)
        setUpButtonImageView()

        addSubview(scrollView)
        setUpScrollView()
    }

    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .title2, weight: .semibold)
    }

    private func setUpButtonImageView() {
        buttonImageView.isUserInteractionEnabled = true
        buttonImageView.image = UIImage(named: "ButtonArrowForward")
    }

    private func setUpScrollView() {
        scrollView.alwaysBounceHorizontal = true
        scrollView.clipsToBounds = false
        scrollView.showsHorizontalScrollIndicator = false

        scrollView.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
    }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(layoutMarginsGuide)
            make.centerY.equalTo(buttonImageView)
        }

        buttonImageView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.width.height.equalTo(40)
            make.top.trailing.equalTo(layoutMarginsGuide)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(layoutMarginsGuide)
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.height.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(186)
        }
    }

    func addCardView(_ contentView: EateryMediumCardContentView) {
        stackView.addArrangedSubview(EateryCardVisualEffectView(content: contentView))
    }

    func addAccessoryView(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }

    func resetCards() {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
    }

}
