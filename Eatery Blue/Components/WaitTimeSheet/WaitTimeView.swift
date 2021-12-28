//
//  WaitTimeView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/25/21.
//

import UIKit

@objc
protocol WaitTimeViewDelegate: AnyObject {

    @objc
    optional func waitTimeView(_ sender: WaitTimeView, waitTimeTextForCell cell: WaitTimeCell, atIndex index: Int) -> String

}

class WaitTimeView: UIView {

    let scrollView = UIScrollView()
    let stackView = UIStackView()
    private var cells: [WaitTimeCell] = []

    private var waitTimePositionConstraint: NSLayoutConstraint?
    let waitTimeLabel = ContainerView(content: UILabel())
    let connectingLine = UIView()

    private(set) var highlightIndex: Int?

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
            highlightCell(at: index, animated: true)
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
        if let previousIndex = highlightIndex {
            cells[previousIndex].bar.backgroundColor = UIColor(named: "BlueMedium")
        }
        highlightIndex = nil

        connectingLine.alpha = 0
        waitTimeLabel.alpha = 0
    }

    func highlightCell(at index: Int) {
        if highlightIndex == index {
            return
        }

        if let previousIndex = highlightIndex {
            cells[previousIndex].bar.backgroundColor = UIColor(named: "BlueMedium")
        }
        highlightIndex = index

        let cell = cells[index]
        cell.bar.backgroundColor = UIColor(named: "EateryBlue")

        connectingLine.alpha = 1
        waitTimeLabel.alpha = 1
        waitTimePositionConstraint?.isActive = false
        waitTimePositionConstraint = waitTimeLabel.centerX(to: cell)

        if let delegate = delegate {
            waitTimeLabel.content.text = delegate.waitTimeView?(self, waitTimeTextForCell: cell, atIndex: index)
        }
    }

    private func highlightCell(at index: Int, animated: Bool) {
        if highlightIndex == index {
            return
        }

        if animated {
            UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction]) { [self] in
                highlightCell(at: index)
                layoutIfNeeded()
            }
        } else {
            highlightCell(at: index)
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

}

extension WaitTimeView: UIScrollViewDelegate {

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let cellWidth = scrollView.bounds.width
        let initialPosition = scrollView.contentOffset.x
        let displacement = 1.5 * velocity.x * cellWidth
        let finalPosition = max(0, min(scrollView.contentSize.width, initialPosition + displacement))

        // Quantize to nearest cell increment
        let quantizedIndex = Int(round(finalPosition / cellWidth))

        targetContentOffset.pointee = CGPoint(x: cellWidth * CGFloat(quantizedIndex), y: 0)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let highlightIndex = highlightIndex else {
            return
        }

        let cellWidth = scrollView.bounds.width
        let position = scrollView.contentOffset.x
        let index = Int(round(position / cellWidth))

        let maxIndexDist = 2
        if abs(index - highlightIndex) > maxIndexDist {
            let clampedIndex = max(index - maxIndexDist, min(index + maxIndexDist, highlightIndex))
            highlightCell(at: clampedIndex, animated: false)
        }
    }

}
