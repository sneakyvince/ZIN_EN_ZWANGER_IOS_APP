//
//  CardsViewController.swift
//  APHRODITE
//
//  Created by Fhict on 10/06/16.
//  Copyright © 2016 Vincent van der Palen. All rights reserved.
//

import UIKit



class CardsViewController: UIViewController {
    
    var newQuestions = [InteresseVragen]()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var singleQuestion: InteresseVragen?

    @IBOutlet weak var DoneLabel: UILabel!
    @IBOutlet weak var ProgressLabel: UILabel!
    @IBOutlet weak var ProgressBar: KDCircularProgress!
    
    @IBOutlet var VakeLabel: UILabel!
    @IBOutlet weak var progress: UIView!
    override func viewDidAppear(animated: Bool) {
      
        newQuestions.removeAll()
        var draggableBackground: DraggableViewBackground = DraggableViewBackground(frame: self.view.frame)
        self.view.addSubview(draggableBackground)
        
        if(singleQuestion == nil)
        {
            for(var i = 0; i < appDelegate.questionsArray.count; i += 1)
            {
                if(appDelegate.questionsArray[i].answer == "")
                {
                    newQuestions.append(appDelegate.questionsArray[i])
                }
            }
        }
        else
        {
            newQuestions.append(singleQuestion!)
            draggableBackground.optionalIndex = searchArrIndex(singleQuestion!)
        }
            if(newQuestions.count == 0)
            {
                DoneLabel.hidden = false
            }
        draggableBackground.DoneText = DoneLabel
        draggableBackground.vakerLabel = VakeLabel
        draggableBackground.progressLabel = ProgressLabel
        draggableBackground.controller = self.ProgressBar
        draggableBackground.questions = newQuestions
        
        //print(Questions[1].subject)
        draggableBackground.loadCards()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ProgressBar.angle = 0
        DoneLabel.hidden = true

                 // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchArrIndex(Question: InteresseVragen) -> Int
    {
        for(var i = 0; i < appDelegate.questionsArray.count; i += 1)
        {
            if(Question.subject == appDelegate.questionsArray[i].subject)
            {
            return i
            }
        }
        return -1
    }
   
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
