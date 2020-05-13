//
//  SuggestionView.swift
//  CrazyText
//
//  Created by David Linhares on 11/05/2020.
//  Copyright © 2020 David Linhares. All rights reserved.
//

import UIKit

protocol SuggestionViewDelegate {
    func suggestionView(_ suggestionView: SuggestionView, didSelectSuggestion suggestion: String)
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
    
    func add(suggestion: String) {
        let label = UILabel()
        label.text = suggestion
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SuggestionView.didTouch(_:))))
        stackView.addArrangedSubview(label)
    }
    
    @objc func didTouch(_ gesture: UITapGestureRecognizer) {
        let label = gesture.view as? UILabel
        delegate?.suggestionView(self, didSelectSuggestion: label?.text ?? "")
    }
    
    func add(suggestions: [String]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        suggestions.forEach { add(suggestion: $0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
