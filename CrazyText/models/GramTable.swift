//
//  GramTable.swift
//  CrazyText
//
//  Created by David Linhares on 12/05/2020.
//  Copyright © 2020 David Linhares. All rights reserved.
//

import Foundation


protocol GramTable {
    var id: String { get }
    var previous: String { get }
    var current: String { get }
    var count: Int { get }
    var userWord: Bool { get }
    
    init(id: String, previous: String, current: String, count: Int, userWord: Bool   )
    
    func updateCount(value: Int)
}

enum GramColumn: String {
    case id
    case previous
    case current
    case count
    case userWord
}
