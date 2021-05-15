//
//  FormulaPreviewController.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/5/13.
//

import UIKit
import SnapKit
import KatexUtils
import Combine

class FormulaPreviewController: UIViewController, UIPopoverPresentationControllerDelegate {
    var formula: String {
        didSet {
            katexView.latex = formula
        }
    }
    var displayMode: Bool {
        didSet {
            katexView.displayMode = displayMode
        }
    }
    
    private var cancellables = [AnyCancellable]()
    
    lazy var katexView: KatexView = {
        let katexView = KatexView(frame: .zero, latex: formula, maxSize: CGSize(width: UIScreen.main.bounds.width - 60, height: 300), options: [.displayMode: displayMode])
        katexView.backgroundColor = .white
        return katexView
    }()
    
    init(formula: String = "", displayMode: Bool = false) {
        self.formula = formula
        self.displayMode = displayMode
        super.init(nibName: nil, bundle: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.addSubview(katexView)
        katexView.$status.sink { [self] status in
            switch status {
            case.finished:
                DispatchQueue.main.async {
                    preferredContentSize = CGSize(width: katexView.intrinsicContentSize.width + 20, height: katexView.intrinsicContentSize.height + 20)
                    UIView.animate(withDuration: 0.25) {
                        view.alpha = 1.0
                        popoverPresentationController?.containerView?.alpha = 1.0
                    }
                }
            default:
                break
            }
        }.store(in: &cancellables)
    }
    
    override func viewWillLayoutSubviews() {
        katexView.snp.remakeConstraints { make in
            var offsets = [10, 10, 10, 10]
            if let direction = popoverPresentationController?.arrowDirection {
                switch direction {
                case .up:
                    offsets[0] += 10
                case .down:
                    offsets[1] += 10
                case .left:
                    offsets[2] += 10
                case .right:
                    offsets[3] += 10
                default:
                    break
                }
            }
            make.top.equalTo(view).offset(offsets[0])
            make.bottom.equalTo(view).offset(-offsets[1])
            make.left.equalTo(view).offset(offsets[2])
            make.right.equalTo(view).offset(-offsets[3])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.alpha = 0.0
        popoverPresentationController?.containerView?.alpha = 0.0
        preferredContentSize = CGSize(width: 20, height: 20)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        .none
    }
}
