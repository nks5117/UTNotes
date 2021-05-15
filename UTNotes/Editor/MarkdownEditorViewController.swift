//
//  MarkdownEditorViewController.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/8.
//

import UIKit
import SnapKit
import Combine


class MarkdownEditorViewController: UIViewController, UITextViewDelegate {
    var document : MarkdownDocument?
    var documentURL : URL?
    
    lazy var textView : UITextView = {
        let textView = EditorTextView(frame: .zero)
        textView.keyboardDismissMode = .interactive
        textView.isScrollEnabled = true
        textView.delegate = self
        textView.layer.insertSublayer(lineIndicatorLayer, at: 0)
        return textView
    }()
    
    lazy var lineIndicatorLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.secondarySystemBackground.cgColor
        return layer
    }()
    
    lazy var toolbar : UIToolbar = {
        let toolbar = UIToolbar(frame: .zero)
        toolbar.items = [
            UIBarButtonItem(image: UIImage(systemName: "eye"), style: .plain, target: self, action: #selector(showPreview)),
        ]
        return toolbar
    }()
    
    var cancellables : [AnyCancellable] = []
    
    override func viewDidLoad() {
        title = document?.fileURL.lastPathComponent
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeFile))
        
        view.addSubview(toolbar)
        //view.addSubview(navigationBar)
        view.addSubview(textView)
        
        toolbar.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.width.equalTo(view)
        }
        
        textView.snp.makeConstraints { make in
            make.width.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(toolbar.snp.top)
        }
                
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification).sink { notification in
            guard
                let userInfo = notification.userInfo,
                let frame = userInfo[UIWindow.keyboardFrameEndUserInfoKey] as? CGRect,
                let curve = userInfo[UIWindow.keyboardAnimationCurveUserInfoKey] as? UInt,
                let duration = userInfo[UIWindow.keyboardAnimationDurationUserInfoKey] as? Double
            else {
                return
            }
            
            UIView.animate(withDuration: duration, delay: 0, options: .init(rawValue: curve << 16)) {
                self.toolbar.snp.remakeConstraints { make in
                    make.width.equalTo(self.view)
                    make.bottom.equalTo(self.view.snp.bottom).offset(-frame.height)
                }
                self.view.layoutIfNeeded()
            }
        }.store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification).sink { _ in
            self.toolbar.snp.remakeConstraints { make in
                make.width.equalTo(self.view)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            }
        }.store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        document?.open { [self] success in
            if success {
                textView.text = document?.text
            }
        }
    }
}

extension MarkdownEditorViewController {
    @objc
    func closeFile() {
        document?.text = textView.text
        if let documentURL = documentURL {
            document?.save(to: documentURL, for: .forOverwriting) { [self] success in
                document?.close { success in
                    if success {
                        self.dismiss(animated: true)
                    }
                }
            }
        } else {
            document?.close { success in
                if success {
                    self.dismiss(animated: true)
                }
            }
        }
    }
}


// Formula Edit
extension MarkdownEditorViewController {
    @objc
    func editFormula() {
        let formulaEditor = FormulaEditorController()
        
        if let range = checkAndGetFormulaRange() {
            var latex = (textView.text as NSString).substring(with: range)
            let displayMode = latex.starts(with: "$$")
            latex = latex.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "$")))
            formulaEditor.displayModeSwitch.isOn = displayMode
            formulaEditor.textView.text = latex
            formulaEditor.editFinished = { [self] text in
                textView.textStorage.replaceCharacters(in: range, with: text)
                textView.selectedRange.length = (text as NSString).length
            }
        } else {
            formulaEditor.editFinished = { [self] text in
                textView.insertText(text)
                textView.scrollRangeToVisible(textView.selectedRange)
            }
        }
        
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: false) {
                self.present(formulaEditor, animated: true)
            }
        } else {
            present(formulaEditor, animated: true)
        }
    }
    
    func checkAndGetFormulaRange() -> NSRange? {
        let locationBegin = textView.selectedRange.location
        let locationEnd = locationBegin + textView.selectedRange.length
        let textStorage = textView.textStorage
        var range = NSRange()
        if locationBegin >= textView.text.utf16.count {
            return nil
        }
        if
            textStorage.attribute(.init("BlockFormula"), at: locationBegin, effectiveRange: &range) != nil,
            range.location + range.length >= locationEnd
        {
            return range
        }
        if
            textStorage.attribute(.init("InlineFormula"), at: locationBegin, effectiveRange: &range) != nil,
            range.location + range.length >= locationEnd
        {
            return range
        }
        return nil
    }
}

