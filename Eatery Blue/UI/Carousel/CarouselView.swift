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

    /// Eateries to show inside this carousel
    var eateries: [Eatery] = [] {
        didSet {
            applySnapshot()
        }
    }
    /// Text to display on top of this carousel
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    /// Navigation controller to push from
    var navigationController: UINavigationController?
    /// An observer to be attatched to this view
    private var observer: NSObjectProtocol?
    /// How many eateries should show in this carousel, -1 if showing all
    var truncateAfter: Int = -1 {
        didSet {
            applySnapshot()
        }
    }
    /// View controller to push when more button is pressed, nil if a ListViewController should be pushed
    var viewControllerToPush: UIViewController?

    private lazy var dataSource = makeDataSource()

    // MARK: - Properties (view)
    private let buttonImageView = UIImageView()
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private let titleLabel = UILabel()

    // MARK: - Initializers
        
    init() {
        super.init(frame: .zero)
        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }


    // MARK: - Setup
    
    private func setUpSelf() {
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

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
            pushViewController()
        }
    }

    private func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 18
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(EateryMediumCardCollectionViewCell.self, forCellWithReuseIdentifier: EateryMediumCardCollectionViewCell.reuse)
        collectionView.register(CarouselMoreEateriesCollectionViewCell.self, forCellWithReuseIdentifier: CarouselMoreEateriesCollectionViewCell.reuse)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.delegate = self
        collectionView.alwaysBounceHorizontal = true
    }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(layoutMarginsGuide)
            make.centerY.equalTo(buttonImageView)
        }

        buttonImageView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing)
            make.width.height.equalTo(40)
            make.top.trailing.equalTo(layoutMarginsGuide)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - OTHER
    
    private func pushViewController() {
        navigationController?.hero.isEnabled = false

        if let viewControllerToPush {
            navigationController?.pushViewController(viewControllerToPush, animated: true)
            return
        }

        let viewController = ListModelController()
        viewController.setUp(eateries, title: self.title, description: nil)

        navigationController?.pushViewController(viewController, animated: true)
    }

    func setupObserver(_ notificationName: String, completion: @escaping () -> Void) {
        observer = NotificationCenter.default.addObserver(
            forName: NSNotification.Name(notificationName),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard self != nil else { return }
            completion()
        }
    }

    // MARK: - Collection View Data Source

    /// Creates and returns the table view data source
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { [weak self] (tableview, indexPath, row) in
            guard let self else { return UICollectionViewCell() }

            switch row {
            case .eatery(let eatery):
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

                cell.configure(eatery: eatery)
                return cell
            case .more:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselMoreEateriesCollectionViewCell.reuse, for: indexPath) as? CarouselMoreEateriesCollectionViewCell else { return UICollectionViewCell() }
                return cell
            }
        }

        return dataSource
    }

    /// Updates the table view data source, and animates if desired
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        if truncateAfter > -1 {
            snapshot.appendItems(
                eateries.map({ .eatery($0) }).prefix(truncateAfter) + (eateries.count <= truncateAfter ? [] : [.more])
            )
        } else {
            snapshot.appendItems(
                eateries.map({ .eatery($0) })
            )
        }

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

}

extension CarouselView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch item {
        case .eatery:
            let pageVC = EateryPageViewController(eateries: eateries, index: indexPath.item)
            navigationController?.hero.isEnabled = false
            navigationController?.pushViewController(pageVC, animated: true)
            break
        case .more:
            pushViewController()
            break
        }
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
        if indexPath.section == min(truncateAfter, eateries.count) && truncateAfter > -1 {
            return CGSize(width: 156, height: 196)
        }
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return CGSize(width: 312, height: 196) }
        
        return item.getSize()
    }

}

extension CarouselView {

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>


    enum Section {
        case main
    }

    enum Item: Hashable {
        case eatery(Eatery)
        case more

        func getSize() -> CGSize {
            switch self {
            case .eatery:
                return CGSize(width: 312, height: 196)
            case .more:
                return CGSize(width: 156, height: 196)
            }
        }
    }

}
