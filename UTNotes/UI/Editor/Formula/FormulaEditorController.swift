//
//  FormulaEditor.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/13.
//

import UIKit
import SnapKit
import KatexUtils

class FormulaEditorController : UIViewController, UITextViewDelegate {
    
    var editFinished : ((_ text: String) -> Void)?
    
    lazy var textView : UITextView = {
        let textView = UITextView(frame: .zero)
        textView.font = .monospacedSystemFont(ofSize: 17, weight: .regular)
        textView.delegate = self
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.spellCheckingType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no
        textView.layer.cornerRadius = 5
        return textView
    }()
    
    lazy var katexView : KatexView = {
        let katexView = KatexView(frame: .zero, latex: "")
        katexView.backgroundColor = .white
        katexView.layer.cornerRadius = 5
        katexView.clipsToBounds = true
        katexView.latex = textView.text
        katexView.displayMode = displayModeSwitch.isOn
        katexView.maxSize = CGSize(width: UIScreen.main.bounds.size.width - 40, height: 200)
        return katexView
    }()
    
    lazy var settingsBar : UIView = {
        let bottomBar = UIView(frame: .zero)
        return bottomBar
    }()
    
    lazy var displayModeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = NSLocalizedString("formula_editor_display_mode", comment: "Display mode") + " "
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("button_title_done", comment: "Done"), for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.addTarget(self, action: #selector(done), for: .touchUpInside)
        button.sizeToFit()
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("button_title_cancel", comment: "Cancel"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        button.sizeToFit()
        return button
    }()
    
    lazy var displayModeSwitch: UISwitch = {
        let displayModeSwitch = UISwitch(frame: .zero)
        displayModeSwitch.isOn = false
        displayModeSwitch.sizeToFit()
        displayModeSwitch.addTarget(self, action: #selector(switchAction(_:)), for: .valueChanged)
        return displayModeSwitch
    }()
    
    lazy var contentView : UIView = {
        let contentView = UIView(frame: .zero)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 5
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        return contentView
    }()
    
    override func viewDidLoad() {
        view.addSubview(contentView)
        contentView.addSubview(textView)
        contentView.addSubview(katexView)
        contentView.addSubview(settingsBar)
        settingsBar.addSubview(displayModeLabel)
        settingsBar.addSubview(displayModeSwitch)
        settingsBar.addSubview(doneButton)
        settingsBar.addSubview(cancelButton)
        
        displayModeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(displayModeSwitch)
            make.left.equalTo(settingsBar)
        }
        
        displayModeSwitch.snp.makeConstraints { make in
            make.left.equalTo(displayModeLabel.snp.right).offset(5)
            make.top.equalTo(settingsBar)
        }
        
        doneButton.snp.makeConstraints { make in
            make.centerY.equalTo(displayModeSwitch)
            make.right.equalTo(settingsBar).offset(-10)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(displayModeSwitch)
            make.right.equalTo(doneButton.snp.left).offset(-10)
        }
        
        textView.snp.makeConstraints { make in
            make.top.left.equalTo(contentView).offset(10)
            make.right.equalTo(contentView).offset(-10)
            make.height.equalTo(200)
        }
        settingsBar.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(10)
            make.right.equalTo(contentView).offset(-10)
            make.top.equalTo(textView.snp.bottom).offset(10)
            make.height.equalTo(displayModeSwitch.snp.height)
        }
        katexView.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(10)
            make.right.equalTo(contentView).offset(-10)
            make.top.equalTo(settingsBar.snp.bottom).offset(10)
        }
        contentView.snp.makeConstraints { make in
            make.top.equalTo(view).offset(50)
            make.left.equalTo(view).offset(10)
            make.right.equalTo(view).offset(-10)
            make.bottom.equalTo(katexView).offset(10)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        katexView.maxSize = CGSize(width: view.bounds.width - 40, height: 200)
    }
}

extension FormulaEditorController {
    func textViewDidChange(_ textView: UITextView) {
        katexView.latex = textView.text
    }
}

extension FormulaEditorController {
    @objc
    func switchAction(_ displayModeSwitch: UISwitch) {
        katexView.displayMode = displayModeSwitch.isOn
    }
    
    @objc
    func dismissKeyboard() {
        textView.resignFirstResponder()
    }
    
    @objc
    func done() {
        var latex = ""
        if let text = textView.text {
            if displayModeSwitch.isOn {
                latex = "$$\n\(text)\n$$"
            } else {
                latex = "$ \(text) $"
            }
        }
        editFinished?(latex)
        dismiss(animated: true)
    }
    
    @objc
    func cancel() {
        dismiss(animated: true)
    }
}
