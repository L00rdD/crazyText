//
//  LoadDataViewController.swift
//  CrazyText
//
//  Created by David Linhares on 13/05/2020.
//  Copyright © 2020 David Linhares. All rights reserved.
//

import UIKit
import AVFoundation

class LoadDataViewController: UIViewController {

    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var singer: UIImageView!
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.startAnimating()
        info.text = "chargement des données"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setCorpus()
        let dataset = Int(AppManager.instance.getPlistValue(withName: "dataset") ?? "0")
        AppManager.instance.setDefaultSetting(key: .datasetVersion, value: dataset)
        AppManager.instance.setDefaultSetting(key: .needUpdate, value: false)
        dismiss(animated: true)
    }
    
    @objc func sing() {
        guard let url = Bundle.main.url(forResource: "a_la_volette1", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func setCorpus() {
        let _ = updateTable(gram: Gram1.self, datasetName: .datasetDefault1)
        let _ = updateTable(gram: Gram2.self, datasetName: .datasetDefault2)
        let _ = updateTable(gram: Gram3.self, datasetName: .datasetDefault3)
        let _ = updateTable(gram: Gram4.self, datasetName: .datasetDefault4)
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
