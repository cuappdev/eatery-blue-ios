//
//  MealTimePicker.swift
//  Eatery Blue
//
//  Created by Charles Liggins on 12/3/24.
//

import UIKit

class MealTimePicker: UIView {
    private let stackView: UIStackView
    private let breakfastToggle: UIButton
    private let lunchToggle: UIButton
    private let dinnerToggle: UIButton
    private let bottomBar: UIView
    private let selectionIndicator: UIView
    
    override init(frame: CGRect) {
        stackView = UIStackView()
        breakfastToggle = UIButton(type: .custom)
        lunchToggle = UIButton(type: .custom)
        dinnerToggle = UIButton(type: .custom)
        bottomBar = UIView()
        selectionIndicator = UIView()
        
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Configure stackView
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 0
        
        // Configure toggles
        [breakfastToggle, lunchToggle, dinnerToggle].forEach { button in
            button.setTitleColor(.gray, for: .normal)
            button.setTitleColor(.black, for: .selected)
            button.titleLabel?.font = UIFont.preferredFont(for: .subheadline, weight: .regular)
            stackView.addArrangedSubview(button)
        }
        
        breakfastToggle.setTitle("Breakfast", for: .normal)
        lunchToggle.setTitle("Lunch", for: .normal)
        dinnerToggle.setTitle("Dinner", for: .normal)
        
        // Add targets for button actions
        breakfastToggle.addTarget(self, action: #selector(breakfastTapped), for: .touchUpInside)
        lunchToggle.addTarget(self, action: #selector(lunchTapped), for: .touchUpInside)
        dinnerToggle.addTarget(self, action: #selector(dinnerTapped), for: .touchUpInside)
        
        // Configure bottom bar
        bottomBar.backgroundColor = .gray
        
        
        
        // Configure selection indicator
        selectionIndicator.backgroundColor = .black
        
        // Add subviews
        addSubview(stackView)
        addSubview(bottomBar)
        addSubview(selectionIndicator)
        
        // Set up constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            bottomBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 2),
            
            selectionIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 2),
            selectionIndicator.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/3)
        ])
        
        // Set initial selection
        toggleSelection(breakfastToggle)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 145, height: 44)
    }
    
    @objc private func breakfastTapped() {
        toggleSelection(breakfastToggle)
        // Add your breakfast function here
    }
    
    @objc private func lunchTapped() {
        toggleSelection(lunchToggle)
        // Add your lunch function here
    }
    
    @objc private func dinnerTapped() {
        toggleSelection(dinnerToggle)
        // Add your dinner function here
    }
    
    private func toggleSelection(_ selectedButton: UIButton) {
        [breakfastToggle, lunchToggle, dinnerToggle].forEach { button in
            button.isSelected = (button == selectedButton)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.selectionIndicator.frame.origin.x = selectedButton.frame.origin.x
        }
    }
}
