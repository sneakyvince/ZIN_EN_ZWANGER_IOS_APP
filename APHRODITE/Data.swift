//
//  Data.swift
//  APHRODITE
//
//  Created by Fhict on 10/06/16.
//  Copyright © 2016 Vincent van der Palen. All rights reserved.
//

import Foundation


class Data: NSObject
{
    var questions = [Question]()
    var test = "test"
    var delegate:updateDelegate?
    
    init(Delegate:updateDelegate)
    {
        super.init()
        self.delegate = Delegate
        self.loadJsonDataQuestionOfTheDay()
    }
    
    func loadJsonDataQuestionOfTheDay()
    {
        let url = NSURL(string: "http://i323074.iris.fhict.nl/aphrodite/vraag_van_de_dag.json")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request){(data, response, error) -> Void in
            do
            {
                if let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                {
                    self.parseJsonDataQuestionOfTheDay(jsonObject)
                }
            }
            catch
            {
                print("Error parsing JSON data!")
                
            }
        }
        dataTask.resume();
        
    }
    
    
    func parseJsonDataQuestionOfTheDay(jsonObject: AnyObject) {
        if let jsonData = jsonObject as? NSArray
        {
            for item in jsonData {
                let newQuestion = Question(
                    question: item.objectForKey("vraag") as? String,
                    options: item.objectForKey("antwoorden") as! Array,
                    answer: item.objectForKey("goede_antwoord") as! Int,
                    explanation: item.objectForKey("Uitleg") as! String,
                    givenAnswer: "",
                    asked: false,
                    image: "spermcell",
                    shared: false
                )
                questions.append(newQuestion)
            }
            print(questions[5].question)
            print("hoi")
            //delegate!.updateQuestion(); JSON
        }
        
    }

    

}