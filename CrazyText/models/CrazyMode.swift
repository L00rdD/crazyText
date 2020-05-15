//
//  CrazyMode.swift
//  CrazyText
//
//  Created by David Linhares on 14/05/2020.
//  Copyright © 2020 David Linhares. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

protocol CrazyMode {
    func doAction(text: String)
}

class KamelottCrazyMode: CrazyMode {
    var localData: [Kamelott] = []
    var player: AVAudioPlayer?
    
    init() {
        guard let data = try? KamelottAdapter().adapt() else { return }
        self.localData = data
    }
    
    func doAction(text: String) {
        let kamelott = localData.first { text.uppercased().contains($0.words.uppercased()) }
        guard let sound = kamelott else { return }
        playSound(fileName: sound.fileName)
    }
    
    func playSound(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }

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
}

class CompanyCrazyMode: CrazyMode {
    var localData: [Company] = []
    var player: AVAudioPlayer?
    
    init() {
        guard let data = try? CompanyAdapter().adapt() else { return }
        self.localData = data
    }
    
    func doAction(text: String) {
        let company = localData.first { text.uppercased().contains($0.words.uppercased()) }
        guard let sound = company else { return }
        playSound(fileName: sound.fileName)
    }
    
    func playSound(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }

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
}
