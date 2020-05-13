//
//  SuggestionView.swift
//  CrazyText
//
//  Created by David Linhares on 11/05/2020.
//  Copyright © 2020 David Linhares. All rights reserved.
//

import UIKit

class SuggestionView: UIView {
    var stackView: UIStackView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initCustomView()
    }
    
    private func initCustomView() {
        self.stackView = UIStackView(frame: .init(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.width, height: self.bounds.height))
        self.addSubview(stackView)
        self.stackView.distribution = .fillEqually
    }
    
    func add(suggestion: String) {
        let label = UILabel()
        label.text = suggestion
        label.textAlignment = .center
        stackView.addArrangedSubview(label)
    }
    
    func add(suggestions: [String]) {
        suggestions.forEach { add(suggestion: $0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
