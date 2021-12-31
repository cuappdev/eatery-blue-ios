//
//  WaitTimesView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/25/21.
//

import UIKit

@objc
protocol WaitTimeViewDelegate: NSObjectProtocol {

    @objc
    optional func waitTimesView(_ sender: WaitTimesView, waitTimeTextForCell cell: WaitTimeCell, atIndex index: Int) -> String

    @objc
    optional func waitTimesView(_ sender: WaitTimesView, shouldHighlightCell cell: WaitTimeCell, atIndex index: Int) -> Bool

    @objc
    optional func waitTimesView(_ sender: WaitTimesView, didHighlightCell cell: WaitTimeCell, atIndex index: Int)

    @objc
    optional func waitTimesViewDidScroll(_ sender: WaitTimesView)

}

class WaitTimesView: UIView {

    let scrollView = UIScrollView()
    let stackView = UIStackView()
    private var cells: [WaitTimeCell] = []

    private var waitTimePositionConstraint: NSLayoutConstraint?
    let waitTimeLabel = ContainerView(content: UILabel())
    let connectingLine = UIView()

    private(set) var highlightedIndex: Int?

    weak var delegate: WaitTimeViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        clipsToBounds = true
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "Gray01")?.cgColor

        addSubview(scrollView)
        setUpScrollView()
    }

    private func setUpScrollView() {
        scrollView.clipsToBounds = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self

        scrollView.addSubview(connectingLine)
        setUpConnectingLine()

        scrollView.addSubview(stackView)
        setUpStackView()

        scrollView.addSubview(waitTimeLabel)
        setUpWaitTimeLabel()
    }

    private func setUpConnectingLine() {
        connectingLine.backgroundColor = UIColor(named: "EateryBlue")
        connectingLine.alpha = 0
    }

    private func setUpWaitTimeLabel() {
        waitTimeLabel.content.font = .preferredFont(for: .caption2, weight: .semibold)
        waitTimeLabel.content.textColor = .white
        waitTimeLabel.cornerRadius = 4
        waitTimeLabel.cornerRadiusView.backgroundColor = UIColor(named: "EateryBlue")
        waitTimeLabel.layoutMargins = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        waitTimeLabel.alpha = 0
    }

    private func setUpStackView() {
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
    }

    private func setUpConstraints() {
        height(216)

        scrollView.topToSuperview()
        scrollView.bottomToSuperview()
        scrollView.widthToSuperview(multiplier: 1/6)
        scrollView.centerXToSuperview()

        stackView.edgesToSuperview()
        stackView.heightToSuperview()

        waitTimeLabel.topToSuperview(offset: 12)

        connectingLine.centerX(to: waitTimeLabel)
        connectingLine.topToBottom(of: waitTimeLabel)
        connectingLine.bottomToSuperview()
        connectingLine.width(2)
    }

    func addCell(_ cell: WaitTimeCell) {
        let index = cells.count

        let container = ContainerView(content: cell)
        stackView.addArrangedSubview(container)
        container.width(to: self, multiplier: 1/6)

        container.on(UITapGestureRecognizer()) { [self] _ in
            highlightCell(at: index, notifyDelegate: true, animated: true)
        }

        cells.append(cell)
    }

    func removeCells() {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }

        cells.removeAll()
    }

    func dehighlightCells() {
        if let previousIndex = highlightedIndex {
            cells[previousIndex].bar.backgroundColor = UIColor(named: "EateryBlueMedium")
        }
        highlightedIndex = nil

        connectingLine.alpha = 0
        waitTimeLabel.alpha = 0
    }

    func highlightCell(at index: Int, askDelegate: Bool = true, notifyDelegate: Bool = false) {
        guard 0 <= index, index < cells.count else {
            return
        }

        let cell = cells[index]
        if askDelegate, !(delegate?.waitTimesView?(self, shouldHighlightCell: cell, atIndex: index) ?? true) {
            return
        }

        if highlightedIndex == index {
            return
        }

        if let previousIndex = highlightedIndex {
            cells[previousIndex].bar.backgroundColor = UIColor(named: "EateryBlueMedium")
        }
        highlightedIndex = index


        cell.bar.backgroundColor = UIColor(named: "EateryBlue")

        connectingLine.alpha = 1
        waitTimeLabel.alpha = 1
        waitTimePositionConstraint?.isActive = false
        waitTimePositionConstraint = waitTimeLabel.centerX(to: cell)

        waitTimeLabel.content.text = delegate?.waitTimesView?(self, waitTimeTextForCell: cell, atIndex: index)

        if notifyDelegate {
            delegate?.waitTimesView?(self, didHighlightCell: cell, atIndex: index)
        }
    }

    private func highlightCell(at index: Int, askDelegate: Bool = true, notifyDelegate: Bool = false, animated: Bool) {
        if highlightedIndex == index {
            return
        }

        if animated {
            UIView.animate(
                withDuration: 0.15,
                delay: 0,
                options: [.allowUserInteraction, .beginFromCurrentState]
            ) { [self] in
                highlightCell(at: index, askDelegate: askDelegate, notifyDelegate: notifyDelegate)
                layoutIfNeeded()
            }
        } else {
            highlightCell(at: index, askDelegate: askDelegate, notifyDelegate: notifyDelegate)
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let child = super.hitTest(point, with: event)

        let result: UIView?

        if child === self {
            result = stackView.hitTest(convert(point, to: stackView), with: event) ?? scrollView
        } else {
            result = child
        }

        return result
    }

    func visibleCellIndexes() -> [Int] {
        cells.enumerated().filter { (i, cell) in
            let cellRectInView = cell.convert(cell.bounds, to: self)
            return bounds.contains(cellRectInView)
        }.map { $0.offset }
    }

    func scrollCellToCenter(at index: Int, animated: Bool) {
        guard 0 <= index, index < cells.count else {
            return
        }

        layoutIfNeeded()

        let cell = cells[index]
        let offset = cell.convert(cell.bounds, to: scrollView).minX
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
    }

}

extension WaitTimesView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.waitTimesViewDidScroll?(self)
    }

}
