//
//  ThemePickerViewController.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/19.
//

import UIKit

class ThemePickerViewController: UITableViewController {
    override func viewDidLoad() {
        title = NSLocalizedString("settings_item_theme", comment: "Theme")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.text = NSLocalizedString("editor_theme_default", comment: "Default")
        cell.accessoryType = .checkmark
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
}
