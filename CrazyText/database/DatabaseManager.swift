//
//  DatabaseManagher.swift
//  CrazyText
//
//  Created by David Linhares on 12/05/2020.
//  Copyright © 2020 David Linhares. All rights reserved.
//

import Foundation
import SQLite3

class DatabaseManager {
    private var db: OpaquePointer?
    private static let defaultName = "databse.sqlite"
    static let `default`: DatabaseManager = DatabaseManager(name: defaultName)
    
    init(name: String) {
        self.db = openDatabase(name: name)
    }
    
    func openDatabase(name: String) -> OpaquePointer? {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(name)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
        {
            return nil
        }
        return db!
    }
    
    func createTable<T: GramTable>(table: T.Type) -> Bool {
        var done: Bool
        let createTableString = "CREATE TABLE IF NOT EXISTS \(T.self) (Id VARCHAR(200) PRIMARY KEY,previous VARCHAR(200), current VARCHAR(100), count INTEGER, userWord INTEGER);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            done = sqlite3_step(createTableStatement) == SQLITE_DONE
        } else {
            done = false
        }
        sqlite3_finalize(createTableStatement)
        
        return done
    }
    
    func createKamelottTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS Kamelott (title VARCHAR(200) PRIMARY KEY,words VARCHAR(200));"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("kamelott table created")
            }
        } else {
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func read<T: GramTable>(table: T.Type) -> [T] {
        let queryStatementString = "SELECT * FROM \(T.self);"
        var queryStatement: OpaquePointer? = nil
        var grams: [T] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let previous = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let current = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let count = sqlite3_column_int(queryStatement, 3)
                let userWord: Bool = sqlite3_column_int(queryStatement, 4) == 1
                grams.append(.init(
                    id: id,
                    previous: previous,
                    current: current,
                    count: Int(count),
                    userWord: userWord))
            }
        }
        sqlite3_finalize(queryStatement)
        return grams
    }
    
    func insert<T: GramTable>(gram: T) {
        let insert = "INSERT INTO \(T.self) (\(GramColumn.id), \(GramColumn.previous), \(GramColumn.current), \(GramColumn.count), \(GramColumn.userWord)) VALUES (?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, insert, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, NSString(string: gram.id).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, NSString(string: gram.previous).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, NSString(string: gram.current).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 4, Int32(gram.count))
            sqlite3_bind_int(insertStatement, 5, Int32(gram.userWord ? 1 : 0))
        if sqlite3_step(insertStatement) == SQLITE_DONE {
          print("")
        } else {
          print("Could not insert row.")
        }
        } else {
            print("INSERT statement is not prepared.")
        }
        // 5
        sqlite3_finalize(insertStatement)
    }
    
    func insert<T: GramTable>(gramTable: String, gram: T) {
        let insert = "INSERT INTO \(gramTable) (\(GramColumn.id), \(GramColumn.previous), \(GramColumn.current), \(GramColumn.count), \(GramColumn.userWord)) VALUES (?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, insert, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, NSString(string: gram.id).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, NSString(string: gram.previous).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, NSString(string: gram.current).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 4, Int32(gram.count))
            sqlite3_bind_int(insertStatement, 5, Int32(gram.userWord ? 1 : 0))
        if sqlite3_step(insertStatement) == SQLITE_DONE {
          print("")
        } else {
          print("Could not insert row.")
        }
        } else {
            print("INSERT statement is not prepared.")
        }
        // 5
        sqlite3_finalize(insertStatement)
    }
    
    func find<T: GramTable>(text: String, from table: T.Type, column: GramColumn) -> [T] {
        let queryStatementString = "SELECT * FROM \(T.self) WHERE UPPER(\(column)) like UPPER('\(text)%') ORDER BY COUNT desc LIMIT 4;"
        var queryStatement: OpaquePointer? = nil
        var grams: [T] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let previous = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let current = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let count = sqlite3_column_int(queryStatement, 3)
                let userWord: Bool = sqlite3_column_int(queryStatement, 4) == 1
                grams.append(.init(
                    id: id,
                    previous: previous,
                    current: current,
                    count: Int(count),
                    userWord: userWord))
            }
        }
        sqlite3_finalize(queryStatement)
        return grams
    }
    
    func find<T: GramTable>(text: String, from table: String, column: GramColumn, gramElement: T.Type) -> [T] {
        let queryStatementString = "SELECT * FROM \(table) WHERE UPPER(\(column)) like UPPER('\(text)%') ORDER BY COUNT desc LIMIT 4;"
        var queryStatement: OpaquePointer? = nil
        var grams: [T] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let previous = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let current = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let count = sqlite3_column_int(queryStatement, 3)
                let userWord: Bool = sqlite3_column_int(queryStatement, 4) == 1
                grams.append(.init(
                    id: id,
                    previous: previous,
                    current: current,
                    count: Int(count),
                    userWord: userWord))
            }
        }
        sqlite3_finalize(queryStatement)
        return grams
    }
    
    func findBy2elements<T: GramTable>(text: String, andText: String, from table: String, column: GramColumn, gramElement: T.Type, andcolumn: GramColumn) -> [T] {
        let queryStatementString = "SELECT * FROM \(table) WHERE UPPER(\(column)) like UPPER('\(text)%')AND UPPER(\(andcolumn)) like UPPER('\(andText)%') ORDER BY COUNT desc LIMIT 4;"
        var queryStatement: OpaquePointer? = nil
        var grams: [T] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let previous = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let current = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let count = sqlite3_column_int(queryStatement, 3)
                let userWord: Bool = sqlite3_column_int(queryStatement, 4) == 1
                grams.append(.init(
                    id: id,
                    previous: previous,
                    current: current,
                    count: Int(count),
                    userWord: userWord))
            }
        }
        sqlite3_finalize(queryStatement)
        return grams
    }
    
    func update<T: GramTable>(table: T.Type, column: GramColumn, value: String, whereColumn: GramColumn, whereValue: String) {
        let update = "UPDATE \(T.self) SET \(column.rawValue) = '\(value)' WHERE \(whereColumn) = \(whereValue);"
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, update, -1, &updateStatement, nil) ==
          SQLITE_OK {
        if sqlite3_step(updateStatement) == SQLITE_DONE {
          print("\nSuccessfully updated row.")
        } else {
          print("\nCould not update row.")
        }
        } else {
        print("\nUPDATE statement is not prepared")
        }
        sqlite3_finalize(updateStatement)
    }
    
    func update(table: String, column: GramColumn, value: String, whereColumn: GramColumn, whereValue: String) {
        let update = "UPDATE \(table) SET \(column.rawValue) = '\(value)' WHERE \(whereColumn) = \(whereValue);"
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, update, -1, &updateStatement, nil) ==
          SQLITE_OK {
        if sqlite3_step(updateStatement) == SQLITE_DONE {
          print("\nSuccessfully updated row.")
        } else {
          print("\nCould not update row.")
        }
        } else {
        print("\nUPDATE statement is not prepared")
        }
        sqlite3_finalize(updateStatement)
    }
    
    func update(table: String, column: GramColumn, value: Int, whereColumn: GramColumn, whereValue: String) {
        let update = "UPDATE \(table) SET \(column.rawValue) = \(value) WHERE \(whereColumn) = '\(whereValue)';"
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, update, -1, &updateStatement, nil) ==
          SQLITE_OK {
        if sqlite3_step(updateStatement) == SQLITE_DONE {
          print("\nSuccessfully updated row.")
        } else {
          print("\nCould not update row.")
        }
        } else {
        print("\nUPDATE statement is not prepared")
        }
        sqlite3_finalize(updateStatement)
    }
    
    func insertOrUpdateCorpus(table: String, previous: String, current: String) {
        guard let gram = findBy2elements(text: previous, andText: current, from: table, column: .previous, gramElement: Gram1.self, andcolumn: .current).first else {
            insert(gramTable: table, gram: Gram1(id: UUID().uuidString,
                                                 previous: previous,
                                                 current: current,
                                                 count: 1,
                                                 userWord: true))
            return
        }
        update(table: table, column: .count, value: (gram.count + 1), whereColumn: .id, whereValue: gram.id)
    }
    
    func delete<T: GramTable>(table: T.Type, whereColumn: GramColumn, whereValue: String) {
        let delete = "DELETE FROM \(T.self) WHERE \(whereColumn) = '\(whereValue)';"
        var deleteStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, delete, -1, &deleteStatement, nil) ==
          SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
              print("\nSuccessfully deleted row.")
            } else {
              print("\nCould not delete row.")
            }
        } else {
            print("\nDELETE statement could not be prepared")
        }

        sqlite3_finalize(deleteStatement)
    }
    
    func delete<T: GramTable>(table: T.Type, whereColumn: GramColumn, whereValue: Int) {
        let delete = "DELETE FROM \(T.self) WHERE \(whereColumn) = '\(whereValue)';"
        var deleteStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, delete, -1, &deleteStatement, nil) ==
          SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
              print("\nSuccessfully deleted row.")
            } else {
              print("\nCould not delete row.")
            }
        } else {
            print("\nDELETE statement could not be prepared")
        }

        sqlite3_finalize(deleteStatement)
    }
}
