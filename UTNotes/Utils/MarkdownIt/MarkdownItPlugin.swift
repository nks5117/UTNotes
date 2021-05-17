//
//  MarkdownItPlugin.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/17.
//

import Foundation
import JavaScriptCore

protocol MarkdownItPlugin {
    var jsValue: JSValue { get }
}
