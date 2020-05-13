//
//  ViewController.swift
//  CrazyText
//
//  Created by David Linhares on 11/05/2020.
//  Copyright © 2020 David Linhares. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textfield: UITextField!
    private var suggestView: SuggestionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textfield.autocorrectionType = .no
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        textfield.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)), for: .editingChanged)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AppManager.instance.getDefaultSetting(key: .needUpdate, valueType: Bool.self) ?? true {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(identifier: "\(LoadDataViewController.self)")
            present(controller, animated: true)
        }
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
        self.suggestView?.delegate = self
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
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = (textField.text ?? "")
        let totalWords = text.filter{$0 == " "}.count
        let db = DatabaseManager.default
        
        let search = text.split(separator: " ")
            .suffix(totalWords + 1 > 4 ? 4 : totalWords + 1).joined(separator: " ")
        
        var grams = [GramTable]()
        
        if totalWords == 0 {
            grams = db.find(text: search, from: Gram1.self, column: .previous)
            suggestView?.add(suggestions: grams.map({ $0.previous }))
            return 
        }
        
        grams = getGram(text: search, count: totalWords > 4 ? 4 : totalWords)
        
        suggestView?.add(suggestions: grams.map({ $0.current }))
    }
    
    func getGram(text: String, count: Int) -> [GramTable] {
        for i in stride(from: count,through: 0,by: -1) {
            let search = text.split(separator: " ")
                .suffix(count > 4 ? 4 : count).joined(separator: " ")
            
            let grams = DatabaseManager.default.find(text: search, from: "Gram\(i)", column: .previous, gramElement: Gram1.self)
            
            if !grams.isEmpty {
                print(grams)
                return grams
            }
        }
        
        return []
    }
}


extension ViewController: SuggestionViewDelegate {
    func suggestionView(_ suggestionView: SuggestionView, didSelectSuggestion suggestion: String) {
        if (textfield.text ?? "").filter{ $0 == " " }.count == 0 {
            textfield.text = suggestion
            return
        }
        
        textfield.text?.append(suggestion)
    }
}
