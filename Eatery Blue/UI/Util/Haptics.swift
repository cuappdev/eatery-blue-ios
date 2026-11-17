//
//  Haptics.swift
//  Eatery Blue
//
// Created by Arielle Nudelman on 11/16/26.
//

import UIKit

enum Haptics {
    private static let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    private static let softImpactGenerator = UIImpactFeedbackGenerator(style: .soft)
    private static let selectionGenerator = UISelectionFeedbackGenerator()

    static func prepareLight() {
        lightImpactGenerator.prepare()
    }

    static func light() {
        lightImpactGenerator.prepare()
        lightImpactGenerator.impactOccurred()
    }

    static func soft() {
        softImpactGenerator.prepare()
        softImpactGenerator.impactOccurred()
    }

    static func selectionChanged() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }
}
