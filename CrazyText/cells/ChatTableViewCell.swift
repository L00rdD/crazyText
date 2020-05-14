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
        self.message.text = message
        self.isIncoming = incoming
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
