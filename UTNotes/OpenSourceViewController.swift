//
//  OpenSourceViewController.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/10.
//

import UIKit
import SnapKit

class OpenSourceViewController: UIViewController, UITextViewDelegate {
    lazy var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        if let url = Bundle.main.url(forResource: "opensource", withExtension: "") {
            textView.text = try? String(contentsOf: url)
        }
        textView.delegate = self
        textView.isEditable = false
        return textView
    }()
    
    override func viewDidLoad() {
        title = "Open Source Licenses"
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        textView.contentOffset = CGPoint(x: 0, y: -textView.adjustedContentInset.top)
    }
}
