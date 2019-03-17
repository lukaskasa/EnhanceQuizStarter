//
//  ViewController.swift
//  EnhanceQuizStarter
//
//  Created by Pasan Premaratne on 3/12/18.
//  Copyright © 2018 Treehouse. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet var optionButtons: Array<UIButton>?
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: - Properties
    let timePerQuestion = 15
    let colors = Colors()
    var sounds = Sounds()
    var gameManager = GameManager(questionsPerRound: 4, numberOfQuestions: 4, timePerQuestion: 15)
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sounds.loadGameStartSound()
        sounds.loadCorrectGameSound()
        sounds.loadWrongGameSound()
        sounds.playGameStartSound()
        
        displayQuestion()
    }
    
    // To hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Helpers
    
    /**
     Shows the question on screen with correct number of buttons
     
     - Returns: Void
     */
    func displayQuestion() {
        if gameManager.questionsAsked == gameManager.gameQuestions.count {
            displayScore()
            return
        }
        
        guard let optionButtons = optionButtons else { fatalError("Option buttons not available") }
        
        for button in optionButtons {
            button.isEnabled = true
        }
        
        gameManager.timePerQuestion = timePerQuestion
        resetTimer()
        
        if gameManager.gameQuestions.count > 0 {
            let options = gameManager.gameQuestions[gameManager.questionsAsked].options
            let question = gameManager.gameQuestions[gameManager.questionsAsked].question
            
            // Hide buttons - in order to display correct number of buttons for the next round
            for button in optionButtons {
                button.isHidden = true
            }
            
            // Show correct number of buttons for the question
            for (index, question) in options.enumerated() {
                optionButtons[index].setTitle(question, for: .normal)
                optionButtons[index].isHidden = false
            }
            
            questionLabel.text = question
            playAgainButton.isHidden = true
        } else {
            displayScore()
        }
    }
    
    /**
     Reset timer.
     
     - Returns: Void
     */
    func resetTimer() {
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
        timeLabel.textColor = UIColor.white
    }
    
    /**
     Start the timer.
     
     - Returns: Void
     */
    @objc func startTimer() {
        gameManager.timePerQuestion -= 1
        timeLabel.text = "\(gameManager.timePerQuestion)s"
        
        if gameManager.timePerQuestion == 6 {
            timeLabel.textColor = colors.incorrectRed
        }
        
        // Stop The Timer
        if gameManager.timePerQuestion == 0 {
            
            sounds.playWrongGameSound()
            showAnswer()
            pauseTimer(for: 2)
            loadNextRound(delay: 2)
            
            gameManager.questionsAsked += 1
            gameManager.timePerQuestion = timePerQuestion
        }
    }
    
    /**
     Pause timer.
     
     - Returns: Void
     */
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
    
    /**
     Switch to the next round.
     
     - Returns: Void
     */
    func nextRound() {
        if gameManager.questionsAsked == gameManager.questionsPerRound {
            // Game is over
            displayScore()
        } else {
            // Continue game
            resetButtons()
            displayQuestion()
        }
    }
    
    /**
     Reset the button styles by removing the border for the next round.
     
     - Returns: Void
     */
    func resetButtons() {
        guard let optionButtons = optionButtons else { fatalError("Option buttons not available") }
        
        for i in 0..<optionButtons.count {
            optionButtons[i].layer.borderWidth = 0
        }
        
        responseLabel.text = ""
    }
    
    /**
     Loads next round (question) with a delay.
     
     - Parameter seconds: Amount of seconds to delay.
     
     - Returns: Void.
     */
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
    
    /**
     Show answer by coloring the button border green.
     
     - Returns: Void
     */
    func showAnswer() {
        guard let optionButtons = optionButtons else { fatalError("Option buttons not available") }
        let correctAnswer = gameManager.gameQuestions[gameManager.questionsAsked].answer
        
        for button in optionButtons {
            if button.currentTitle == correctAnswer {
                button.layer.borderWidth = 2.0
                button.layer.borderColor = colors.lightCorrectGreen.cgColor
            }
        }
    }
    
    /**
     Display final Score of the Game
     
     - Returns: Void
     */
    func displayScore() {
        timer?.invalidate()
        // Display play again button
        playAgainButton.isHidden = false
        timeLabel.text = ""
        questionLabel.text = "Way to go!\nYou got \(gameManager.correctQuestions) out of \(gameManager.questionsPerRound) correct!"
    }
    
    // MARK: - Actions
    @IBAction func checkAnswer(_ sender: UIButton) {
        
        guard let optionButtons = optionButtons else { fatalError("Option buttons not available") }
        
        // Enable all buttons
        for button in optionButtons {
            button.isEnabled = false
        }
        
        let correctAnswer = gameManager.gameQuestions[gameManager.questionsAsked].answer
        if (correctAnswer == sender.currentTitle) {
            sounds.playCorrectGameSound()
            gameManager.correctQuestions += 1
    
            sender.layer.borderWidth = 2.0
            responseLabel.textColor = colors.correctGreen
            sender.layer.borderColor = colors.correctGreen.cgColor
            responseLabel.text = "Correct!"
            
        } else {
            sounds.playWrongGameSound()
            showAnswer()
            
            sender.layer.borderWidth = 2.0
            sender.layer.borderColor = colors.incorrectRed.cgColor
            responseLabel.textColor = colors.incorrectRed
            responseLabel.text = "Sorry, wrong answer!"
        }
        
        loadNextRound(delay: 2)
    
        // Increment the questions asked counter
        gameManager.questionsAsked += 1
    }
    
    @IBAction func playAgain(_ sender: UIButton) {
        gameManager.playAgain()
        sounds.playGameStartSound()
        nextRound()
    }
    
}

