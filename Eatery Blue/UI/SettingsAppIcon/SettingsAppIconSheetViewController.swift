//
//  SettingsAppIconSheetViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 4/16/24.
//

import UIKit

struct AppIcon {
    let name: String
    let icon: UIImage?
    var selected: Bool = false
}

class SettingsAppIconSheetViewController: SheetViewController {
    
    // MARK: - Properties (data)

    private var icons = [
        AppIcon(name: "Default", icon: UIImage(named: "AppIcon-Preview")),
        AppIcon(name: "Inverted", icon: UIImage(named: "AppIcon-Preview-White")),
        AppIcon(name: "OG", icon: UIImage(named: "AppIcon-Preview-OG")),
        AppIcon(name: "StPaddy", icon: UIImage(named: "AppIcon-Preview-StPaddy")),
        AppIcon(name: "Valentine", icon: UIImage(named: "AppIcon-Preview-Valentine")),
        AppIcon(name: "Red", icon: UIImage(named: "AppIcon-Preview-WhiteRed")),
        AppIcon(name: "Green", icon: UIImage(named: "AppIcon-Preview-WhiteGreen")),
        AppIcon(name: "Orange", icon: UIImage(named: "AppIcon-Preview-WhiteOrange")),
        AppIcon(name: "Yellow", icon: UIImage(named: "AppIcon-Preview-WhiteYellow"))
    ]

    // MARK: - Properties (view)

    private let iconsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
        
        setupSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupSelf() {
        addHeader(title: "Change App Icon")

        setupSelectedIcon()

        stackView.addArrangedSubview(iconsCollectionView)
        setupIconCollectionView()

        setupConstraints()
    }

    private func setupSelectedIcon() {
        let iconName = UserDefaults.standard.string(forKey: UserDefaultsKeys.activeIcon) ?? "Default"
    }

    private func setupIconCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        iconsCollectionView.setCollectionViewLayout(layout, animated: true)
        iconsCollectionView.register(SettingsAppIconCell.self, forCellWithReuseIdentifier: SettingsAppIconCell.reuse)
        iconsCollectionView.dataSource = self
        iconsCollectionView.delegate = self
        iconsCollectionView.showsVerticalScrollIndicator = false
    }

    private func setupConstraints() {
        iconsCollectionView.snp.makeConstraints { make in
            make.height.equalTo(256)
            make.leading.trailing.equalTo(stackView).inset(16)
        }
    }

    private func setIcon(named: String) {
        if named == UserDefaults.standard.string(forKey: UserDefaultsKeys.activeIcon) { return }
        if let index = icons.firstIndex(where: { $0.name == named }) {
            let iconIdentifier: String? = named == "Default" ? nil : "AppIcon-\(named)"
            UIApplication.shared.setAlternateIconName(iconIdentifier) { [weak self] _ in
                guard let self else { return }

                self.dismiss(animated: true)
            }

            UserDefaults.standard.set(named, forKey: UserDefaultsKeys.activeIcon)
            for i in 0..<icons.count {
                icons[i].selected = false
            }

            icons[index].selected = true
        }
    }

}

extension SettingsAppIconSheetViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return icons.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if icons.count / 3 > section {
            return 3
        }

        return icons.count % 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let icon = icons[indexPath.section * 3 + indexPath.row]

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsAppIconCell.reuse, for: indexPath) as? SettingsAppIconCell else { return UICollectionViewCell() }

        cell.configure(appIcon: icon)
        return cell
    }

}

extension SettingsAppIconSheetViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setIcon(named: icons[indexPath.section * 3 + indexPath.row].name)
        collectionView.reloadData()
    }

}

extension SettingsAppIconSheetViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 84, height: 84)
    }

}

