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
    
    // MARK: - Properties
    
    let questionsPerRound = 4
    let questions = Questions()
    let colors = Colors()
    var sounds = Sounds()
    var questionsAsked = 0
    var correctQuestions = 0
    var indexOfSelectedQuestion = 0
    var timePerQuestion = 15
    var gameQuestions = [[String : Any]]()
    var timer: Timer?
    
    // MARK: - Outlets
    
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var responseField: UILabel!
    @IBOutlet var optionButtons: Array<UIButton>?
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var timeDisplay: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameQuestions = questions.getQuestions(numberOfQuestions: questionsPerRound)

        sounds.loadGameStartSound()
        sounds.loadCorrectGameSound()
        sounds.loadWrongGameSound()
        sounds.playGameStartSound()
        
        displayQuestion()
    }
    
    /// To hide the statusBar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Helpers
    
    func displayQuestion() {
        
        guard let optionButtons = optionButtons else { fatalError("Option buttons not available") }
        
        for i in 0..<optionButtons.count {
            optionButtons[i].isEnabled = true
        }
        
        timePerQuestion = 15
        resetTimer()
        
        if gameQuestions.count > 0 {
            var questionDictionary = gameQuestions[questionsAsked]
        
            guard let options = questionDictionary["Options"] as? [String] else { fatalError("Options do not exist!") }
            
            for i in 0..<optionButtons.count {
                optionButtons[i].isHidden = true
            }
            
            for i in 0..<options.count {
                optionButtons[i].setTitle(options[i], for: .normal)
                optionButtons[i].isHidden = false
            }
            
            guard let question = questionDictionary["Question"] as? String else { fatalError("Question does not exist!") }
            questionField.text = question
            playAgainButton.isHidden = true
        } else {
            displayScore()
        }
        
    }
    
    func displayScore() {
        // Display play again button
        playAgainButton.isHidden = false
        timer?.invalidate()
        timeDisplay.text = ""
        questionField.text = "Way to go!\nYou got \(correctQuestions) out of \(questionsPerRound) correct!"
    }
    
    func nextRound() {
        if questionsAsked == questionsPerRound {
            // Game is over
            displayScore()
        } else {
            // Continue game
            resetButtons()
            displayQuestion()
        }
    }
    
    func resetButtons() {
        guard let optionButtons = optionButtons else { fatalError("Option buttons not available") }
        
        for i in 0..<optionButtons.count {
            optionButtons[i].layer.borderWidth = 0
        }
        
        responseField.text = ""
    }
    
    func loadNextRound(delay seconds: Int) {
        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
        
        // Executes the nextRound method at the dispatch time on the main queue
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.nextRound()
        }
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = nil
        timeDisplay.textColor = UIColor.white
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
    }
    
    func pauseTimer(for seconds: Int) {
        timer?.invalidate()
        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
        
        // Executes the nextRound method at the dispatch time on the main queue
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.timer?.fire()
        }
    }
    
    func showAnswer() {
        guard let optionButtons = optionButtons else { fatalError("Option buttons not available") }
        let selectedQuestionDict = gameQuestions[questionsAsked]
        guard let correctAnswer = selectedQuestionDict["Answer"] as? String else { fatalError("Error: Answer does not exit!") }
        
        for button in optionButtons {
            if button.currentTitle == correctAnswer {
                button.layer.borderWidth = 2.0
                button.layer.borderColor = colors.lightCorrectGreen.cgColor
            }
        }
    }
 
    @objc func startTimer() {
        timePerQuestion -= 1
        timeDisplay.text = "\(timePerQuestion)s"
        
        if timePerQuestion == 6 {
            timeDisplay.textColor = colors.incorrectRed
        }
        
        // Stop The Timer
        if timePerQuestion == 0 {
            sounds.playWrongGameSound()
            showAnswer()
            questionsAsked += 1
            timePerQuestion = 15
            pauseTimer(for: 2)
            loadNextRound(delay: 2)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func checkAnswer(_ sender: UIButton) {
        
        guard let optionButtons = optionButtons else { fatalError("Option buttons not available") }
        
        for i in 0..<optionButtons.count {
            optionButtons[i].isEnabled = false
        }
        
        if gameQuestions.count > 0 {
            let selectedQuestionDict = gameQuestions[questionsAsked]
        
            guard let correctAnswer = selectedQuestionDict["Answer"] as? String else { fatalError("Error: Answer does not exit!") }

            if (correctAnswer == sender.currentTitle) {
                sounds.playCorrectGameSound()
                correctQuestions += 1
                sender.layer.borderWidth = 2.0
                responseField.textColor = colors.correctGreen
                sender.layer.borderColor = colors.correctGreen.cgColor
                responseField.text = "Correct!"
            } else {
                sounds.playWrongGameSound()
                showAnswer()
                sender.layer.borderWidth = 2.0
                sender.layer.borderColor = colors.incorrectRed.cgColor
                responseField.textColor = colors.incorrectRed
                responseField.text = "Sorry, wrong answer!"
            }
            loadNextRound(delay: 2)
        }
        
        // Increment the questions asked counter
        questionsAsked += 1
    }
    
    
    @IBAction func playAgain(_ sender: UIButton) {
        gameQuestions = questions.getQuestions(numberOfQuestions: questionsPerRound)
        questionsAsked = 0
        correctQuestions = 0
        nextRound()
    }
    
}

