//
//  SheetPresentationAnimationController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/24/21.
//

import UIKit

class SheetPresentationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    private let isPresenting: Bool

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting

        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.25
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let presentedViewController = presentedViewController(transitionContext),
              let presentedView = presentedView(transitionContext) else { return }

        if isPresenting {
            transitionContext.containerView.addSubview(presentedViewController.view)
        }

        let presentedFrame = transitionContext.finalFrame(for: presentedViewController)
        presentedView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }

        let offScreenTransform = CGAffineTransform(
            translationX: 0,
            y: transitionContext.containerView.frame.maxY - presentedFrame.minY
        )

        let startTransform = isPresenting ? offScreenTransform : .identity
        let endTransform = isPresenting ? .identity : offScreenTransform

        presentedView.transform = startTransform

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseOut
        ) {
            presentedView.transform = endTransform
        } completion: { _ in
            transitionContext.completeTransition(true)
        }
    }

    private func presentingViewController(_ transitionContext: UIViewControllerContextTransitioning) -> UIViewController? {
        transitionContext.viewController(forKey: isPresenting ? .from : .to)
    }

    private func presentingView(_ transitionContext: UIViewControllerContextTransitioning) -> UIView? {
        transitionContext.view(forKey: isPresenting ? .from : .to)
    }

    private func presentedViewController(_ transitionContext: UIViewControllerContextTransitioning) -> UIViewController? {
        transitionContext.viewController(forKey: isPresenting ? .to : .from)
    }

    private func presentedView(_ transitionContext: UIViewControllerContextTransitioning) -> UIView? {
        transitionContext.view(forKey: isPresenting ? .to : .from)
    }

}
