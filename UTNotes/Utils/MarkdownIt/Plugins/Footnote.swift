//
//  Footnote.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/17.
//

import Foundation
import JavaScriptCore


class Footnote: MarkdownItPlugin {
    private static let jsUrl: URL = {
        guard let url = Bundle.main.url(forResource: "markdown-it-footnote", withExtension: "js") else {
            fatalError()
        }
        return url
    }()
    
    private static let jsString: String = {
        guard let str = try? String(data: Data(contentsOf: jsUrl), encoding: .utf8) else {
            fatalError()
        }
        return str
    }()
    
    var jsContext: JSContext
    
    var jsValue: JSValue
    
    init(jsContext: JSContext? = nil) {
        if let jsContext = jsContext {
            self.jsContext = jsContext
        } else {
            guard let jsContext = JSContext(virtualMachine: JSVirtualMachine()) else {
                fatalError()
            }
            jsContext.exceptionHandler = { context, exception in
                if let exc = exception {
                    print("JS Exception:", exc.toString() ?? "")
                }
            }
            self.jsContext = jsContext
        }
        
        self.jsContext.evaluateScript(Self.jsString, withSourceURL: Self.jsUrl)
        
        self.jsValue = self.jsContext.evaluateScript("""
        this.markdownitFootnote;
        """)
    }
}
