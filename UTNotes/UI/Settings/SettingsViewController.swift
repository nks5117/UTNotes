//
//  SettingsViewController.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/10.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    var settingItems: [(String, [SettingItem])] = []
    
    lazy var footerLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        label.text = "UT Notes\n\(version)"
        label.sizeToFit()
        label.frame.size.height += 20
        return label
    }()
    
    override func viewDidLoad() {
        title = "Settings"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = footerLabel
        
        settingItems = [
            ("Editor", [
                SwitchSettingItem("Show formula preview", defaultValue: SettingsManager.shared.showFormulaPreview) { isOn in
                    SettingsManager.shared.showFormulaPreview = isOn
                }
            ]),
            ("Preview", [
                SwitchSettingItem("Enable HTML tags", defaultValue: SettingsManager.shared.enableHtmlTags) { isOn in
                    SettingsManager.shared.enableHtmlTags = isOn
                },
                SwitchSettingItem("Enable breaks in paragraph", defaultValue: SettingsManager.shared.enableBreaksInParagraph) { isOn in
                    SettingsManager.shared.enableBreaksInParagraph = isOn
                },
                SwitchSettingItem("Autoconvert URL-like text to links", defaultValue: SettingsManager.shared.linkify) { isOn in
                    SettingsManager.shared.linkify = isOn
                },
                SwitchSettingItem("Footnote", defaultValue: SettingsManager.shared.footnote) { isOn in
                    SettingsManager.shared.footnote = isOn
                },
            ]),
            ("General", [
                BaseSettingItem("Open Source Licenses") {
                    let openSourceVC = OpenSourceViewController()
                    self.navigationController?.pushViewController(openSourceVC, animated: true)
                },
            ])
        ]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        settingItems.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingItems[section].1.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        settingItems[section].0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            fatalError()
        }
        let settingItem = settingItems[indexPath.section].1[indexPath.row]
        settingItem.configCell(cell)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        let settingItem = settingItems[indexPath.section].1[indexPath.row]
        settingItem.select()
    }
}
