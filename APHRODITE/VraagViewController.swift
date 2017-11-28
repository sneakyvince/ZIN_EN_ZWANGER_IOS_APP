//
//  VraagViewController.swift
//  APHRODITE
//
//  Created by Vincent van der Palen on 03-06-16.
//  Copyright © 2016 Vincent van der Palen. All rights reserved.
//

import UIKit

//class VraagViewController: UIViewController, updateDelegate {
class VraagViewController: UIViewController {
    
    var questions = [Question]()
    var questionsHardcoded = [Question]()
    var DVC: AntwoordViewController!
    
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var btnAnswer1: UIButton!
    @IBOutlet weak var btnAnswer2: UIButton!
    @IBOutlet weak var imgQuestion: UIImageView!
    
    //var data:Data? JSON
    var random: UInt32!
    //var status = false
    var askedQuestion: Question!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        random = arc4random_uniform(7)
        loadQuestions()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        for item in questionsHardcoded {
            if (item.asked == false) { //check if question is asked already
                //status = true
                self.lblQuestion?.text = item.question //update question label
                self.btnAnswer1.setTitle(item.options[0], forState: .Normal) //update button answer 1
                self.btnAnswer2.setTitle(item.options[1], forState: .Normal) //update button answer 2
                askedQuestion = item
                imgQuestion.image = UIImage(named: item.image!)
            }
        }
        //JSON
//        if(questions.count > 0) {
//            self.lblQuestion?.text = data!.questions[Int(random)].question
//            self.btnAnswer1.setTitle(data!.questions[Int(random)].options[0], forState: .Normal)
//            self.btnAnswer2.setTitle(data!.questions[Int(random)].options[1], forState: .Normal)
//        }
    }
    
    //JSON
//    func updateQuestion() {
//        self.lblQuestion?.text = data!.questions[Int(random)].question
//        self.btnAnswer1.setTitle(data!.questions[Int(random)].options[0], forState: .Normal)
//        self.btnAnswer2.setTitle(data!.questions[Int(random)].options[1], forState: .Normal)
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        DVC = segue.destinationViewController as? AntwoordViewController
    
        if(segue.identifier == "answer1")
        {
            DVC!.answer = askedQuestion.options[0]
            askedQuestion.givenAnswer = askedQuestion.options[0]
        }
        else if(segue.identifier == "answer2")
        {
            DVC!.answer = askedQuestion.options[1]
            askedQuestion.givenAnswer = askedQuestion.options[1]
        }
        
        checkDataAndSend()
    }
    
    func checkDataAndSend(){
        DVC!.explanation = askedQuestion.explanation!
        askedQuestion.asked = true //update status
        DVC!.askedQuestion = askedQuestion
        
        if askedQuestion.answer == 3{
            DVC!.correct = "Beide!"
        }
        else if askedQuestion.options[0] == askedQuestion.options[askedQuestion.answer!] {
            DVC!.correct = "Dat is juist!"
        }
        else {
            DVC!.correct = "Helaas..."
        }
    }
    
    func loadQuestions() {
        let newQuestion = Question(
            question: "Wat heeft een remmend effect op de kwaliteit van sperma?",
            options: ["Glijmiddelen", "Speeksel"],
            answer: 3,
            explanation: "Door onvoldoende opwinding kan vaginale droogheid voorkomen. Hebben jullie hier wel eens last van? Probeer dan de opwinding te verhogen want zowel glijmiddelen als speeksel hebben een remmend effect op de kwaliteit van het sperma.",
            givenAnswer: "",
            asked: false,
            image: "spermcell2",
            shared: false
        )
        questionsHardcoded.append(newQuestion)
        
        let newQuestion2 = Question(
            question: "Hoe vaak kun je het beste seks hebben in de vruchtbare periode?",
            options: ["Elke dag", "Om de dag"],
            answer: 1,
            explanation: "De kwaliteit van zaadcellen is het beste 48 uur na de laatste zaadlozing, het is dus beter om de dag seks te hebben. Hebben jullie in de vruchtbare periode soms elke dag of meerdere keren per dag seks? Laat er dan eens een dag tussen voor de betere zaadkwaliteit.",
            givenAnswer: "",
            asked: false,
            image: "spermcell",
            shared: false
        )
        questionsHardcoded.append(newQuestion2)
        
        let newQuestion3 = Question(
            question: "Wat voor effect hebben erectiepillen als viagra op de zaadkwaliteit?",
            options: ["Positief effect", "Negatief effect"],
            answer: 0,
            explanation: "Is het soms lastig om een erectie te krijgen of te houden? Gebruik dan gerust een erectiepil als viagra. Dit lijkt een positief effect te hebben op de zaadkwaliteit.",
            givenAnswer: "",
            asked: false,
            image: "viagra",
            shared: false
        )
        questionsHardcoded.append(newQuestion3)
    }
}
