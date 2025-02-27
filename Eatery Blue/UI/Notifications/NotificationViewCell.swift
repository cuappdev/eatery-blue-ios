//
//  NotificationViewCell.swift
//  Eatery Blue
//
//  Created by Cindy Liang on 2/22/25.
//

import UIKit

class NotificationHubTableViewCell: UITableViewCell {

    // MARK: - Properties (View)

    private let eateryLabel = UILabel()
    private let arrowButton = UIButton()
    private let favoriteImage = UIImageView()
    private let itemNameLabel = UILabel()
    private let itemDateLabel = UILabel()
    private let index = Int()
    private var favoriteItem = FavoriteItemNotif(name: "", date: "", eateries: "")
    weak var delegate: NotificationHubTableViewCellDelegate?
 

    // MARK: - Properties (Data)

    static let reuse = "NotificationHubTableViewCellReuse"

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    func configure(favoriteItemData: FavoriteItemNotif) {
        favoriteItem = favoriteItemData
        itemNameLabel.text = favoriteItemData.itemName
        eateryLabel.text = favoriteItemData.availableEateries
        itemDateLabel.text = favoriteItemData.date
        arrowButton.setImage(UIImage(named:"ArrowRound"), for: .normal)
      
        
        if favoriteItemData.isSelected{
            favoriteImage.image = UIImage(named: "FavoriteNoNotif" )
        } else {
            favoriteImage.image = UIImage(named: "FavoriteNotif" )
        }
    
    }


    // MARK: - Set Up
    private func setUpSelf() {

        self.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 4, right: 16)

        itemNameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(itemNameLabel)
        
        itemDateLabel.font = .systemFont(ofSize: 14, weight: .regular)
        itemDateLabel.textColor = .gray
        contentView.addSubview(itemDateLabel)

        
        eateryLabel.font = .systemFont(ofSize: 12, weight: .medium)
        eateryLabel.textColor = .darkGray
        contentView.addSubview(eateryLabel)

        
        arrowButton.addTarget(self, action: #selector(tapArrowButton), for: .touchUpInside)
        arrowButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(arrowButton)
        
        contentView.addSubview(favoriteImage)

        setUpConstraints()

    }

    @objc func tapArrowButton(){
        
        delegate?.cellDidRequestNavigation(self,favoriteItem:self.favoriteItem)
       
    }
  
    

    private func setUpConstraints() {

        favoriteImage.snp.makeConstraints { make in
            make.leading.equalTo(layoutMarginsGuide.snp.leading).inset(4)
            make.centerY.equalToSuperview()
        }

        itemNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(favoriteImage.snp.trailing).offset(8)
            make.top.equalToSuperview().offset(24)
        }
        
        itemDateLabel.snp.makeConstraints { make in
            make.leading.equalTo(itemNameLabel.snp.trailing).offset(8)
            make.top.equalToSuperview().offset(26)
        }
        
        eateryLabel.snp.makeConstraints { make in
            make.leading.equalTo(favoriteImage.snp.trailing).offset(8)
            make.top.equalToSuperview().offset(42)
        }
        
        
        arrowButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
                make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
                
        }
        
    }

}
protocol NotificationHubTableViewCellDelegate: AnyObject {
    func cellDidRequestNavigation(_ cell: NotificationHubTableViewCell,favoriteItem:FavoriteItemNotif)
}
