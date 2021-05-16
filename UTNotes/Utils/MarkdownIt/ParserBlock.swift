//
//  ParserBlock.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/16.
//

import Foundation
import JavaScriptCore

class ParserBlock {
    var jsValue: JSValue
    
    var ruler: Ruler {
        get {
            Ruler(jsValue.forProperty("ruler"))
        }
    }
    
    init(_ jsValue: JSValue) {
        self.jsValue = jsValue
    }
    
    func parse(str: String, md: String, env: Any, outTokens: Any) {
        fatalError("parse() has not been implemented")
    }
}
