//
//  DocumentBrowserViewController.swift
//  UTNotes
//
//  Created by 倪可塑 on 2021/4/20.
//

import UIKit

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate, UIViewControllerTransitioningDelegate {

    private var transitionController: UIDocumentBrowserTransitionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
        
        let settings = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settings))
        additionalTrailingNavigationBarButtonItems = [settings]
        
        view.tintColor = UIColor(named: "AccentColor")
    }
    
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL: URL? = Bundle.main.url(forResource: "untitled", withExtension: "md")
        
        if newDocumentURL != nil {
            importHandler(newDocumentURL, .copy)
        } else {
            importHandler(nil, .none)
        }
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        let editorViewController = MarkdownEditorViewController()

        let naviController = UINavigationController(rootViewController: editorViewController)
        naviController.modalPresentationStyle = .fullScreen
        
        let progress = Progress(totalUnitCount: 0)
        naviController.transitioningDelegate = self
        let transitionController = transitionController(forDocumentAt: documentURL)
        transitionController.targetView = editorViewController.textView
        transitionController.loadingProgress = progress
        self.transitionController = transitionController
        
        editorViewController.openDocument(at: documentURL) {
            self.present(naviController, animated: true)
        }
    }
}

extension DocumentBrowserViewController {
    @objc
    func settings() {
        let naviController = UINavigationController(rootViewController: SettingsViewController(style: .grouped))
        naviController.modalPresentationStyle = .popover
        naviController.popoverPresentationController?.barButtonItem = additionalTrailingNavigationBarButtonItems.first
        present(naviController, animated: true)
    }
}


// UIViewControllerTransitioningDelegate
extension DocumentBrowserViewController {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionController
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionController
    }
}
