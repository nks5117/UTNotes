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
                                .html: true,
                                .breaks: true,
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
    
    init(_ text: String) {
        self.text = text
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
    }
}

extension MarkdownPreviewViewController {
    func updateHtml() {
        let result = md.render(src: text)
        html = #"""
            <!DOCTYPE html>
            <html lang="zh-CN">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no, user-scalable=no">

                <link href="https://cdn.jsdelivr.net/npm/github-markdown-css@4.0.0/github-markdown.min.css" rel="stylesheet">
                <link href="https://cdn.jsdelivr.net/npm/katex@0.13.0/dist/katex.min.css" rel="stylesheet">
                <style>
                    .markdown-body {
                        overflow: auto;
                    }
                </style>
                <title>Title</title>
            </head>
            <body class="markdown-body">

                $MARKDOWN$

            </body>
            </html>
        """#.replacingOccurrences(of: "$MARKDOWN$", with: result)
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
