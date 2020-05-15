//
//  Kamelott.swift
//  CrazyText
//
//  Created by David Linhares on 14/05/2020.
//  Copyright © 2020 David Linhares. All rights reserved.
//

import Foundation
import CSV
import CSVImporter

struct Kamelott {
    var fileName: String
    var words: String
}

class KamelottAdapter {
    func adapt() throws -> [Kamelott] {
        var array = [Kamelott]()
        guard let path = Bundle.main.path(forResource: "kam", ofType: "csv"),
            let stream = InputStream(fileAtPath: path)
        else {
            throw CSVError.CSVNotFound
        }
        
        
        guard let csv = try? CSVReader(stream: stream, hasHeaderRow: true) else {
            throw CSVError.CSVUnableToRead
        }
        while csv.next() != nil {
            array.append(.init(fileName: csv["TITLE"] ?? "", words: csv["WORDS"] ?? ""))
        }
        
        return array
    }
}
