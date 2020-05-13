//
//  AppDelegate.swift
//  CrazyText
//
//  Created by David Linhares on 11/05/2020.
//  Copyright © 2020 David Linhares. All rights reserved.
//

import UIKit

struct TestTable: GramTable {
    var id: String = UUID().uuidString
    var previous: String
    var current: String
    var count: Int
    var userWord: Bool
    
    init(id: String, previous: String, current: String, count: Int, userWord: Bool) {
        self.id = id
        self.previous = previous
        self.current = current
        self.userWord = userWord
        self.count = count
    }
    
    init(previous: String, current: String, count: Int, userWord: Bool) {
        self.previous = previous
        self.current = current
        self.userWord = userWord
        self.count = count
    }
    
    func updateCount(value: Int) {
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let res = DatabaseManager.instance.createTable(table: TestTable.self)
        if res {
            DatabaseManager.instance.insert(gram: TestTable(previous: "test", current: "poulet", count: 2, userWord: true))
            var test = DatabaseManager.instance.read(table: TestTable.self)
            print(test)
            DatabaseManager.instance.delete(table: TestTable.self, whereColumn: .userWord, whereValue: 1)
            test = DatabaseManager.instance.read(table: TestTable.self)
            print(test)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

