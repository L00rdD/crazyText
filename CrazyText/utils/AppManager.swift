//
//  AppManager.swift
//  CrazyText
//
//  Created by David Linhares on 13/05/2020.
//  Copyright © 2020 David Linhares. All rights reserved.
//

import Foundation

class AppManager {
    enum Setting: String {
        case datasetVersion
        case needUpdate
    }
    static let instance = AppManager()
    
    private init() {}
    
    func getPlistValue(withName name: String) -> String? {
        var resourceFileDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
           resourceFileDictionary = NSDictionary(contentsOfFile: path)
        }

        if let resourceFileDictionaryContent = resourceFileDictionary {
           return resourceFileDictionaryContent[name] as? String
        }
        
        return nil
    }
    
    func setDefaultSetting<T>(key: AppManager.Setting, value: T) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key.rawValue)
    }
    
    func getDefaultSetting<T>(key: AppManager.Setting, valueType: T.Type) -> T? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: key.rawValue) as? T
    }
}