// UITextViewDelegate
extension MarkdownEditorViewController {
    func textViewDidBeginEditing(_ textView: UITextView) {
        toolbar.items = [
            UIBarButtonItem(image: UIImage(systemName: "eye"), style: .plain, target: nil, action: #selector(showPreview)),
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(image: UIImage(systemName: "sum"), style: .plain, target: self, action: #selector(editFormula)),
        ]
        updateLineIndicator()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        toolbar.items = [
            UIBarButtonItem(image: UIImage(systemName: "eye"), style: .plain, target: nil, action: #selector(showPreview)),
        ]
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.isFirstResponder {
            showPopoverIfNeeded()
            updateLineIndicator()
        }
    }
    
    func updateLineIndicator() {
        if textView.selectedRange.length != 0 {
            lineIndicatorLayer.frame = .zero
            return
        }
        
        guard let selectedTextRange = textView.selectedTextRange else {
            return
        }
        var rect = textView.caretRect(for: selectedTextRange.start)
        rect.origin.x = 0
        rect.size.width = textView.frame.width
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        lineIndicatorLayer.frame = rect
        CATransaction.commit()
    }
    
    func showPopoverIfNeeded() {
        let location = textView.selectedRange.location
        var range = NSRange()
        if
            location < (textView.text as NSString).length,
            let selectedTextRange = textView.selectedTextRange,
            textView.textStorage.attribute(.init("InlineFormula"), at: location, effectiveRange: &range) != nil ||
            textView.textStorage.attribute(.init("BlockFormula"), at: location, effectiveRange: &range) != nil
        {
            var latex = (textView.text as NSString).substring(with: range)
            let displayMode = latex.starts(with: "$$")
            latex = latex.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "$")))
            
            let configAndPresentPopover = { [self] in
                let formulaPreviewController = FormulaPreviewController()
                formulaPreviewController.formula = latex
                formulaPreviewController.displayMode = displayMode
                formulaPreviewController.modalPresentationStyle = .popover
                formulaPreviewController.popoverPresentationController?.backgroundColor = .white
                formulaPreviewController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
                formulaPreviewController.popoverPresentationController?.delegate = formulaPreviewController
                formulaPreviewController.popoverPresentationController?.passthroughViews = [toolbar]
                formulaPreviewController.popoverPresentationController?.sourceView = textView
                formulaPreviewController.popoverPresentationController?.sourceRect = textView.firstRect(for: selectedTextRange)
                present(formulaPreviewController, animated: true)
            }
            
            if let presentedViewController = presentedViewController {
                if
                    let formulaPreviewController = presentedViewController as? FormulaPreviewController,
                    displayMode == formulaPreviewController.displayMode && latex == formulaPreviewController.formula
                {
                    return
                } else {
                    presentedViewController.dismiss(animated: false) {
                        configAndPresentPopover()
                    }
                }
            } else {
                configAndPresentPopover()
            }
        } else if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true)
        }
    }
}

// preview
extension MarkdownEditorViewController {
    @objc
    func showPreview() {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }
        let previewViewController = MarkdownPreviewViewController(textView.text)
        navigationController?.pushViewController(previewViewController, animated: true)
    }
}