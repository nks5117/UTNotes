//
//  MarkdownDocument.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/8.
//

import UIKit

class MarkdownDocument : UIDocument {
    var text = ""
    
    override func contents(forType typeName: String) throws -> Any {
        return text.data(using: .utf8) ?? Data()
    }
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let contents = contents as? Data else {
            fatalError()
        }
        text = String(data: contents, encoding: .utf8) ?? ""
    }
}
