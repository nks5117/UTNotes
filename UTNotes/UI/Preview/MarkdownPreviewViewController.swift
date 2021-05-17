//
//  MarkdownPreviewViewController.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/15.
//

import UIKit
import WebKit
import JavaScriptCore
import KatexUtils
import SnapKit


class MarkdownPreviewViewController: UIViewController {
    var text: String {
        didSet {
            updateHtml()
        }
    }
    
    private lazy var webView : WKWebView = WKWebView()
    
    private lazy var md: MarkdownIt = {
        let md = MarkdownIt(jsContext: KatexRenderer.jsContext,
                            options: [
                                .html: SettingsManager.shared.enableHtmlTags,
                                .breaks: SettingsManager.shared.enableBreaksInParagraph,
                            ])
        let jsContext = md.jsContext
        let mathParserRule = mathParserRule(for: jsContext)
        let mathRendererRule = mathRendererRule(for: jsContext)
        md.inline.ruler.before(beforeName: "escape", ruleName: "math", fn: mathParserRule)
        md.renderer.rules.setValue(mathRendererRule, forProperty: "math")
        return md
    }()

    private var html: String = "" {
        didSet {
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
    
    private var documentTitle: String
    
    init(_ text: String, documentTitle: String? = nil) {
        self.text = text
        self.documentTitle = documentTitle ?? "Title"
        super.init(nibName: nil, bundle: nil)
        updateHtml()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
    }
}

extension MarkdownPreviewViewController {
    @objc
    func share() {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(documentTitle).html")
        do {
            try html.data(using: .utf8)?.write(to: fileURL)
        } catch {
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityVC.modalPresentationStyle = .popover
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
    }
}

extension MarkdownPreviewViewController {
    func updateHtml() {
        let result = md.render(src: text)
        guard
            let url = Bundle.main.url(forResource: "template", withExtension: "html"),
            let baseHtml = try? String(contentsOf: url, encoding: .utf8)
        else {
            return
        }
        html = baseHtml
                .replacingOccurrences(of: "$TITLE$", with: documentTitle)
                .replacingOccurrences(of: "$MARKDOWN$", with: result)
    }
}

extension MarkdownPreviewViewController {
    func mathParserRule(for jsContext: JSContext) -> JSValue! {
        return jsContext.evaluateScript(#"""
            (state) => {
                const delimiters = [
                    {left: '$$', right: '$$', display: true},
                    {left: '$', right: '$', display: false},
                    {left: '\\(', right: '\\)', display: false},
                    {left: '\\[', right: '\\]', display: true},
                ];
                let start = -1, end = -1;
                let display = true;
                let delimiterLeft, delimiterRight;
                for (const delimiter of delimiters.filter((d)=>{return d.display===true;})) {
                    if (state.src.startsWith(delimiter.left, state.pos)) {
                        start = state.pos + delimiter.left.length;
                        delimiterLeft = delimiter.left;
                        delimiterRight = delimiter.right;
                        break;
                    }
                }
                if (start === -1) {
                    for (const delimiter of delimiters.filter((d)=>{return d.display===false;})) {
                        if (state.src.startsWith(delimiter.left, state.pos)) {
                            start = state.pos + delimiter.left.length;
                            delimiterLeft = delimiter.left;
                            delimiterRight = delimiter.right;
                            display = false;
                            break;
                        }
                    }
                }
                if (start === -1) {
                    return false;
                }
                let i = start;
                while (i < state.src.length) {
                    if (state.src.startsWith(delimiterRight, i)) {
                        end = i;
                        break;
                    }
                    else if (state.src[i] === '\\') {
                        i += 1;
                    }
                    i += 1;
                }
                if (end <= start) {
                    return false;
                }
                const content = state.src.slice(start, end);
                const token = state.push('math');
                token.content = content.trim();
                token.display = display;
                token.delimiterLeft = delimiterLeft;
                token.delimiterRight = delimiterRight;
                state.pos += content.length + delimiterLeft.length + delimiterRight.length;
                if (display && state.src.startsWith('\n', state.pos)) {
                    state.pos += 1;
                }
                return true;
            }
        """#)
    }
    
    func mathRendererRule(for jsContext: JSContext) -> JSValue! {
        return jsContext.evaluateScript(#"""
            (tokens, idx) => {
                const content = tokens[idx].content, display = tokens[idx].display;
                return katex.renderToString(content,{
                    throwOnError: false,
                    displayMode: display,
                });
            }
        """#)
    }
}
