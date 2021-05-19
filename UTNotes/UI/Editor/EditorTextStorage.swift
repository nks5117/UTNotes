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
    
    let inlineBlockFormulaRegx = try? NSRegularExpression(pattern: #"\${2}(.+?)\${2}"#, options: [])
    let blockFormulaStartRegx = try? NSRegularExpression(pattern: #"^[ \t]*\${2}"#, options: [])
    let blockFormulaEndRegx = try? NSRegularExpression(pattern: #"\${2}[ \t]*$"#, options: [])
    let inlineFormulaRegx = try? NSRegularExpression(pattern: #"(?<!\$)\$(?=[^$])(.+?)(?<=[^$])\$(?!\$)"#, options: [])
    let boldRegx = try? NSRegularExpression(pattern: #"(?<!\*)\*{2}(?=[^*])(((?!`).)+?)(?<=[^*])\*{2}(?!\*)"#, options: [])
    let italicRegx = try? NSRegularExpression(pattern: #"(?<!\*)\*(?=[^*])(((?!`).)+?)(?<=[^*])\*(?!\*)"#, options: [])
    let strikethroughRegx = try? NSRegularExpression(pattern: #"(?<!~)~(?=[^~])(((?!`).)+?)(?<=[^~])~(?!~)"#, options: [])
    let h1Regx = try? NSRegularExpression(pattern: #"^# .*$"#, options: [])
    let h2Regx = try? NSRegularExpression(pattern: #"^## .*$"#, options: [])
    let h3Regx = try? NSRegularExpression(pattern: #"^### .*$"#, options: [])
    let h4Regx = try? NSRegularExpression(pattern: #"^#### .*$"#, options: [])
    let h5Regx = try? NSRegularExpression(pattern: #"^##### .*$"#, options: [])
    let inlineCode = try? NSRegularExpression(pattern: #"(?<!`)``?(?=[^`])(.+?)(?<=[^`])``?(?!`)"#, options: [])


    
    lazy var defaultFont = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .regular)
    lazy var boldFont = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .bold)
    lazy var italicFont: UIFont = {
        guard let fontDescriptor = defaultFont.fontDescriptor.withSymbolicTraits(.traitItalic) else {
            return defaultFont
        }
        return UIFont(descriptor: fontDescriptor, size: UIFont.systemFontSize)
    }()
    
    
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
        let lineRange = (string as NSString).lineRange(for: editedRange)
        
        print("updateInLineAttributes: \(Date.timeIntervalSinceReferenceDate)")
        (string as NSString).enumerateSubstrings(in: lineRange,
                                                 options: .byLines) { str, _, range, _ in
            self.updateInlineAttributes(for: range)
        }
        print("blockFormulaStart: \(Date.timeIntervalSinceReferenceDate)")
        
        var inBlockFormula = lineRange.location > 0 && (attribute(.init("LineInBlockFormula"), at: lineRange.location - 1, effectiveRange: nil) != nil)
        var indexWaitingEnd: Int = inBlockFormula ? attribute(.init("LineInBlockFormula"), at: lineRange.location - 1, effectiveRange: nil) as? Int ?? 0 : 0
        var stopOnceMatch = false
        
        let block : ((String?, NSRange, NSRange, UnsafeMutablePointer<ObjCBool>) -> Void) = { [self] str, range, enclosingRange, stop in
            if !inBlockFormula && (blockFormulaStartRegx?.firstMatch(in: string, options: [], range: range) != nil) {
                inBlockFormula = true
                addAttributes([
                    .init("LineInBlockFormula"): range.location
                ], range: enclosingRange)
                indexWaitingEnd = range.location
            } else if blockFormulaEndRegx?.firstMatch(in: string, options: [], range: range) != nil {
                inBlockFormula = false
                let index = indexWaitingEnd
                let formulaRange = NSRange(location: index, length: enclosingRange.location - index + enclosingRange.length)
                addAttributes([
                    .init("BlockFormula"): (string as NSString).substring(with: formulaRange).trimmingCharacters(in: .whitespaces),
                ], range: formulaRange)
                addAttributes(Theme.default.formula, range: formulaRange)
                if stopOnceMatch {
                    stop.pointee = true
                }
            } else if inBlockFormula {
                addAttributes([
                    .init("LineInBlockFormula"): indexWaitingEnd
                ], range: enclosingRange)
            } else {
                removeAttribute(.init("LineInBlockFormula"), range: enclosingRange)
            }
        }
        
        (string as NSString).enumerateSubstrings(in: lineRange,
                                                 options: .byLines,
                                                 using: block)
        
        if lineRange.location + lineRange.length < (string as NSString).length {
            let remainsRange = NSRange(location: lineRange.location + lineRange.length ,
                                      length: (string as NSString).length - lineRange.length - lineRange.location)
            
            let nextLineInBlockFormula = attribute(.init("BlockFormula"), at: remainsRange.location, effectiveRange: nil) != nil
            
            if inBlockFormula || nextLineInBlockFormula {
                indexWaitingEnd = attribute(.init("LineInBlockFormula"), at: remainsRange.location - 1, effectiveRange: nil) as? Int ?? -1
                stopOnceMatch = inBlockFormula && nextLineInBlockFormula
                (string as NSString).enumerateSubstrings(in: remainsRange,
                                                         options: .byLines,
                                                         using: block)
            }
        }
        
        
        print("blockFormulaEnd: \(Date.timeIntervalSinceReferenceDate)")
        
        super.processEditing()
    }
    
    func updateInlineAttributes(for range: NSRange) {
        
        addAttributes(Theme.default.text, range: range)
        
        removeAttribute(.init("InlineFormula"), range: range)
        removeAttribute(.init("InlineBlockFormula"), range: range)
        
        var effectiveRange = NSRange()
        if attribute(.init("BlockFormula"), at: range.location, effectiveRange: &effectiveRange) != nil {
            return
        }
        
        inlineFormulaRegx?.enumerateMatches(in: string,
                                           options: [],
                                           range: range)
        { result, flags, stop in
            if let range = result?.range {
                addAttributes([.init("InlineFormula"): (string as NSString).substring(with: range)], range: range)
                addAttributes(Theme.default.formula, range: range)
            }
        }
        
        inlineBlockFormulaRegx?.enumerateMatches(in: string,
                                           options: [],
                                           range: range)
        { result, flags, stop in
            if let range = result?.range {
                addAttributes([.init("InlineBlockFormula"): (string as NSString).substring(with: range)], range: range)
                addAttributes(Theme.default.formula, range: range)
            }
        }
        
        boldRegx?.enumerateMatches(in: string, options: [], range: range, using: { result, flags, stop in
            if let range = result?.range {
                addAttributes(Theme.default.bold, range: range)
            }
        })
        
        italicRegx?.enumerateMatches(in: string, options: [], range: range, using: { result, flags, stop in
            if let range = result?.range {
                addAttributes(Theme.default.italic, range: range)
            }
        })
        
        strikethroughRegx?.enumerateMatches(in: string, options: [], range: range, using: { result, flags, stop in
            if let range = result?.range {
                addAttributes(Theme.default.strikethrough, range: range)
            }
        })
        
        inlineCode?.enumerateMatches(in: string, options: [], range: range, using: { result, flags, stop in
            if let range = result?.range {
                addAttributes(Theme.default.inlineCode, range: range)
            }
        })
        
        h1Regx?.enumerateMatches(in: string, options: [], range: range, using: { result, flags, stop in
            if let range = result?.range {
                addAttributes(Theme.default.h1, range: range)
            }
        })
        
        h2Regx?.enumerateMatches(in: string, options: [], range: range, using: { result, flags, stop in
            if let range = result?.range {
                addAttributes(Theme.default.h2, range: range)
            }
        })
        
        h3Regx?.enumerateMatches(in: string, options: [], range: range, using: { result, flags, stop in
            if let range = result?.range {
                addAttributes(Theme.default.h3, range: range)
            }
        })
        
        h4Regx?.enumerateMatches(in: string, options: [], range: range, using: { result, flags, stop in
            if let range = result?.range {
                addAttributes(Theme.default.h4, range: range)
            }
        })
        
        h5Regx?.enumerateMatches(in: string, options: [], range: range, using: { result, flags, stop in
            if let range = result?.range {
                addAttributes(Theme.default.h5, range: range)
            }
        })
    }
}
