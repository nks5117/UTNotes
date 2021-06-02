//
//  OpenSourceViewController.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/10.
//

import UIKit
import SnapKit

class OpenSourceViewController: UIViewController {
    lazy var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        if let url = Bundle.main.url(forResource: "opensource", withExtension: "") {
            textView.text = try? String(contentsOf: url)
        }
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.sizeToFit()
        return textView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    override func viewDidLoad() {
        title = "Open Source Licenses"
        view.addSubview(scrollView)
        scrollView.addSubview(textView)
        scrollView.contentSize = textView.contentSize
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
}
