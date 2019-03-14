//
//  Options.swift
//  EnhanceQuizStarter
//
//  Created by Lukas Kasakaitis on 11.03.19.
//  Copyright © 2019 Treehouse. All rights reserved.
//

import Foundation

struct Options {
    
    let optionOne: String
    let optionTwo: String
    let optionThree: String?
    let optionFour: String?
    
    init(optionOne: String, optionTwo: String, optionThree: String?, optionFour: String?) {
        self.optionOne = optionOne
        self.optionTwo = optionTwo
        self.optionThree = optionThree
        self.optionFour = optionFour
    }
    
}
