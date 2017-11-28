//
//  InteressesVragen.swift
//  APHRODITE
//
//  Created by Fhict on 09/06/16.
//  Copyright © 2016 Vincent van der Palen. All rights reserved.
//

import Foundation


class InteresseVragen: NSObject
{
    var subject: String!
    var answer: String!
    var title: String!

    init(Subject: String, Title: String, Answer: String)
    {
        self.subject = Subject
        self.title = Title
        self.answer = Answer
    }
}