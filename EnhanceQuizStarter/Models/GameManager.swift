//
//  GameManager.swift
//  EnhanceQuizStarter
//
//  Created by Lukas Kasakaitis on 17.03.19.
//  Copyright © 2019 Treehouse. All rights reserved.
//

class GameManager {
    
    // Properties
    let questionsPerRound: Int
    let questions = Questions()
    let numberOfQuestions: Int
    
    var gameQuestions = [Question]()
    var questionsAsked: Int = 0
    var correctQuestions: Int = 0
    var timePerQuestion: Int
    
    init(questionsPerRound: Int, numberOfQuestions: Int, timePerQuestion: Int) {
        self.questionsPerRound = questionsPerRound
        self.numberOfQuestions = numberOfQuestions
        self.timePerQuestion = timePerQuestion
        self.gameQuestions = getQuestions()
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
    
    public func playAgain() {
        gameQuestions = getQuestions()
        questionsAsked = 0
        correctQuestions = 0
    }
    
}
