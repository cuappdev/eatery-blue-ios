//
//  MenuCardTableViewCell.swift
//  Eatery Blue
//
//  Created by Antoinette Marie Torres on 9/26/23.
//
import SnapKit
import UIKit

class MenuCardTableViewCell: UITableViewCell {
    
    private let containerView = UIStackView()
    let cellView = EateryExpandableCardContentView(frame: .zero)
    let detailView = ExpandableCardDetailView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpSelf()
        setUpConstraints()
    }
    
    private func setUpSelf() {
        selectionStyle = .none
        detailView.backgroundColor = .systemBlue
        detailView.isHidden = true
        
        containerView.axis = .vertical
        
        contentView.addSubview(containerView)
        containerView.addArrangedSubview(cellView)
        containerView.addArrangedSubview(detailView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        cellView.translatesAutoresizingMaskIntoConstraints = false
        detailView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setUpConstraints() {
        containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MenuCardTableViewCell {
    var isDetailViewHidden: Bool {
        return detailView.isHidden
    }
    
    func showDetailView() {
        detailView.isHidden = false
    }
    
    func hideDetailView() {
        detailView.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if isDetailViewHidden, selected {
            showDetailView()
        } else {
            hideDetailView()
        }
    }
}
