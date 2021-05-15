//
//  EditorTextStorage.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/13.
//

import UIKit

class EditorTextStorage : NSTextStorage {
    var imp = NSTextStorage()
    
    var lastParseTime : TimeInterval = 0.0
    
    override var string: String {
        imp.string
    }
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        imp.attributes(at: location, effectiveRange: range)
    }
    
    override func replaceCharacters(in range: NSRange, with str: String) {
        imp.replaceCharacters(in: range, with: str)
        edited(.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)
    }
    
    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        imp.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
    }
    
    override func processEditing() {
        let time = Date.timeIntervalSinceReferenceDate
        
        if lastParseTime > 0.0 && time - lastParseTime < 1.0 {
            lastParseTime = time
            super.processEditing()
            return
        }
                
        setAttributes([
            .font: UIFont.monospacedSystemFont(ofSize: 17, weight: .regular),
            .foregroundColor: UIColor.label
        ], range: NSRange(location: 0, length: length))
        
        let blockFormulaRegx = try? NSRegularExpression(pattern: #"\${2}(.+?)\${2}"#, options: .dotMatchesLineSeparators)
        let inlineFormulaRegx = try? NSRegularExpression(pattern: #"(?<!\$)\$(?=[^$])(.+?)(?<=[^$])\$(?!\$)"#, options: .dotMatchesLineSeparators)
        
        blockFormulaRegx?.enumerateMatches(in: string,
                                           options: .init(rawValue: 0),
                                           range: NSRange(location: 0, length: string.utf16.count))
        { result, flags, stop in
            if let range = result?.range {
                addAttributes([.init("BlockFormula"): (string as NSString).substring(with: range)], range: range)
            }
        }
        
        inlineFormulaRegx?.enumerateMatches(in: string,
                                           options: .init(rawValue: 0),
                                           range: NSRange(location: 0, length: string.utf16.count))
        { result, flags, stop in
            if let range = result?.range {
                addAttributes([.init("InlineFormula"): (string as NSString).substring(with: range)], range: range)
            }
        }

        lastParseTime = Date.timeIntervalSinceReferenceDate

        super.processEditing()
    }
}
