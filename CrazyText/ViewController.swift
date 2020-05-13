//
//  ViewController.swift
//  CrazyText
//
//  Created by David Linhares on 11/05/2020.
//  Copyright © 2020 David Linhares. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textfield: UITextField!
    private var suggestView: SuggestionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textfield.autocorrectionType = .no
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            initSuggestView(keyboardHeight: keyboardSize.height)
            self.view.addSubview(suggestView!)
        }
    }
    
    private func initSuggestView(keyboardHeight: CGFloat) {
        let viewSize: CGFloat = 40
        let y = self.view.frame.height - keyboardHeight - viewSize
        self.suggestView = SuggestionView(frame: .init(x: 0, y: y, width: self.view.frame.width, height: viewSize))
        suggestView?.backgroundColor = .red
        suggestView?.add(suggestions: ["test", "azertop", "poulet"])
        self.suggestView?.tag = 1
    }

    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.suggestView = nil
            self.view.subviews.first { $0.tag == 1 }?.removeFromSuperview()
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

}
