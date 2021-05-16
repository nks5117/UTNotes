//
//  MarkdownIt.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/14.
//

import Foundation
import JavaScriptCore

class MarkdownIt {
    private static let jsUrl: URL = {
        guard let url = Bundle.main.url(forResource: "markdown-it/dist/markdown-it", withExtension: "js") else {
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

    var inline: ParserInline {
        get {
            ParserInline(jsValue.forProperty("inline"))
        }
    }
    
    var block: ParserBlock {
        get {
            ParserBlock(jsValue.forProperty("block"))
        }
    }
    
    var renderer: Renderer {
        get {
            Renderer(jsValue.forProperty("renderer"))
        }
    }
    
    convenience init(jsContext: JSContext? = nil, preset: Preset? = nil) {
        self.init(jsContext: jsContext, presetName: preset?.rawValue)
    }
    
    init(jsContext: JSContext? = nil, presetName: String? = nil, options: [OptionKey : Any]? = nil) {
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
        
        if let presetName = presetName {
            self.jsContext.setObject(presetName, forKeyedSubscript: "presetName" as (NSCopying & NSObjectProtocol))
            self.jsValue = self.jsContext.evaluateScript("""
            this.markdownit(presetName);
            """)
        } else if let options = options {
            var jsOptions = [String : Any]()
            for (key, value) in options {
                jsOptions[key.rawValue] = value
            }
            self.jsContext.setObject(jsOptions, forKeyedSubscript: "options" as (NSCopying & NSObjectProtocol))
            self.jsValue = self.jsContext.evaluateScript("""
            this.markdownit(options);
            """)
        } else {
            self.jsValue = self.jsContext.evaluateScript("""
            this.markdownit();
            """)
        }
    }
    
    func disable(list: [String], ignoreInvalid: Bool) -> MarkdownIt {
        jsValue.invokeMethod("disable", withArguments: [list, ignoreInvalid])
        return self
    }
    
    func disable(name: String, ignoreInvalid: Bool) -> MarkdownIt {
        jsValue.invokeMethod("disable", withArguments: [name, ignoreInvalid])
        return self
    }
    
    func enable(list: [String], ignoreInvalid: Bool) -> MarkdownIt {
        jsValue.invokeMethod("enable", withArguments: [list, ignoreInvalid])
        return self
    }
    
    func enable(name: String, ignoreInvalid: Bool) -> MarkdownIt {
        jsValue.invokeMethod("enable", withArguments: [name, ignoreInvalid])
        return self
    }
    
    func render(src: String, env: [AnyHashable : Any] = [:]) -> String {
        if let result = jsValue.invokeMethod("render", withArguments: [src, env]).toString() {
            return result
        }
        return ""
    }
    
    func renderInline(src: String, env: [AnyHashable : Any] = [:]) -> String {
        if let result = jsValue.invokeMethod("render", withArguments: [src, env]).toString() {
            return result
        }
        return ""
    }
    
    func set(options: [OptionKey : Any]) -> MarkdownIt {
        jsValue.invokeMethod("set", withArguments: [options])
        return self
    }
    
    func use(plugin: String) -> MarkdownIt {
        jsValue.invokeMethod("use", withArguments: [plugin])
        return self
    }
    
    func use(plugin: String, params: Any ... ) -> MarkdownIt {
        jsValue.invokeMethod("use", withArguments: [plugin, params])
        return self
    }
}

extension MarkdownIt {
    enum Preset: String {
        case commonmark
        case zero
    }
    
    struct OptionKey : Equatable, Hashable, RawRepresentable {

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }

        public let rawValue: String

        public typealias RawValue = String

        public static let html = OptionKey("html")
        public static let xhtmlOut = OptionKey("xhtmlOut")
        public static let breaks = OptionKey("breaks")
        public static let langPrefix = OptionKey("langPrefix")
        public static let linkify = OptionKey("linkify")
        public static let typographer = OptionKey("typographer")
        public static let quotes = OptionKey("quotes")
        public static let highlight = OptionKey("highlight")
    }
}
