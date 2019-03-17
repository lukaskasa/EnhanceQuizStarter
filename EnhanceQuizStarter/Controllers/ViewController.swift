//
//  ViewController.swift
//  EnhanceQuizStarter
//
//  Created by Pasan Premaratne on 3/12/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

import UIKit
import GameKit
import AudioToolbox

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var responseField: UILabel!
    @IBOutlet var optionButtons: Array<UIButton>?
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var timeDisplay: UILabel!
    
    var gameManager: GameManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameManager = GameManager(questionsPerRound: 4, numberOfQuestions: 4, timePerQuestion: 15, questionField: questionField, responseField: responseField, optionButtons: optionButtons!, playAgainButton: playAgainButton, timeDisplay: timeDisplay)
        
        gameManager?.loadSounds()
        
        gameManager?.displayQuestion()
    }
    
    // To hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Actions
    @IBAction func checkAnswer(_ sender: UIButton) {
        gameManager?.checkAnswer(sender: sender)
    }
    
    @IBAction func playAgain(_ sender: UIButton) {
        gameManager?.playAgain()
    }
    
}

