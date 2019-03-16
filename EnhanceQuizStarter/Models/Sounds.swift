//
//  Sounds.swift
//  EnhanceQuizStarter
//
//  Created by Lukas Kasakaitis on 16.03.19.
//  Copyright © 2019 Treehouse. All rights reserved.
//

import AudioToolbox

struct Sounds {
    
    let startSoundPath = Bundle.main.path(forResource: "GameSound", ofType: "wav")
    let correctSoundPath = Bundle.main.path(forResource: "CorrectAnswer", ofType: "wav")
    let wrongSoundPath = Bundle.main.path(forResource: "WrongAnswer", ofType: "wav")
    var gameSound: SystemSoundID = 0
    var correctGameSound: SystemSoundID = 0
    var wrongGameSound: SystemSoundID = 0
    
    mutating func loadGameStartSound() {
        let soundUrl = URL(fileURLWithPath: startSoundPath!)
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &self.gameSound)
    }
    
    mutating func loadCorrectGameSound() {
        let soundUrl = URL(fileURLWithPath: correctSoundPath!)
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &self.correctGameSound)
    }
    
    mutating func loadWrongGameSound() {
        let soundUrl = URL(fileURLWithPath: wrongSoundPath!)
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &self.wrongGameSound)
    }
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
    
    func playCorrectGameSound() {
        AudioServicesPlaySystemSound(correctGameSound)
    }
    
    func playWrongGameSound() {
        AudioServicesPlaySystemSound(wrongGameSound)
    }
    
}
