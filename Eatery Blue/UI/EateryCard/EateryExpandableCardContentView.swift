//
//  EateryExpandableCardContentView.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 9/23/23.
//

import SnapKit
import UIKit

class EateryExpandableCardContentView: UIView {
    
    let expandImage = UIImage(named: "ExpandDown")
    let collapseImage = UIImage(named: "CollapseUp")
    
    let alertsStackView = UIStackView()
    
    let labelStackView = UIStackView()
    let titleLabel = UILabel()
    let subtitleLabels = [UILabel(), UILabel()]
    
    var isExpanded = false {
        didSet {
            updateUIForExpansion()
        }
    }
    
    let expandButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpSelf()
        setUpConstraints()
        setUpExpandButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpSelf() {
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = .zero
        backgroundColor = .systemRed
//        backgroundColor = UIColor.Eatery.offWhite
        
        addSubview(labelStackView)
        setUpLabelStackView()
        
        addSubview(expandButton)
        setUpExpandButton()
    }
    
    private func setUpAlertsStackView() {
        alertsStackView.spacing = 8
        alertsStackView.axis = .vertical
        alertsStackView.alignment = .trailing
        alertsStackView.distribution = .equalSpacing
    }
    
    private func setUpLabelStackView() {
        labelStackView.axis = .vertical
        labelStackView.spacing = 4
        labelStackView.distribution = .fill
        labelStackView.alignment = .fill
        
        labelStackView.addArrangedSubview(titleLabel)
        setUpTitleLabel()
        
        for subtitleLabel in subtitleLabels {
            labelStackView.addArrangedSubview(subtitleLabel)
            setUpSubtitleLabel(subtitleLabel)
        }
    }
    
    private func setUpTitleLabel() {
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.black
    }
    
    private func setUpSubtitleLabel(_ subtitleLabel: UILabel) {
        subtitleLabel.font = .preferredFont(for: .subheadline, weight: .medium)
        subtitleLabel.textColor = UIColor.Eatery.gray05
    }
    
    private func setUpExpandButton() {
        expandButton.setImage(expandImage, for: .normal)
        expandButton.contentMode = .scaleAspectFill
        
        if isExpanded {
            print("Expanded")
        }
    }
    
    private func setUpConstraints() {
        snp.makeConstraints { make in
            make.width.equalTo(343)
            make.height.equalTo(66)
        }
        
        labelStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.bottom.equalToSuperview().inset(12)
        }
        
        expandButton.snp.makeConstraints { make in
            make.width.equalTo(18)
            make.height.equalTo(16)
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    func addAlertView(_ view: UIView) {
        alertsStackView.addArrangedSubview(view)
    }
    
    private func updateUIForExpansion() {
        print("Will update")
        expandButton.setImage(isExpanded ? collapseImage : expandImage, for: .normal)
    }
}

class ExpandableCardDetailView: UIView {
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpSelf()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpSelf() {
        backgroundColor = .systemBlue
        titleLabel.text = "Testing"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
    }
    
    func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().offset(10)
        }
    }
}
