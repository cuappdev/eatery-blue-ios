//
//  ButtonView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/21/22.
//  Updated by ChatGPT on 4/18/25.
//

import UIKit

class ButtonView<Content: UIView>: ContainerView<Content>, UIGestureRecognizerDelegate {

    private let button = UIButton(type: .custom)

    // Normal “short tap” callback
    private var callback: ((UIButton) -> Void)?

    // Optional long‑press callback & configuration
    private var longPressCallback: ((UIButton) -> Void)?
    private var longPressDuration: TimeInterval = 0
    private var longPressActivated = false

    // MARK: - Initializers

    /// Original designated initializer for just a normal button
    override init(content: Content) {
        super.init(content: content)
        setupButton()
    }

    /// Convenience initializer to also set up a long‑press callback
    /// - Parameters:
    ///   - content: your content view
    ///   - longPressDuration: minimum press duration (in seconds) before long‑press fires
    ///   - longPressCallback: closure to run if press ≥ `longPressDuration`
    convenience init(
        pillContent: Content,
        longPressDuration: TimeInterval
    ) {
        self.init(pillContent: pillContent)
        self.longPressDuration = longPressDuration
        setupLongPressGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API

    /// Set the normal tap callback
    func buttonPress(_ callback: ((UIButton) -> Void)?) {
        self.callback = callback
    }

    /// Set the long‑press callback
    func buttonLongPress(_ callback: ((UIButton) -> Void)?) {
        self.longPressCallback = callback
    }

    // MARK: - Setup

    private func setupButton() {
        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        button.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonTouchUpOutside), for: .touchUpOutside)
    }

    private func setupLongPressGesture() {
        let longPressGR = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        longPressGR.delegate = self
        longPressGR.minimumPressDuration = longPressDuration
        // Allow the button’s normal touchUpInside to coexist (gated it in code)
        button.addGestureRecognizer(longPressGR)
    }

    // MARK: - Touch Handlers

    @objc private func buttonTouchDown(_ sender: UIButton) {
        // shrink immediately
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: .beginFromCurrentState
        ) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func buttonTouchUpInside(_ sender: UIButton) {
        UIView.animate(
            withDuration: 0.15,
            delay: 0.15,
            options: .beginFromCurrentState
        ) { [weak self] in
            self?.transform = .identity
        } completion: { [weak self] _ in
            guard let self = self else { return }
            // only fire the normal callback if a long‑press wasn't already triggered
            if !self.longPressActivated {
                self.callback?(sender)
            }
            // reset for next tap
            self.longPressActivated = false
        }
    }

    @objc private func buttonTouchUpOutside(_ sender: UIButton) {
        UIView.animate(
            withDuration: 0.15,
            delay: 0.15,
            options: .beginFromCurrentState
        ) { [weak self] in
            self?.transform = .identity
        }
        // cancel any pending long‑press state
        longPressActivated = false
    }

    @objc private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        // fire exactly once, when the minimumPressDuration has elapsed
        guard recognizer.state == .began else { return }
        longPressActivated = true
        // bounce back to identity if still “pressed down”
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: .beginFromCurrentState
        ) { [weak self] in
            self?.transform = .identity
        }
        longPressCallback?(button)
    }
}
