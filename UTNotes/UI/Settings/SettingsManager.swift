//
//  SettingsManager.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/16.
//

import Foundation


struct SettingsManager {
    static var shared = SettingsManager()
    
    @Config("enable_html_tags")
    var enableHtmlTags: Bool
    
    @Config("enable_breaks_in_paragraph", default: true)
    var enableBreaksInParagraph: Bool
    
    @Config("linkify")
    var linkify: Bool
    
    @Config("footnote")
    var footnote: Bool
    
    @Config("show_formula_preview", default: true)
    var showFormulaPreview:Bool
    
}


@propertyWrapper
struct Config<T> where T: Codable {
    let key: String
    let defaultValue: T
 
    init(_ key: String, default: T) {
        self.key = key
        self.defaultValue = `default`
    }
    
    init(_ key: String) where T : ExpressibleByBooleanLiteral {
        self.init(key, default: false)
    }
    
    init(_ key: String) where T : ExpressibleByStringLiteral {
        self.init(key, default: "")
    }
    
    init(_ key: String) where T : Numeric {
        self.init(key, default: 0)
    }
    
    var wrappedValue: T {
        get {
            guard
                let data = UserDefaults.standard.data(forKey: key),
                let object = try? JSONDecoder().decode(T.self, from: data)
            else {
                return defaultValue
            }
            return object
        }
        set {
            guard
                let data = try? JSONEncoder().encode(newValue)
            else {
                return
            }
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

