//
//  LoadDataViewController.swift
//  CrazyText
//
//  Created by David Linhares on 13/05/2020.
//  Copyright © 2020 David Linhares. All rights reserved.
//

import UIKit

class LoadDataViewController: UIViewController {

    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.startAnimating()
        info.text = "chargement des données"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let _ = updateTable(gram: Gram1.self, datasetName: .datasetDefault1)
        let _ = updateTable(gram: Gram2.self, datasetName: .datasetDefault2)
        let _ = updateTable(gram: Gram3.self, datasetName: .datasetDefault3)
        let _ = updateTable(gram: Gram4.self, datasetName: .datasetDefault4)
        let dataset = Int(AppManager.instance.getPlistValue(withName: "dataset") ?? "0")
        AppManager.instance.setDefaultSetting(key: .datasetVersion, value: dataset)
        AppManager.instance.setDefaultSetting(key: .needUpdate, value: false)
        dismiss(animated: true)
    }
    
    private func updateTable<T: GramTable>(gram: T.Type, datasetName dataset: GramCSVFiles) -> Bool {
        let db = DatabaseManager.default
        let _ = db.createTable(table: gram)
        db.delete(table: gram, whereColumn: .userWord, whereValue: 0)
        guard let grams = try? GramTableAdapter<T>().adapt(csvName: dataset.rawValue) else {
            return false
        }
        
        grams.forEach { db.insert(gram: $0) }
        
        return true
    }
}
