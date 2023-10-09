//
//  UpcomingMenuChoiceView.swift
//  Eatery Blue
//
//  Created by Tiffany Pan on 10/1/23.
//

import UIKit

class UpcomingMenuChoiceView: UIView {

    let descriptionLabel = UILabel()
    let timeLabel = UILabel()
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(description: String, time: String) {
        descriptionLabel.text = description
        timeLabel.text = time
    }

    private func setUpSelf() {
        addSubview(descriptionLabel)
        setUpDescriptionLabel()

        addSubview(timeLabel)
        setUpTimeLabel()
        
        addSubview(imageView)
    }

    private func setUpDescriptionLabel() {
        descriptionLabel.font = .preferredFont(for: .body, weight: .semibold)
        descriptionLabel.textColor = UIColor.Eatery.black
    }

    private func setUpTimeLabel() {
        timeLabel.font = .preferredFont(for: .caption1, weight: .semibold)
        timeLabel.textColor = UIColor.Eatery.gray05
    }

    private func setUpConstraints() {
        descriptionLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(layoutMarginsGuide)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(4)
            make.leading.bottom.equalTo(layoutMarginsGuide)
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.equalTo(descriptionLabel.snp.trailing)
            make.leading.equalTo(timeLabel.snp.trailing)
            make.centerY.trailing.equalTo(layoutMarginsGuide)
            make.width.height.equalTo(24)
        }
    }
}

