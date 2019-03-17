//
//  GameManager.swift
//  EnhanceQuizStarter
//
//  Created by Lukas Kasakaitis on 17.03.19.
//  Copyright © 2019 Treehouse. All rights reserved.
//

import UIKit

class GameManager {
    
    // Properties
    let questionsPerRound: Int
    let questions = Questions()
    let colors = Colors()
    let numberOfQuestions: Int
    
    var sounds = Sounds()
    var gameQuestions = [Question]()
    var questionsAsked: Int = 0
    var correctQuestions: Int = 0
    var timer: Timer?
    var timePerQuestion: Int
    
    // UI Elements
    var questionField: UILabel!
    var responseField: UILabel!
    var optionButtons: Array<UIButton>?
    var playAgainButton: UIButton!
    var timeDisplay: UILabel!
    
    init(questionsPerRound: Int, numberOfQuestions: Int, timePerQuestion: Int, questionField: UILabel, responseField: UILabel, optionButtons: [UIButton], playAgainButton: UIButton, timeDisplay: UILabel) {
        self.questionsPerRound = questionsPerRound
        self.numberOfQuestions = numberOfQuestions
        self.timePerQuestion = timePerQuestion
        self.gameQuestions = getQuestions()
        self.questionField = questionField
        self.responseField = responseField
        self.optionButtons = optionButtons
        self.playAgainButton = playAgainButton
        self.timeDisplay = timeDisplay
    }
    
    private func getQuestions() -> [Question] {
        var gameQuestions = [Question]()
        var questions = self.questions.trivia
        questions.shuffle()
        
        if self.numberOfQuestions > questions.count { return questions }
        
        for i in 0..<self.numberOfQuestions {
            gameQuestions.append(questions[i])
        }
        
        return gameQuestions
    }
    
    public func displayQuestion() {
        
        if questionsAsked == gameQuestions.count {
            displayScore(playAgainButton: playAgainButton, timeDisplay: timeDisplay, questionField: questionField)
            return
        }
        
        guard let optionButtons = optionButtons else { fatalError("Option buttons not available") }
        
        for button in optionButtons {
            button.isEnabled = true
        }
        
        timePerQuestion = 15
        resetTimer()
        
        if gameQuestions.count > 0 {
            let questionDictionary = gameQuestions[questionsAsked]
            let options = questionDictionary.options
            
            for button in optionButtons {
                button.isHidden = true
            }
            
            for i in 0..<options.count {
                optionButtons[i].setTitle(options[i], for: .normal)
                optionButtons[i].isHidden = false
            }
            
            let question = questionDictionary.question
            
            questionField.text = question
            playAgainButton.isHidden = true
        } else {
            displayScore(playAgainButton: playAgainButton, timeDisplay: timeDisplay, questionField: questionField)
        }
        
    }
    
    
    private func nextRound() {
        if questionsAsked == questionsPerRound {
            // Game is over
            displayScore(playAgainButton: playAgainButton, timeDisplay: timeDisplay, questionField: questionField)
        } else {
            // Continue game
            resetButtons()
            displayQuestion()
        }
    }
    
    private func resetButtons() {
        guard let optionButtons = optionButtons else { fatalError("Option buttons not available") }
        
        for i in 0..<optionButtons.count {
            optionButtons[i].layer.borderWidth = 0
        }
        
        responseField.text = ""
    }
    
    private func loadNextRound(delay seconds: Int) {
        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
        
        // Executes the nextRound method at the dispatch time on the main queue
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.nextRound()
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        timeDisplay.textColor = UIColor.white
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
    }
    
    private func pauseTimer(for seconds: Int) {
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
    
    private func showAnswer() {
        guard let optionButtons = optionButtons else { fatalError("Option buttons not available") }
        let selectedQuestionDict = gameQuestions[questionsAsked]
        
        //guard let correctAnswer = selectedQuestionDict["Answer"] as? String else { fatalError("Error: Answer does not exit!") }
        
        let correctAnswer = selectedQuestionDict.answer
        
        for button in optionButtons {
            if button.currentTitle == correctAnswer {
                button.layer.borderWidth = 2.0
                button.layer.borderColor = colors.lightCorrectGreen.cgColor
            }
        }
    }
    
    @objc private func startTimer() {
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
    
    private func displayScore(playAgainButton: UIButton, timeDisplay: UILabel, questionField: UILabel) {
        // Display play again button
        playAgainButton.isHidden = false
        timer?.invalidate()
        timeDisplay.text = ""
        questionField.text = "Way to go!\nYou got \(correctQuestions) out of \(self.questionsPerRound) correct!"
    }
    
    public func checkAnswer(sender: UIButton) {
        guard let optionButtons = optionButtons else { fatalError("Option buttons not available") }
        
        for button in optionButtons {
            button.isEnabled = false
        }
        
        if gameQuestions.count > 0 {
            
            let selectedQuestionDict = gameQuestions[questionsAsked]
            let correctAnswer = selectedQuestionDict.answer
            
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
    
    public func loadSounds() {
        sounds.loadGameStartSound()
        sounds.loadCorrectGameSound()
        sounds.loadWrongGameSound()
        sounds.playGameStartSound()
    }
    
    public func playAgain() {
        gameQuestions = getQuestions()
        questionsAsked = 0
        correctQuestions = 0
        nextRound()
    }
    
}
