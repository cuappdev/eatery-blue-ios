//
//  CarouselView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import EateryModel
import UIKit

class CarouselView: UIView {
    
    // MARK: - Properties (data)

    var carouselEateries: [Eatery] = [] {
        didSet {
            fullRefresh()
        }
    }
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    var navigationController: UINavigationController?
    /// How many eateries should show in this carousel, -1 if showing all
    var truncateAfter: Int = -1 {
        didSet {
            collectionView.reloadData()
        }
    }
    var viewControllerToPush: UIViewController?

    // MARK: - Properties (view)
    
    let titleLabel = UILabel()
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private let buttonImageView = UIImageView()
    
    // MARK: - Initializers
        
    init() {
        super.init(frame: .zero)
        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func fullRefresh() {
        buttonImageView.tap { [weak self] _ in
            guard let self else { return }
            pushListViewController(title: title)
        }
        
        collectionView.reloadData()
    }

    // MARK: - Setup
    
    private func setUpSelf() {
        insetsLayoutMarginsFromSafeArea = false
        
        snp.makeConstraints { make in
            make.height.equalTo(260)
        }

        addSubview(titleLabel)
        setUpTitleLabel()

        addSubview(buttonImageView)
        setUpButtonImageView()

        addSubview(collectionView)
        setUpCollectionView()
    }

    private func setUpTitleLabel() {
        titleLabel.text = title
        titleLabel.font = .preferredFont(for: .title2, weight: .semibold)
    }

    private func setUpButtonImageView() {
        buttonImageView.isUserInteractionEnabled = true
        buttonImageView.image = UIImage(named: "ButtonArrowForward")
        buttonImageView.tap { [weak self] _ in
            guard let self else { return }
            pushListViewController(title: title ?? "")
        }
    }

    private func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(EateryMediumCardCollectionViewCell.self, forCellWithReuseIdentifier: EateryMediumCardCollectionViewCell.reuse)
        collectionView.register(CarouselMoreEateriesCollectionViewCell.self, forCellWithReuseIdentifier: CarouselMoreEateriesCollectionViewCell.reuse)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.alwaysBounceHorizontal = true
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

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - OTHER
    
    private func pushListViewController(title: String) {
        navigationController?.hero.isEnabled = false

        if let viewControllerToPush {
            navigationController?.pushViewController(viewControllerToPush, animated: true)
            return
        }

        let viewController = ListModelController()
        viewController.setUp(carouselEateries, title: title, description: nil)

        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CarouselView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == min(truncateAfter, carouselEateries.count) && truncateAfter > -1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselMoreEateriesCollectionViewCell.reuse, for: indexPath) as? CarouselMoreEateriesCollectionViewCell else { return UICollectionViewCell() }
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EateryMediumCardCollectionViewCell.reuse, for: indexPath) as? EateryMediumCardCollectionViewCell else { return UICollectionViewCell() }
        
        cell.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 2,
            options: .curveEaseInOut,
            animations: {
                cell.transform = .identity
            }
        )

        let eatery = carouselEateries[indexPath.section]
        cell.configure(eatery: eatery)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if truncateAfter > -1 {
            return min(truncateAfter + 1, carouselEateries.count)
        }
        
        return carouselEateries.count
    }

}

extension CarouselView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.section == min(truncateAfter, carouselEateries.count) && truncateAfter > -1 {
            pushListViewController(title: title)
            return
        }

        let pageVC = EateryPageViewController(eateries: carouselEateries, index: indexPath.section)
        pageVC.modalPresentationStyle = .overCurrentContext
        navigationController?.hero.isEnabled = false
        navigationController?.pushViewController(pageVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
            cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
            cell?.transform = .identity
        }
    }
    
}

extension CarouselView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == min(truncateAfter, carouselEateries.count) && truncateAfter > -1 {
            return CGSize(width: 156, height: 196)
        }
        return CGSize(width: 312, height: 196)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = CGFloat(18)
        
        if section == min(truncateAfter, carouselEateries.count) && truncateAfter > -1 {
            return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        }
        
        if section == carouselEateries.count - 1 {
            return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        }
        
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: 0)
    }
    
}
