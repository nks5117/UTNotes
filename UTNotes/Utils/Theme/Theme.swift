//
//  Theme.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/19.
//

import UIKit

struct Theme {
    var text : [NSAttributedString.Key: Any] = [:]
    var bold : [NSAttributedString.Key: Any] = [:]
    var italic : [NSAttributedString.Key: Any] = [:]
    var formula : [NSAttributedString.Key: Any] = [:]
    var strikethrough : [NSAttributedString.Key: Any] = [:]
    var inlineCode : [NSAttributedString.Key: Any] = [:]
    var h1 : [NSAttributedString.Key: Any] = [:]
    var h2 : [NSAttributedString.Key: Any] = [:]
    var h3 : [NSAttributedString.Key: Any] = [:]
    var h4 : [NSAttributedString.Key: Any] = [:]
    var h5 : [NSAttributedString.Key: Any] = [:]
    var backgroundColor: UIColor = .systemBackground
    var lineIndicatorColor: UIColor = .secondarySystemBackground
    
    static var `default`: Theme {
        var theme = Theme()
        let defaultSize = UIFont.systemFontSize + 2
        let defaultFont = UIFont.monospacedSystemFont(ofSize: defaultSize, weight: .regular)
        let boldFont = UIFont.monospacedSystemFont(ofSize: defaultSize, weight: .bold)
        var italicFont = defaultFont
        if let descriptor = defaultFont.fontDescriptor.withSymbolicTraits(.traitItalic) {
            italicFont = UIFont(descriptor: descriptor, size: UIFont.systemFontSize)
        }
        
        theme.text = [
            .font: defaultFont,
            .foregroundColor: UIColor.label,
        ]
        theme.bold = [
            .font: boldFont,
            .foregroundColor: UIColor.label,
        ]
        theme.italic = [
            .font: italicFont,
            .foregroundColor: UIColor.label,
        ]
        theme.strikethrough = [
            .font: defaultFont,
            .foregroundColor: UIColor.secondaryLabel
        ]
        theme.inlineCode = [
            .font: defaultFont,
            .foregroundColor: UIColor.init(light: "9F1C10", dark: "EFAB90")
        ]
        theme.h1 = [
            .font: UIFont.monospacedSystemFont(ofSize: defaultSize + 4, weight: .bold),
            .foregroundColor: UIColor.init(light: "5A7FF6", dark: "4F7AEF")
        ]
        theme.h2 = [
            .font: UIFont.monospacedSystemFont(ofSize: defaultSize + 3, weight: .bold),
            .foregroundColor: UIColor.init(light: "5A7FF6", dark: "4F7AEF")
        ]
        theme.h3 = [
            .font: UIFont.monospacedSystemFont(ofSize: defaultSize + 2, weight: .bold),
            .foregroundColor: UIColor.init(light: "5A7FF6", dark: "4F7AEF")
        ]
        theme.h4 = [
            .font: UIFont.monospacedSystemFont(ofSize: defaultSize + 1, weight: .bold),
            .foregroundColor: UIColor.init(light: "5A7FF6", dark: "4F7AEF")
        ]
        theme.h5 = [
            .font: UIFont.monospacedSystemFont(ofSize: defaultSize, weight: .bold),
            .foregroundColor: UIColor.init(light: "5A7FF6", dark: "4F7AEF")
        ]
        theme.formula = [
            .font: defaultFont,
            .foregroundColor: UIColor.init(light: "001080", dark: "9CDCFE")
        ]
        
        theme.backgroundColor = .init(light: "FFFFFF", dark: "1B1D1F")
        theme.lineIndicatorColor = .init(light: "EDF1F8", dark: "242628")
        
        return theme
    }
}
