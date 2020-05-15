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
    @IBOutlet weak var chat: UITableView!
    @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!
    
    private var messages = [String]()
    private var modeController: ModeViewController!
    private var mode: CrazyMode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textfield.autocorrectionType = .no
        textfield.delegate = self
        
        chat.delegate = self
        chat.dataSource = self
        chat.backgroundColor = UIColor(white: 0.95, alpha: 1)
        chat.register(ChatTableViewCell.self, forCellReuseIdentifier: "chat")
        
        navigationItem.title = "MESSAGES"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onModeActivated)))
        
        modeController = storyboard?.instantiateViewController(identifier: "\(ModeViewController.self)")
        modeController.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        textfield.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)), for: .editingChanged)

    }
    
    @objc func onModeActivated() {
        present(modeController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AppManager.instance.getDefaultSetting(key: .needUpdate, valueType: Bool.self) ?? true {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(identifier: "\(LoadDataViewController.self)")
            present(controller, animated: true)
        }
    }

    private func initSuggestView(keyboardHeight: CGFloat) {
        let viewSize: CGFloat = 40
        let y = self.view.frame.height - textFieldBottomConstraint.constant - viewSize - textfield.frame.height
        self.suggestView = SuggestionView(frame: .init(x: 0, y: y, width: self.view.frame.width, height: viewSize))
        suggestView?.backgroundColor = .white
        self.suggestView?.delegate = self
        self.suggestView?.tag = 1
    }

    func addUSerEntries(text: String, level: Int) {
        if level < 1 { return }
        let split = text.split(separator: " ")
        let previous = split.prefix(level - 1 < 1 ? 1 : level - 1).joined(separator: " ")
        let current: String = String(split.last ?? "")
        
        DatabaseManager.default.insertOrUpdateCorpus(table: "Gram\(level - 1 < 1 ? 1 : level - 1)", previous: previous, current: current)
    }
    
    func getGram(text: String, count: Int) -> (grams: [GramTable], level: Int) {
        for i in stride(from: count,through: 0,by: -1) {
            let search = text.split(separator: " ")
                .suffix(count > 4 ? 4 : count).joined(separator: " ")
            
            let grams = DatabaseManager.default.find(text: search, from: "Gram\(i)", column: .previous, gramElement: Gram1.self)
            
            if !grams.isEmpty {
                print(grams)
                return (grams, i)
            }
        }
        
        return ([], 0)
    }
}

extension ViewController: UITextFieldDelegate {
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.textFieldBottomConstraint.constant = keyboardSize.height
            }
            initSuggestView(keyboardHeight: keyboardSize.height)
            self.view.addSubview(suggestView!)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.suggestView = nil
            self.view.subviews.first { $0.tag == 1 }?.removeFromSuperview()
            if self.textFieldBottomConstraint.constant != 0 {
                self.textFieldBottomConstraint.constant = 0
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
        var level: Int
        
        if totalWords == 0 {
            grams = db.find(text: search, from: Gram1.self, column: .previous)
            suggestView?.add(suggestions: grams.map({ SuggestionWord(id: $0.id,
                                                                     word: $0.previous,
                                                                     count: $0.count,
                                                                     gramLevel: 1) }))
            return
        }
        
        addUSerEntries(text: search, level: totalWords)
        (grams, level) = getGram(text: search, count: totalWords > 4 ? 4 : totalWords)
        
        suggestView?.add(suggestions: grams.map({ SuggestionWord(id: $0.id,
                                                                 word: $0.current,
                                                                 count: $0.count,
                                                                 gramLevel: level) }))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        mode?.doAction(text: text)
        messages.append(text)
        chat.reloadData()
        textfield.resignFirstResponder()
        textField.text = ""
        return true
    }
}


extension ViewController: SuggestionViewDelegate {
    func suggestionView(_ suggestionView: SuggestionView, didSelectSuggestion suggestion: SuggestionWord) {
        if (textfield.text ?? "").filter({ $0 == " " }).count == 0 {
            update(textfield: textfield, with: suggestion, replace: true)
            return
        }
        
        update(textfield: textfield, with: suggestion, replace: false)
    }
    
    private func update(textfield: UITextField, with suggestion: SuggestionWord, replace: Bool) {
        if replace {
            textfield.text = "\(suggestion.word) "
        } else {
            textfield.text?.append("\(suggestion.word) ")
        }
        
        DatabaseManager.default.update(table: "Gram\(suggestion.gramLevel)",
            column: .count,
            value: (suggestion.count + 1),
            whereColumn: .id,
            whereValue: suggestion.id)
        textFieldDidChange(textfield)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =  tableView.dequeueReusableCell(withIdentifier: "chat", for: indexPath) as? ChatTableViewCell else {
            return .init()
        }
        
        cell.set(message: messages[indexPath.row], incoming: indexPath.row % 2 == 0)
        
        return cell
    }
}

extension ViewController: ModeViewControllerDelegate {
    func modeViewController(_ modeViewController: ModeViewController, didSelect mode: ModeViewController.Mode) {
        switch mode {
        case .kamelott:
            self.mode = KamelottCrazyMode()
            let imageView = UIImageView(image: .init(imageLiteralResourceName: "kamelott"))
            imageView.contentMode = .scaleAspectFit
            self.chat.backgroundView = imageView
        case .none:
            self.mode = nil
            self.chat.backgroundView = UIView()
        }
    }
}
