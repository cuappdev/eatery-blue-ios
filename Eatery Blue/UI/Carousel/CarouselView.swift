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
    private var collectionView: UICollectionView
    private let titleLabel = UILabel()

    // MARK: - Init

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(frame: .zero)

        setUpSelf()
        setUpConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        snp.makeConstraints { make in
            make.height.equalTo(260)
        }
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
        collectionView.register(EateryMediumCardView.self, forCellWithReuseIdentifier: EateryMediumCardView.reuse)
        collectionView.register(
            CarouselMoreEateriesCollectionViewCell.self,
            forCellWithReuseIdentifier: CarouselMoreEateriesCollectionViewCell.reuse
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.delegate = self
        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = .clear
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

    // MARK: - Actions

    private func pushViewController() {
        navigationController?.hero.isEnabled = false

        if let viewControllerToPush {
            navigationController?.pushViewController(viewControllerToPush, animated: true)
            return
        }

        let viewController = ListModelController()
        viewController.setUp(eateries, title: title, description: nil)

        navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: - Collection View Data Source

    /// Creates and returns the table view data source
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { [weak self] _, indexPath, row in
            guard let self else { return UICollectionViewCell() }

            switch row {
            case let .eatery(eatery, favorited):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: EateryMediumCardView.reuse,
                    for: indexPath
                ) as? EateryMediumCardView else { return UICollectionViewCell() }
                cell.configure(eatery: eatery, favorited: favorited)
                return cell
            case .more:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CarouselMoreEateriesCollectionViewCell.reuse,
                    for: indexPath
                ) as? CarouselMoreEateriesCollectionViewCell else { return UICollectionViewCell() }

                return cell
            }
        }

        return dataSource
    }

    /// Updates the table view data source, and animates if desired
    private func applySnapshot(animated: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])

        let coreDataStack = AppDelegate.shared.coreDataStack

        let eateryCells = eateries.map { Item.eatery(
            eatery: $0,
            favorited: coreDataStack.metadata(eateryId: $0.id).isFavorite
        ) }

        if truncateAfter > -1 {
            snapshot.appendItems(Array(eateryCells.prefix(truncateAfter)), toSection: .main)
            if eateryCells.count > truncateAfter {
                snapshot.appendItems([.more], toSection: .main)
            }
        } else {
            snapshot.appendItems(eateryCells, toSection: .main)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

extension CarouselView: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch item {
        case .eatery:
            let pageVC = EateryPageViewController(eateries: eateries, index: indexPath.item)
            navigationController?.hero.isEnabled = false
            navigationController?.pushViewController(pageVC, animated: true)
        case .more:
            pushViewController()
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
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
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
        case eatery(eatery: Eatery, favorited: Bool)
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
