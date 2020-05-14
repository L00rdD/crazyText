//
//  SuggestionView.swift
//  CrazyText
//
//  Created by David Linhares on 11/05/2020.
//  Copyright © 2020 David Linhares. All rights reserved.
//

import UIKit

struct SuggestionWord {
    var id: String
    var word: String
    var count: Int
    var gramLevel: Int
}

protocol SuggestionViewDelegate {
    func suggestionView(_ suggestionView: SuggestionView, didSelectSuggestion suggestion: SuggestionWord)
}

class SuggestionView: UIView {
    var stackView: UIStackView!
    var delegate: SuggestionViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initCustomView()
    }
    
    private func initCustomView() {
        self.stackView = UIStackView(frame: .init(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.width, height: self.bounds.height))
        self.addSubview(stackView)
        stackView.isUserInteractionEnabled = true
        self.stackView.distribution = .fillEqually
    }
    
    func add(suggestion: SuggestionWord) {
        let label = SuggestionLabel()
        label.text = suggestion.word
        label.suggestionWord = suggestion
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor.gray.cgColor
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SuggestionView.didTouch(_:))))
        stackView.addArrangedSubview(label)
    }
    
    @objc func didTouch(_ gesture: UITapGestureRecognizer) {
        let label = gesture.view as? SuggestionLabel
        delegate?.suggestionView(self, didSelectSuggestion: label?.suggestionWord ?? .init(id: "", word: "", count: 0, gramLevel: 1))
    }
    
    func add(suggestions: [SuggestionWord]) {
        stackView.layer.borderWidth = 0.5
        stackView.layer.borderColor = UIColor.gray.cgColor
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        suggestions.forEach { add(suggestion: $0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
