//
//  MarkdownEditorViewController.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/8.
//

import UIKit
import SnapKit
import Combine

class MarkdownEditorViewController: UIViewController, UINavigationBarDelegate, UITextViewDelegate {
    var document : MarkdownDocument?
    var documentURL : URL?
    lazy var textView : UITextView = {
        let textView = UITextView()
        textView.font = .monospacedSystemFont(ofSize: 17, weight: .regular)
        textView.keyboardDismissMode = .interactive
        textView.isScrollEnabled = true
        textView.delegate = self
        return textView
    }()
    
    lazy var toolbar : UIToolbar = {
        let toolbar = UIToolbar(frame: .zero)
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .play, target: nil, action: nil)]
        return toolbar
    }()
    
    lazy var navigationBar : UINavigationBar = {
        let navigationBar = UINavigationBar(frame: .zero)
        let rootItem = UINavigationItem(title: "Editor")
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeFile))
        rootItem.rightBarButtonItem = doneButton
        navigationBar.items = [rootItem]
        navigationBar.delegate = self
        return navigationBar
    }()
    
    var cancellables : [AnyCancellable] = []
    
    override func viewDidLoad() {
        view.addSubview(toolbar)
        view.addSubview(navigationBar)
        view.addSubview(textView)
        
        toolbar.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.width.equalTo(view)
        }

        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.width.equalTo(view)
        }
        
        textView.snp.makeConstraints { make in
            make.width.equalTo(view)
            make.top.equalTo(navigationBar.snp.bottom)
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

// UINavigationBarDelegate
extension MarkdownEditorViewController {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }
}

