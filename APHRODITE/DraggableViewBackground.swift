//
//  DraggableViewBackground.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit

class DraggableViewBackground: UIView, DraggableViewDelegate {
    
    var allCards: [DraggableView]!
    var questions = [InteresseVragen]()
    var optionalIndex = -1
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    let MAX_BUFFER_SIZE = 2
    let CARD_HEIGHT: CGFloat = 100
    let CARD_WIDTH: CGFloat = 290
    //let CARD_HEIGHT: CGFloat = 60
    //let CARD_WIDTH: CGFloat = 250
    
    var cardsLoadedIndex: Int!
    var loadedCards: [DraggableView]!
    var menuButton: UIButton!
    var messageButton: UIButton!
    var checkButton: UIButton!
    var xButton: UIButton!
    var progressLabel: UILabel!
    var controller : KDCircularProgress!
    var DoneText : UILabel!
    var vakerLabel: UILabel!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.layoutSubviews()
        self.setupView()
        allCards = []
        loadedCards = []
        cardsLoadedIndex = 0
    }
    
    func setupView() -> Void {
       // self.backgroundColor = UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1)
        
        xButton = UIButton(frame: CGRectMake((self.frame.size.width - CARD_WIDTH)/2 + 35, self.frame.size.height/2 + CARD_HEIGHT/2 + 120, 59, 59))
        xButton.setImage(UIImage(named: "CROSS"), forState: UIControlState.Normal)
        xButton.addTarget(self, action: "swipeLeft", forControlEvents: UIControlEvents.TouchUpInside)
        
        checkButton = UIButton(frame: CGRectMake(self.frame.size.width/2 + CARD_WIDTH/2 - 85, self.frame.size.height/2 + CARD_HEIGHT/2 + 120, 59, 59))
        xButton = UIButton(frame: CGRectMake((self.frame.size.width - CARD_WIDTH)/2 + 35, self.frame.size.height/2 + CARD_HEIGHT/2 + 100, 50, 50))
        xButton.setImage(UIImage(named: "CROSS"), forState: UIControlState.Normal)
        xButton.addTarget(self, action: "swipeLeft", forControlEvents: UIControlEvents.TouchUpInside)
        
        checkButton = UIButton(frame: CGRectMake(self.frame.size.width/2 + CARD_WIDTH/2 - 85, self.frame.size.height/2 + CARD_HEIGHT/2 + 100, 50, 50))
        checkButton.setImage(UIImage(named: "HEART"), forState: UIControlState.Normal)
        checkButton.addTarget(self, action: "swipeRight", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.addSubview(xButton)
        self.addSubview(checkButton)
    }
    
    func createDraggableViewWithDataAtIndex(index: NSInteger) -> DraggableView {
        var draggableView = DraggableView(frame: CGRectMake((self.frame.size.width - CARD_WIDTH)/2, (self.frame.size.height - CARD_HEIGHT)/2 + 50, CARD_WIDTH, CARD_HEIGHT))
        draggableView.information.text = questions[index].subject
        draggableView.delegate = self
        return draggableView
    }
    
    func loadCards() -> Void {
        var count = 0
        controller.clockwise = false
        controller.glowAmount = 0.2
        if questions.count > 0  {
            let numLoadedCardsCap = questions.count > MAX_BUFFER_SIZE ? MAX_BUFFER_SIZE : questions.count
            for var i = 0; i < questions.count; i++ {
                var newCard: DraggableView = self.createDraggableViewWithDataAtIndex(i)
                allCards.append(newCard)
                if i < numLoadedCardsCap {
                    loadedCards.append(newCard)
                }
            }
            
            for var i = 0; i < loadedCards.count; i++ {
                if i > 0 {
                    self.insertSubview(loadedCards[i], belowSubview: loadedCards[i - 1])
                } else {
                    self.addSubview(loadedCards[i])
                }
                cardsLoadedIndex = cardsLoadedIndex + 1
            }
        }
        if appDelegate.index <= appDelegate.questionsArray.count {
            let newAngleValue = newAngle()
            
            
            controller.animateToAngle(newAngleValue, duration: 0.5, completion: nil)
            progressLabel.text = (String(Int(updateLabel())) + "%")

        }
    }
    
    func cardSwipedLeft(card: UIView) -> Void {
        if(optionalIndex > -1)
        {
            appDelegate.questionsArray[optionalIndex].answer = "true"
            appDelegate.index = appDelegate.index + 1

            let newAngleValue = newAngle()

            
            controller.animateToAngle(newAngleValue, duration: 0.5, completion: nil)
            progressLabel.text = (String(Int(updateLabel())) + "%")
            
        }
        else{
        loadedCards.removeAtIndex(0)
        appDelegate.questionsArray[appDelegate.index].answer = "false"
        appDelegate.index = appDelegate.index + 1

        if cardsLoadedIndex < allCards.count {

            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
            

        }
        if appDelegate.index <= appDelegate.questionsArray.count {
            let newAngleValue = newAngle()
            
            
            controller.animateToAngle(newAngleValue, duration: 0.5, completion: nil)
            progressLabel.text = (String(Int(updateLabel())) + "%")
        }
        if(appDelegate.index == appDelegate.questionsArray.count)
        {
            DoneText.hidden = false
            vakerLabel.hidden = true
        }
        }


    }
    
    func cardSwipedRight(card: UIView) -> Void {
        if(optionalIndex > -1)
        {
            appDelegate.questionsArray[optionalIndex].answer = "true"
            appDelegate.index = appDelegate.index + 1

            let newAngleValue = newAngle()
            

            controller.animateToAngle(newAngleValue, duration: 0.5, completion: nil)
            progressLabel.text = (String(Int(updateLabel())) + "%")

        }
        else{
        loadedCards.removeAtIndex(0)
        appDelegate.questionsArray[appDelegate.index].answer = "true"
        appDelegate.index = appDelegate.index + 1
        if cardsLoadedIndex < allCards.count {

            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
           
            
      
            
        }
        if appDelegate.index <= appDelegate.questionsArray.count {
            let newAngleValue = newAngle()
            
            
            controller.animateToAngle(newAngleValue, duration: 0.5, completion: nil)
            progressLabel.text = (String(Int(updateLabel())) + "%")
            
        }
        if(appDelegate.index == appDelegate.questionsArray.count)
        {
        DoneText.hidden = false
        }
        }
        
    }
    
    func swipeRight() -> Void {
        if loadedCards.count <= 0 {
            return
        }
        var dragView: DraggableView = loadedCards[0]
        dragView.overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeRight)
        UIView.animateWithDuration(0.2, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.rightClickAction()

    }
    
    func swipeLeft() -> Void {
        if loadedCards.count <= 0 {
            return
        }
        var dragView: DraggableView = loadedCards[0]
        dragView.overlayView.setMode(GGOverlayViewMode.GGOverlayViewModeLeft)
        UIView.animateWithDuration(0.2, animations: {
            () -> Void in
            dragView.overlayView.alpha = 1
        })
        dragView.leftClickAction()
    }
    
    func newAngle() -> Double {
        return (360 * Double(Double(appDelegate.index) / Double(appDelegate.questionsArray.count)))
    }
    func updateLabel() -> Double {
        return (100 * Double(Double(appDelegate.index) / Double(appDelegate.questionsArray.count)))
    }
}