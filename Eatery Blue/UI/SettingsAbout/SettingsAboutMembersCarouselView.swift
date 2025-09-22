//
//  SettingsAboutMembersCarouselView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/27/22.
//

import UIKit

class SettingsAboutMembersCarouselView: UIView {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        addSubview(scrollView)
        setUpScrollView()
    }

    private func setUpScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        scrollView.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
    }

    private func setUpConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.height.equalTo(layoutMarginsGuide)
        }
    }

    func addTitleView(_ title: String) {
        let label = UILabel()
        label.font = .preferredFont(for: .footnote, weight: .semibold)
        label.text = title

        stackView.addArrangedSubview(label)
    }

    func addMemberView(name: String) {
        let label = UILabel()
        label.font = .preferredFont(for: .footnote, weight: .semibold)
        label.text = name

        let container = ContainerView(pillContent: label)
        container.layoutMargins = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        container.backgroundColor = UIColor.Eatery.gray00

        stackView.addArrangedSubview(container)
    }

    func addSeparator() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "FavoriteSelected")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.Eatery.gray01
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(8)
        }

        stackView.addArrangedSubview(imageView)
    }

    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()

        scrollView.contentInset = layoutMargins
    }
}
