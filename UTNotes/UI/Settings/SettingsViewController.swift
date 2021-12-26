//
//  SettingsViewController.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/10.
//

import UIKit
import SafariServices

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
        title = NSLocalizedString("settings_page_title", comment: "Settings")
        // tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = footerLabel
        
        settingItems = [
            (NSLocalizedString("settings_group_editor", comment: "Editor"), [
                SwitchSettingItem(NSLocalizedString("settings_item_show_formula_preview", comment: "Show formula preview"), defaultValue: SettingsManager.shared.showFormulaPreview) { isOn in
                    SettingsManager.shared.showFormulaPreview = isOn
                },
                BaseSettingItem(NSLocalizedString("settings_item_theme", comment: "Theme"), subtitle: NSLocalizedString("editor_theme_default", comment: "Default")) {
                    let vc = ThemePickerViewController(style: .grouped)
                    self.navigationController?.pushViewController(vc, animated: true)
                },
            ]),
            (NSLocalizedString("settings_group_preview", comment: "Preview"), [
                SwitchSettingItem(NSLocalizedString("settings_item_enable_html_tags", comment: "Enable HTML tags"), defaultValue: SettingsManager.shared.enableHtmlTags) { isOn in
                    SettingsManager.shared.enableHtmlTags = isOn
                },
                SwitchSettingItem(NSLocalizedString("settings_item_enable_breaks_in_paragraph", comment: "Enable breaks in paragraph"), defaultValue: SettingsManager.shared.enableBreaksInParagraph) { isOn in
                    SettingsManager.shared.enableBreaksInParagraph = isOn
                },
                SwitchSettingItem(NSLocalizedString("settings_item_autoconvert_url_like_text_to_links", comment: "Autoconvert URL-like text to links"), defaultValue: SettingsManager.shared.linkify) { isOn in
                    SettingsManager.shared.linkify = isOn
                },
                SwitchSettingItem(NSLocalizedString("settings_item_footnote", comment: "Footnote"), defaultValue: SettingsManager.shared.footnote) { isOn in
                    SettingsManager.shared.footnote = isOn
                },
            ]),
            (NSLocalizedString("settings_group_general", comment: "General"), [
                BaseSettingItem(NSLocalizedString("settings_item_open_source_licenses", comment: "Open Source Licenses")) {
                    let openSourceVC = OpenSourceViewController()
                    self.navigationController?.pushViewController(openSourceVC, animated: true)
                },
                BaseSettingItem(NSLocalizedString("settings_item_feedback", comment: "Feedback")) {
                    var systemInfo = utsname()
                    uname(&systemInfo)
                    
                    let machine = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
                        return String(cString: ptr)
                    }
                    let systemName = UIDevice.current.systemName
                    let systemVersion = UIDevice.current.systemVersion
                    
                    let subject = "Feedback - \(machine) \(systemName) \(systemVersion)"
                    
                    let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Feedback"
                    
                    guard let feedbackUrl = URL(string: "mailto:utnotes@nikesu.com?subject=\(encodedSubject)") else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(feedbackUrl) {
                        UIApplication.shared.open(feedbackUrl)
                    }
                },
                BaseSettingItem(NSLocalizedString("settings_item_privacy_policy", comment: "Privacy Policy")) {
                    guard let privacyUrl = URL(string: "https://www.nikesu.com/UTNotes/privacy.html") else {
                        return
                    }
                    
                    self.present(SFSafariViewController(url: privacyUrl), animated: true)
                }
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
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
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
