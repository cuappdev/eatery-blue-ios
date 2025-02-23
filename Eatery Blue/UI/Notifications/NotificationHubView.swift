//
//  NotificationHubView.swift
//  Eatery Blue
//
//  Created by Cindy Liang on 2/22/25.
//

import Foundation
import UIKit

class NotificationHubView: UIView {

    // MARK: - Properties (View)

    let tableView = UITableView()
    private let titleLabel = UILabel()
    var navigationController: UINavigationController?

  
    private var itemData: [FavoriteItemNotif] = [FavoriteItemNotif(name:"Chicken Nuggets",date:"Today",eateries:"At Okies"),FavoriteItemNotif(name:"Chicken Nuggets",date:"Today",eateries:"At Okies"),FavoriteItemNotif(name:"Chicken Nuggets",date:"Today",eateries:"At Okies"),FavoriteItemNotif(name:"Chicken Nuggets",date:"Today",eateries:"At Okies")]
  

//    private lazy var dataSource = makeDataSource()


    // MARK: - Init

    init() {
        super.init(frame: .zero)

        setUpSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Set Up

    private func setUpSelf() {
        self.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 4, right: 16)
        
        addSubview(titleLabel)
        setUpTitleLabel()
        
        setUpTableView()
        self.addSubview(tableView)

        setUpConstraints()
     
    }

    private func setUpTitleLabel(){
        titleLabel.text = "Favorite Items"
        titleLabel.font = .eateryNavigationBarTitleFont
        titleLabel.textColor = UIColor.Eatery.black
    }
    private func setUpTableView() {
        
        tableView.register(NotificationHubTableViewCell.self, forCellReuseIdentifier: NotificationHubTableViewCell.reuse)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        tableView.rowHeight = 80
    }

    private func setUpConstraints() {
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(layoutMarginsGuide.snp.leading).inset(4)
            make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
            make.top.equalTo(layoutMarginsGuide.snp.top)
        }


        tableView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom)
        }
    }
}


extension NotificationHubView: NotificationHubTableViewCellDelegate {
    func cellDidRequestNavigation(_ cell: NotificationHubTableViewCell, favoriteItem:FavoriteItemNotif) {
        
        //TODO: want the items side to be selected not eatery side
        let favoritesViewController = FavoritesViewController()
        navigationController?.pushViewController(favoritesViewController, animated: true)
        favoriteItem.isSelected = true
        self.tableView.reloadData()
    }

}


extension NotificationHubView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let favoritesViewController = FavoritesViewController()
//     
//        navigationController?.pushViewController(favoritesViewController, animated: true)
  
    }

}


extension NotificationHubView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NotificationHubTableViewCell.reuse, for: indexPath) as? NotificationHubTableViewCell{
            cell.configure(favoriteItemData: itemData[indexPath.row] )
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        }else{
            return UITableViewCell()
        }
                
        
    }
    
}

