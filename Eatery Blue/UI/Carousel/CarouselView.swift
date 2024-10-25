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
    
    private let title: String
    private var allItems: [Eatery]
    private var carouselItems: [Eatery]
    private let navigationController: UINavigationController?
    private let shouldTruncate: Bool

    // MARK: - Properties (view)
    
    let titleLabel = UILabel()
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private let buttonImageView = UIImageView()
    
    // MARK: - Initializers
        
    init(title: String, allItems: [Eatery], carouselItems: [Eatery], navigationController: UINavigationController?, shouldTruncate: Bool) {
        self.title = title
        self.allItems = allItems
        self.carouselItems = carouselItems
        self.navigationController = navigationController
        self.shouldTruncate = shouldTruncate
        super.init(frame: .zero)
        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCarousel(carouselItems: [Eatery]) {
        buttonImageView.tap { [weak self] _ in
            guard let self else { return }
            pushListViewController(title: title, description: "", eateries: carouselItems)
        }
        
        var sects: [IndexPath] = []
        for i in 0...min(3, carouselItems.count) {
            sects.append(IndexPath(row: 0, section: i))
        }
        collectionView.reloadItems(at: sects)
        
        var sectionsToRemove = IndexSet()
        for item in allItems {
            if carouselItems.contains(item) {
                if !self.carouselItems.contains(item) {
                    self.carouselItems.insert(item, at: 0)
                    let index = IndexPath(item: 0, section: 0)
                    collectionView.insertSections(IndexSet(index))
                    collectionView.setContentOffset(.zero, animated: true)
                }
            } else {
                if self.carouselItems.contains(item) {
                    let removeIndex = self.carouselItems.firstIndex(of: item) ?? -1
                    if removeIndex == -1 { continue }
                    sectionsToRemove.insert(removeIndex)
                    self.carouselItems.remove(at: removeIndex)
                }
            }
        }
        collectionView.deleteSections(sectionsToRemove)
    }

    func fullRefresh(carouselItems: [Eatery]) {
        buttonImageView.tap { [weak self] _ in
            guard let self else { return }
            pushListViewController(title: title, description: "", eateries: carouselItems)
        }
        
        self.carouselItems = carouselItems
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
            pushListViewController(title: titleLabel.text ?? "", description: "", eateries: carouselItems)
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
    
    private func pushListViewController(title: String, description: String?, eateries: [Eatery]) {
        let viewController = ListModelController()
        viewController.setUp(eateries, title: title, description: description, allEateries: allItems)

        navigationController?.hero.isEnabled = false
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CarouselView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == min(3, carouselItems.count) && shouldTruncate {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselMoreEateriesCollectionViewCell.reuse, for: indexPath) as? CarouselMoreEateriesCollectionViewCell else { return UICollectionViewCell() }
            
            cell.tap { [weak self] _ in
                guard let self else { return }
                pushListViewController(title: self.titleLabel.text ?? "", description: nil, eateries: self.carouselItems)
            }
            
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

        let eatery = carouselItems[indexPath.section]
        cell.configure(eatery: eatery)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if shouldTruncate {
            return min(4, carouselItems.count)
        }
        
        return carouselItems.count
    }

}

extension CarouselView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pageVC = EateryPageViewController(allEateries: allItems, eateries: carouselItems, index: indexPath.section)
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
        if indexPath.section == min(3, carouselItems.count) && shouldTruncate {
            return CGSize(width: 156, height: 196)
        }
        return CGSize(width: 312, height: 196)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = CGFloat(18)
        
        if section == min(3, carouselItems.count) && shouldTruncate {
            return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        }
        
        if section == carouselItems.count - 1 {
            return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        }
        
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: 0)
    }
    
}
