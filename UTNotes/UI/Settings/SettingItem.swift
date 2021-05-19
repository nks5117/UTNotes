//
//  SettingItem.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/16.
//

import UIKit

protocol SettingItem {
    func configCell(_ cell: UITableViewCell)
    func select()
}

struct BaseSettingItem: SettingItem {
    let title: String
    let action: (() -> Void)?
    let subtitle: String?
    
    func configCell(_ cell: UITableViewCell) {
        cell.textLabel?.text = title
        cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.text = subtitle
    }
    
    func select() {
        action?()
    }
    
    init (_ title: String, subtitle: String? = nil, action: (() -> Void)?) {
        self.title = title
        self.action = action
        self.subtitle = subtitle
    }
}

class SwitchSettingItem: SettingItem {
    let title: String
    let switchAction: ((Bool) -> Void)?
    let switchView: UISwitch
    
    func configCell(_ cell: UITableViewCell) {
        cell.textLabel?.text = title
        cell.accessoryView = switchView
    }
    
    func select() {
        
    }
    
    @objc func valueChanged() {
        switchAction?(switchView.isOn)
    }
    
    init(_ title: String, defaultValue: Bool, switchAction: ((Bool)->Void)?) {
        self.title = title
        self.switchAction = switchAction
        self.switchView = UISwitch()
        self.switchView.isOn = defaultValue
        self.switchView.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
}
