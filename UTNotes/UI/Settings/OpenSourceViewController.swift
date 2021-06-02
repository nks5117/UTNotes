//
//  OpenSourceViewController.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/10.
//

import UIKit
import SnapKit

class OpenSourceViewController: UIViewController, UIScrollViewDelegate {
    lazy var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.font = .monospacedSystemFont(ofSize: 17, weight: .regular)
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
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.bouncesZoom = false
        return scrollView
    }()
    
    override func viewDidLoad() {
        title = "Open Source Licenses"
        view.addSubview(scrollView)
        scrollView.addSubview(textView)
        scrollView.contentSize = textView.frame.size
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.zoomScale = scrollView.bounds.width / scrollView.contentSize.width
        scrollView.minimumZoomScale = scrollView.zoomScale
    }
}


// UIScrollViewDelegate
extension OpenSourceViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        textView.subviews[1]
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let size = textView.subviews[1].frame.size
        scrollView.contentSize = CGSize(width: size.width * scale, height: size.height * scale)
    }
}
