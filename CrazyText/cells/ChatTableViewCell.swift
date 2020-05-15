//
//  ChatTableViewCell.swift
//  CrazyText
//
//  Created by David Linhares on 14/05/2020.
//  Copyright © 2020 David Linhares. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    let message = UILabel()
    let bubble = UIView()
    private var leading: NSLayoutConstraint!
    private var trailing: NSLayoutConstraint!
    
    var isIncoming: Bool = false {
        didSet {
            bubble.backgroundColor = isIncoming ? .white: .systemBlue
            message.textColor = isIncoming ? .black : .white
            trailing.isActive = isIncoming ? false : true
            leading.isActive = isIncoming ? true : false
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.layer.cornerRadius = 5
        addSubview(bubble)
        
        addSubview(message)
        message.numberOfLines = 0
        message.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [message.topAnchor.constraint(equalTo: topAnchor, constant: 32),
                           message.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
                           message.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
                           bubble.topAnchor.constraint(equalTo: message.topAnchor, constant: -16),
                           bubble.leadingAnchor.constraint(equalTo: message.leadingAnchor, constant: -16),
                           bubble.trailingAnchor.constraint(equalTo: message.trailingAnchor, constant: 16),
                           bubble.bottomAnchor.constraint(equalTo: message.bottomAnchor, constant: 16)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        self.leading = message.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
        leading.isActive = true
        self.trailing = message.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        trailing.isActive = false
    }
    
    func set(message: String, incoming: Bool) {
        let attributedString = NSMutableAttributedString.init(string: message)
        phoneNumber(in: message).forEach {
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: $0)
        }

        email(in: message).forEach {
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: $0)
        }
        
        url(in: message).forEach {
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: $0)
        }
        
        dates(in: message).forEach {
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: $0)
        }
        
        self.message.attributedText = attributedString
        self.isIncoming = incoming
    }
    
    func email(in text: String) -> [NSRange] {
        var ranges = [NSRange]()
        let split = text.split(separator: " ")
        split.forEach {
            if let range = $0.range(of: "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}", options: .regularExpression) {
                ranges.append(NSRange(text.range(of: text[range])!, in: text))
            }
        }
        
        return ranges
    }
    
    func url(in text: String) -> [NSRange] {
        var ranges = [NSRange]()
        let split = text.split(separator: " ")
        split.forEach {
            if let range = $0.range(of: #"/(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/"#, options: .regularExpression) {
                ranges.append(NSRange(text.range(of: text[range])!, in: text))
            }
        }
        
        return ranges
    }
    
    func dates(in text: String) -> [NSRange] {
        var ranges = [NSRange]()
        let split = text.split(separator: " ")
        split.forEach {
            if let range = $0.range(of: "^([0-2][0-9]||3[0-1])/(0[0-9]||1[0-2])/([0-9][0-9])?[0-9][0-9]$", options: .regularExpression) {
                ranges.append(NSRange(text.range(of: text[range])!, in: text))
            }
        }
        
        return ranges
    }
    
    func phoneNumber(in text: String) -> [NSRange] {
        var ranges = [NSRange]()
        let split = text.split(separator: " ")
        split.forEach {
            if let range = $0.range(of: #"^(?:(?:\+|00)33[\s.-]{0,3}(?:\(0\)[\s.-]{0,3})?|0)[1-9](?:(?:[\s.-]?\d{2}){4}|\d{2}(?:[\s.-]?\d{3}){2})$"#, options: .regularExpression) {
                ranges.append(NSRange(text.range(of: text[range])!, in: text))
            }
        }
        
        return ranges
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
