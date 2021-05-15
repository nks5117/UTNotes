//
//  ParserInline.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/14.
//

import Foundation
import JavaScriptCore

class ParserInline {
    var jsValue: JSValue
    
    var ruler: Ruler {
        get {
            Ruler(jsValue.forProperty("ruler"))
        }
    }
    
    var ruler2: Ruler {
        get {
            Ruler(jsValue.forProperty("ruler2"))
        }
    }
    
    init(_ jsValue: JSValue) {
        self.jsValue = jsValue
    }
    
    func parse(str: String, md: String, env: Any, outTokens: Any) {
        fatalError("parse() has not been implemented")
    }
}
