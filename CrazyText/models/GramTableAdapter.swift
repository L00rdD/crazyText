//
//  GramTableAdapter.swift
//  CrazyText
//
//  Created by David Linhares on 13/05/2020.
//  Copyright © 2020 David Linhares. All rights reserved.
//

import Foundation
import CSV

enum CSVError: Error {
    case CSVNotFound
    case CSVUnableToRead
}

enum GramCSVFiles: String {
    case datasetDefault1 = "dataset_default_1"
    case datasetDefault2 = "dataset_default_2"
    case datasetDefault3 = "dataset_default_3"
    case datasetDefault4 = "dataset_default_4"
}

class GramTableAdapter<T: GramTable> {
    func adapt(csvName: String) throws -> [T] {
        var array = [T]()
        guard let path = Bundle.main.path(forResource: csvName, ofType: "csv"),
            let stream = InputStream(fileAtPath: path)
        else {
            throw CSVError.CSVNotFound
        }
        
        
        guard let csv = try? CSVReader(stream: stream, hasHeaderRow: true) else {
            throw CSVError.CSVUnableToRead
        }
        while csv.next() != nil {
            array.append(.init(id: UUID().uuidString,
                               previous: csv["PREVIOUS"] ?? "",
                               current: csv["CURRENT"] ?? "",
                               count: Int(csv["COUNTER"] ?? "0") ?? 0,
                               userWord: false))
        }
        
        return array
    }
}
