//
//  CarouselView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/22/21.
//

import UIKit
import EateryModel

class CarouselView: UIView {
    
    // MARK: - Fields
    
    var allItems: [Eatery]
    var carouselItems: [Eatery]
    let navigationController: UINavigationController?
    let shouldTruncate: Bool

    
    // MARK: - Properties
    
    let titleLabel = UILabel()
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    let buttonImageView = UIImageView()
    
    // MARK: - Initializers
        
    required init(allItems: [Eatery], carouselItems: [Eatery], navigationController: UINavigationController?, shouldTruncate: Bool) {
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
    
    // MARK: - Update
    
    public func updateCarousel(carouselItems: [Eatery]) {
        
        buttonImageView.tap { [self] _ in
            pushListViewController(title: titleLabel.text ?? "", description: "", eateries: carouselItems)
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
        titleLabel.font = .preferredFont(for: .title2, weight: .semibold)
    }

    private func setUpButtonImageView() {
        buttonImageView.isUserInteractionEnabled = true
        buttonImageView.image = UIImage(named: "ButtonArrowForward")
        buttonImageView.tap { [self] _ in
            pushListViewController(title: titleLabel.text ?? "", description: "", eateries: carouselItems)
        }
    }

    private func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(EateryMediumCardCollectionViewCell.self, forCellWithReuseIdentifier: EateryMediumCardCollectionViewCell.reuse)
        collectionView.register(CarouselMoreEateriesView.self, forCellWithReuseIdentifier: CarouselMoreEateriesView.reuse)
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
            make.leading.equalTo(snp.leading)
            make.trailing.equalTo(snp.trailing)
            make.bottom.equalTo(snp.bottom)
        }
    }
    
    // MARK: - OTHER
    
    private func pushListViewController(title: String, description: String?, eateries: [Eatery]) {
        let viewController = ListModelController()
        viewController.setUp(eateries, title: title, description: description)

        navigationController?.hero.isEnabled = false
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CarouselView: UICollectionViewDataSource {
    
    // what is the cell?
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == min(3, carouselItems.count) && shouldTruncate {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselMoreEateriesView.reuse, for: indexPath) as? CarouselMoreEateriesView else { return UICollectionViewCell() }
            
            cell.tap {_ in 
                self.pushListViewController(title: self.titleLabel.text ?? "", description: nil, eateries: self.carouselItems)
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
    
    // how many items in each section?
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return 1
    }
    
    // how many sections?
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if shouldTruncate {
            return min(4, carouselItems.count)
        }
        
        return carouselItems.count
    }
}

extension CarouselView: UICollectionViewDelegate {
    
    // on tap
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pageVC = EateryPageViewController(eateries: carouselItems, index: indexPath.section)
        pageVC.modalPresentationStyle = .overCurrentContext
        navigationController?.hero.isEnabled = false
        navigationController?.pushViewController(pageVC, animated: true)
    }
    
    // press down
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
            cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    // lift up
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
            cell?.transform = .identity
        }
    }
}

extension CarouselView: UICollectionViewDelegateFlowLayout {
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == min(3, carouselItems.count) && shouldTruncate {
            return CGSize(width: 156, height: 196)
        }
        return CGSize(width: 312, height: 196)
    }
    
    // insets
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
