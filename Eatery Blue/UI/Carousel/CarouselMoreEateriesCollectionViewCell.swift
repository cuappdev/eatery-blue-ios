//
//  CarouselMoreEateriesView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import UIKit

class CarouselMoreEateriesCollectionViewCell: UICollectionViewCell {

    let stackView = UIStackView()
    let imageView = UIImageView()
    let titleLabel = UILabel()
    
    static let reuse = "CarouselMoreEateriesCollectionViewCellReuse"

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        backgroundColor = UIColor.Eatery.offWhite
        
        layer.cornerRadius = 8
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowColor = UIColor.Eatery.shadowLight.cgColor
        layer.shadowOpacity = 0.25
        
        addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill

        stackView.addArrangedSubview(imageView)
        setUpImageView()

        stackView.addArrangedSubview(titleLabel)
        setUpTitleLabel()
    }

    private func setUpImageView() {
        imageView.image = UIImage(named: "ButtonNext")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.Eatery.blue
        imageView.contentMode = .scaleAspectFit
    }

    private func setUpTitleLabel() {
        titleLabel.textColor = UIColor.Eatery.blue
        titleLabel.font = .preferredFont(for: .callout, weight: .semibold)
        titleLabel.text = "More eateries"
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints { make in
            make.leading.trailing.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
        }
    }

}
