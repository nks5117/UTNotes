//
//  Renderer.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/14.
//

import Foundation
import JavaScriptCore

class Renderer {
    var jsValue: JSValue
    
    var rules: JSValue {
        get {
            jsValue.forProperty("rules")
        }
    }
    
    init(_ jsValue: JSValue) {
        self.jsValue = jsValue
    }
}
