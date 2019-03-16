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
    
    
    var questionsAsked = 0
    var correctQuestions = 0
    var indexOfSelectedQuestion = 0
    var timePerQuestion = 15
    
    
    var gameSound: SystemSoundID = 0
    var correctGameSound: SystemSoundID = 0
    var wrongGameSound: SystemSoundID = 0
    
    var questions = Questions().trivia
    
    var timer: Timer?
    
//    let trivia: [[String : String]] = [
//        ["Question": "Only female koalas can whistle", "Answer": "False"],
//        ["Question": "Blue whales are technically whales", "Answer": "True"],
//        ["Question": "Camels are cannibalistic", "Answer": "False"],
//        ["Question": "All ducks are birds", "Answer": "True"]
//    ]
    
    // MARK: - Outlets
    
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var responseField: UILabel!
    @IBOutlet var optionButtons: Array<UIButton>?
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var timeDisplay: UILabel!
    
    //let answerButtons = [answerButtonOne, answerButtonTwo, answerButtonThree, answerButtonFour]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadGameStartSound()
        loadCorrectGameSound()
        loadWrongGameSound()
        playGameStartSound()
        displayQuestion()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Helpers
    
    func loadGameStartSound() {
        let path = Bundle.main.path(forResource: "GameSound", ofType: "wav")
        let soundUrl = URL(fileURLWithPath: path!)
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &gameSound)
    }
    
    func loadCorrectGameSound() {
        let path = Bundle.main.path(forResource: "CorrectAnswer", ofType: "wav")
        let soundUrl = URL(fileURLWithPath: path!)
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &correctGameSound)
    }
    
    func loadWrongGameSound() {
        let path = Bundle.main.path(forResource: "WrongAnswer", ofType: "wav")
        let soundUrl = URL(fileURLWithPath: path!)
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &wrongGameSound)
    }
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
    
    func displayQuestion() {
        
        
        guard let optionButtons = optionButtons else { fatalError("Option buttons not available") }
        
        for i in 0..<optionButtons.count {
            optionButtons[i].isEnabled = true
        }
        //        answerButtonTwo.isHidden = true
        //        answerButtonThree.isHidden = true
        //        answerButtonFour.isHidden = true
        
        timePerQuestion = 15
        resetTimer()
        
        indexOfSelectedQuestion = GKRandomSource.sharedRandom().nextInt(upperBound: questions.count)
        
        if questions.count > 0 {
            var questionDictionary = questions[indexOfSelectedQuestion]
        
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
        // Hide the answer uttons
//        answerButtonOne.isHidden = true
//        answerButtonTwo.isHidden = true
//        answerButtonThree.isHidden = true
//        answerButtonFour.isHidden = true
        
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
 
    @objc func startTimer() {
        timePerQuestion -= 1
        timeDisplay.text = "\(timePerQuestion)s"
        
        if timePerQuestion == 6 {
            timeDisplay.textColor = UIColor(red: 253/255.0, green: 162/255.0, blue: 104/255.0, alpha: 1.0)
        }
        
        // Stop The Timer
        if timePerQuestion == 0 {
            guard let optionButtons = optionButtons else { fatalError("Option buttons not available") }
            let selectedQuestionDict = questions[indexOfSelectedQuestion]
            guard let correctAnswer = selectedQuestionDict["Answer"] as? String else { fatalError("Error: Answer does not exit!") }

            for button in optionButtons {
                if button.currentTitle == correctAnswer {
                    button.layer.borderWidth = 2.0
                    button.layer.borderColor = UIColor(red: 116/255.0, green: 244/255.0, blue: 66/255.0, alpha: 1.0).cgColor
                }
            }
            
            questionsAsked += 1
            timePerQuestion = 15
            pauseTimer(for: 2)
            loadNextRound(delay: 2)
            print("Switched Round!")
        }
    }
    
    // MARK: - Actions
    
    @IBAction func checkAnswer(_ sender: UIButton) {
        // Increment the questions asked counter
        questionsAsked += 1
        
        guard let optionButtons = optionButtons else { fatalError("Option buttons not available") }
        
        for i in 0..<optionButtons.count {
            optionButtons[i].isEnabled = false
        }
        
        
        if questions.count > 0 {
            let selectedQuestionDict = questions[indexOfSelectedQuestion]
        
            guard let correctAnswer = selectedQuestionDict["Answer"] as? String else { fatalError("Error: Answer does not exit!") }
            guard let question = selectedQuestionDict["Question"] as? String else { fatalError("Error: Answer does not exit!") }
            
            questions.removeAll { element in
                 guard let questionToBeRemoved = element["Question"] as? String else { fatalError("Question does not exist!") }
                 return questionToBeRemoved == question
            }

            if (correctAnswer == sender.currentTitle) {
                AudioServicesPlaySystemSound(correctGameSound)
                correctQuestions += 1
                sender.layer.borderWidth = 2.0
                responseField.textColor = UIColor(red: 21/255.0, green: 147/255.0, blue: 135/255.0, alpha: 1.0)
                sender.layer.borderColor = UIColor(red: 21/255.0, green: 147/255.0, blue: 135/255.0, alpha: 1.0).cgColor
                responseField.text = "Correct!"
            } else {
                AudioServicesPlaySystemSound(wrongGameSound)
                for button in optionButtons {
                    if button.currentTitle == correctAnswer {
                        button.layer.borderWidth = 2.0
                        button.layer.borderColor = UIColor(red: 116/255.0, green: 244/255.0, blue: 66/255.0, alpha: 1.0).cgColor
                    }
                }
                sender.layer.borderWidth = 2.0
                sender.layer.borderColor = UIColor(red: 253/255.0, green: 162/255.0, blue: 104/255.0, alpha: 1.0).cgColor
                responseField.textColor = UIColor(red: 253/255.0, green: 162/255.0, blue: 104/255.0, alpha: 1.0)
                responseField.text = "Sorry, wrong answer!"
            }
            loadNextRound(delay: 2)
        }
    }
    
    
    @IBAction func playAgain(_ sender: UIButton) {
        // Show the answer buttons
//        answerButtonOne.isHidden = false
//        answerButtonTwo.isHidden = false
//        answerButtonThree.isHidden = false
//        answerButtonFour.isHidden = false
        questions = Questions().trivia
        questionsAsked = 0
        correctQuestions = 0
        nextRound()
    }
    

}

