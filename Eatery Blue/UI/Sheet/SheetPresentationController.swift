//
//  SheetPresentationController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/24/21.
//

import UIKit

class SheetPresentationController: UIPresentationController {

    lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(didTapDimmingView(_:))
        ))
        return view
    }()

    override var shouldPresentInFullscreen: Bool {
        false
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }

        var frame: CGRect = .zero

        frame.size = size(
            forChildContentContainer: presentedViewController,
            withParentContainerSize: containerView.bounds.size
        )

        frame.origin.y = containerView.bounds.height - height

        return frame
    }

    private let height: CGFloat

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        height: CGFloat
    ) {
        self.height = height

        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }

        containerView.addSubview(dimmingView)
        dimmingView.edgesToSuperview()

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [self] _ in
            dimmingView.alpha = 1
        })
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [self] _ in
            dimmingView.alpha = 0
        })
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func size(
        forChildContentContainer container: UIContentContainer,
        withParentContainerSize parentSize: CGSize
    ) -> CGSize {
        CGSize(width: parentSize.width, height: height)
    }

    @objc private func didTapDimmingView(_ sender: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true)
    }

}
