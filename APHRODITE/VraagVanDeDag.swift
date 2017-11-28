//
//  VraagVanDeDag.swift
//  APHRODITE
//
//  Created by Fhict on 09/06/16.
//  Copyright © 2016 Vincent van der Palen. All rights reserved.
//

import Foundation
class Question: NSObject {
    var question:String?
    var answer:Int?
    var explanation:String?
    var options: [String] = []
    var givenAnswer:String?
    var asked:Bool?
    var image:String?
    var shared:Bool?
    
    init(question:String!, options:[String], answer:Int, explanation:String, givenAnswer:String, asked:Bool, image:String, shared:Bool) {
        self.question = question!
        self.answer = answer
        self.explanation = explanation
        self.options = options
        self.givenAnswer = givenAnswer
        self.asked = false
        self.image = image
        self.shared = false
    }
}