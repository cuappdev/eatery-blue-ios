//
//  MenusNavigationView.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 9/13/23.
//

import UIKit

class MenusNavigationView: NavigationView {
    
    let scrollView = UIScrollView()
    
    private(set) var fadeInProgress: Double = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpSelf() {
        backgroundColor = UIColor.Eatery.blue
        layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)

        titleLabel.text = "Upcoming Menus"
        titleLabel.textColor = .white

        largeTitleLabel.text = "Upcoming Menus"
        largeTitleLabel.textColor = .white
        
        addSubview(scrollView)
        setUpScrollView()
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.equalTo(layoutMarginsGuide)
        }
        
        scrollView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
    }
    
    private func setUpScrollView() {
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    func setFadeInProgress(_ progress: Double) {
        titleLabel.alpha = progress
    }
    
    func setFadeInProgress(_ progress: Double, animated: Bool) {
        if progress == fadeInProgress {
            return
        }

        let progress = max(0, min(1, progress))
        self.fadeInProgress = progress

        if animated {
            UIView.animate(withDuration: 0.125) {
                self.setFadeInProgress(progress)
            }
        } else {
            setFadeInProgress(progress)
        }
    }
}
