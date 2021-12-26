//
//  EditorTextView.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/13.
//

import UIKit

class EditorTextView: UITextView {
    lazy var highlightRect: CALayer = {
        let rect = CALayer()
        rect.cornerRadius = 5.0
        rect.backgroundColor = UIColor.black.cgColor
        rect.opacity = 0.2
        return rect
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        if textContainer != nil {
            super.init(frame: .zero, textContainer: textContainer)
            return
        }

        let storage = UTTextStorage()

        let layoutManager = NSLayoutManager()
        storage.addLayoutManager(layoutManager)
        let container = NSTextContainer()
        container.replaceLayoutManager(layoutManager)
        super.init(frame: .zero, textContainer: container)
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
