//
//  Ruler.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/14.
//

import Foundation
import JavaScriptCore

class Ruler {
    var jsValue: JSValue
    
    init(_ jsValue: JSValue) {
        self.jsValue = jsValue
    }
    
    func after(afterName: String, ruleName: String, fn: JSValue!, options: [AnyHashable: Any] = [:]) {
        jsValue.invokeMethod("after", withArguments: [afterName, ruleName, fn, options])
    }
    
    func before(beforeName: String, ruleName: String, fn: JSValue!, options: [AnyHashable: Any] = [:]) {
        jsValue.invokeMethod("before", withArguments: [beforeName, ruleName, fn, options])
    }
    
    func at(name: String, fn: Any, options: [AnyHashable: Any] = [:]) {
        jsValue.invokeMethod("at", withArguments: [name, fn, options])
    }
}
