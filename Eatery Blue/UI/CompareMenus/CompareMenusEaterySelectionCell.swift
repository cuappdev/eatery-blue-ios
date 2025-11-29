//
//  CompareMenusEaterySelectionCell.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/2/24.
//

import EateryModel
import UIKit

class CompareMenusEaterySelectionCell: UITableViewCell {
    // MARK: - Properties (data)

    static let reuse = "CompareMenusEaterySelectionCellReuse"

    // MARK: - Properties (view)

    private let checkView = UIImageView()
    private let nameView = UILabel()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpSelf()
        setUpConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func configure(eatery: Eatery, filled: Bool, draggable: Bool) {
        nameView.text = eatery.name
        if filled {
            checkView.image = UIImage(named: "CheckboxFilled")
        } else {
            checkView.image = UIImage(named: "CheckboxUnfilled")
        }

        layoutIfNeeded()
        if draggable {
            nameView.snp.updateConstraints { make in
                make.trailing.equalToSuperview().offset(32)
            }
        } else {
            nameView.snp.updateConstraints { make in
                make.trailing.equalToSuperview()
            }
        }

        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let self else { return }
            self.layoutIfNeeded()
        }

        selectionStyle = .none
        let cellBackground = UIView()
        cellBackground.backgroundColor = UIColor.Eatery.default00
        backgroundView = cellBackground
        cellBackground.snp.makeConstraints { make in
            make.edges.equalTo(self.snp.edges)
        }
    }

    private func setUpSelf() {
        addSubview(nameView)
        addSubview(checkView)
    }

    private func setUpConstraints() {
        checkView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(24)
        }

        nameView.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.leading.equalTo(checkView.snp.trailing).offset(8)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let reorderControl = subviews.first(where: { subview in
            type(of: subview).description() == "UITableViewCellReorderControl"
        }) {
            reorderControl.snp.remakeConstraints { make in
                make.trailing.height.centerY.equalToSuperview()
                make.leading.equalTo(self.snp.trailing).inset(24)
            }
        }
    }
}
