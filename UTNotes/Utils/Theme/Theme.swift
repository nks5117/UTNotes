//
//  Theme.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/19.
//

import UIKit

@objc
enum NodeType: UInt {
    case h1
    case h2
    case h3
    case h4
    case h5
    case text
    case bold
    case italic
    case formula
    case strikethrough
    case inlineCode
    case blockCode
    case table
    case listMarker
    case link
}

@objc
class Theme: NSObject {
    var backgroundColor: UIColor = .systemBackground
    var lineIndicatorColor: UIColor = .secondarySystemBackground
    var defaultSize = UIFont.systemFontSize + 2

    @objc var defaultFount: UIFont {
        UIFont.systemFont(ofSize: defaultSize, weight: .regular)
    }

    @objc func fontDescriptor(for nodeType: NodeType) -> UIFontDescriptor {
        let descriptor = defaultFount.fontDescriptor

        switch nodeType {
        case .text:
            return descriptor
        case .bold:
            return descriptor.withSize(0.0).withSymbolicTraits(.traitBold) ?? descriptor
        case .italic:
            return descriptor.withSize(0.0).withSymbolicTraits(.traitItalic) ?? descriptor
        case .formula:
            return descriptor.withSize(0.0).withSymbolicTraits(.traitMonoSpace) ?? descriptor
        case .strikethrough:
            return descriptor.withSize(0.0)
        case .inlineCode, .blockCode, .table, .listMarker, .link:
            return descriptor.withSize(0.0).withSymbolicTraits(.traitMonoSpace) ?? descriptor
        case .h1:
            return descriptor.withSize(defaultSize + 4).withSymbolicTraits(.traitBold) ?? descriptor
        case .h2:
            return descriptor.withSize(defaultSize + 3).withSymbolicTraits(.traitBold) ?? descriptor
        case .h3:
            return descriptor.withSize(defaultSize + 2).withSymbolicTraits(.traitBold) ?? descriptor
        case .h4:
            return descriptor.withSize(defaultSize + 1).withSymbolicTraits(.traitBold) ?? descriptor
        case .h5:
            return descriptor.withSize(0.0).withSymbolicTraits(.traitBold) ?? descriptor
        }
    }

    @objc func attributes(for nodeType: NodeType) -> [NSAttributedString.Key: Any] {
        switch nodeType {
        case .text:
            return [
                .backgroundColor: UIColor.clear,
                .foregroundColor: UIColor.label,
            ]
        case .bold, .italic, .formula:
            return [:]
        case .strikethrough:
            return [
                .foregroundColor: UIColor.secondaryLabel,
            ]
        case .inlineCode:
            return [
                .foregroundColor: UIColor.init(light: "9F1C10", dark: "EFAB90"),
            ]
        case .blockCode:
            return [
                .backgroundColor: UIColor.systemGroupedBackground,
            ]
        case .table:
            return [
                .foregroundColor: UIColor.init(light: "001080", dark: "9CDCFE")
            ]
        case .h1, .h2, .h3, .h4, .h5, .listMarker, .link:
            return [
                .foregroundColor: UIColor.init(light: "5A7FF6", dark: "4F7AEF"),
            ]
        }
    }

    @objc(defaultTheme)
    static var `default`: Theme {
        let theme = Theme()

        theme.backgroundColor = .init(light: "FFFFFF", dark: "1B1D1F")
        theme.lineIndicatorColor = .init(light: "EDF1F8", dark: "242628")
        
        return theme
    }
}
