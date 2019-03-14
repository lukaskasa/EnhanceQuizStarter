//
//  Questions.swift
//  EnhanceQuizStarter
//
//  Created by Lukas Kasakaitis on 10.03.19.
//  Copyright © 2019 Treehouse. All rights reserved.
//

import Foundation
import GameKit

struct Questions {
    
    let trivia: [[String : Any]] = [
        // Options - 3/4
        ["Question": "This was the only US President to serve more than two consecutive terms.",
         "Options": ["George Washington", "Franklin D. Roosevelt", "Woodrow Wilson", "Andrew Jackson"],
         "Answer": "Franklin D. Roosevelt"],
        ["Question": "Which of the following countries has the most residents?",
         "Options": ["Nigeria", "Russia", "Iran", "Vietnam"],
         "Answer": "Nigeria"],
        ["Question": "In what year was the United Nations founded?",
         "Options": ["1918", "1919", "1945", "1954"],
         "Answer": "1945"],
        ["Question": "The Titanic departed from the United Kingdom, where was it supposed to arrive?",
         "Options": ["Paris", "Washington D.C.", "New York City", "Boston"],
         "Answer": "New York City"],
        ["Question": "Which nation produces the most oil?",
         "Options": ["Iran", "Iraq", "Brazil", "Canada"],
         "Answer": "Canada"],
        ["Question": "Which country has most recently won consecutive World Cups in Soccer?",
         "Options": ["Italy", "Brazil", "Argetina", "Spain"],
         "Answer": "Brazil"],
        ["Question": "Which of the following rivers is longest?",
         "Options": ["Yangtze", "Mississippi", "Congo", "Mekong"],
         "Answer": "Mississippi"],
        ["Question": "Which city is the oldest?",
         "Options": ["Mexico City", "Cape Town", "San Juan", "Sydney"],
         "Answer": "Mexico City"],
        ["Question": "Which country was the first to allow women to vote in national elections?",
         "Options": ["Poland", "United States", "Sweden", "Senegal"],
         "Answer": "Poland"],
        ["Question": "Which of these countries won the most medals in the 2012 Summer Games?",
         "Options": ["France", "Germany", "Japan", "Great Britian"],
         "Answer": "Great Britian"]
    ]
    
    func randomQuestion() -> [String : Any] {
        let randomIndex = GKRandomSource.sharedRandom().nextInt(upperBound: trivia.count)
        return trivia[randomIndex]
    }
    
}
