/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Firebase
import JSQMessagesViewController


enum answerState
{
    case start
    case messageSent
    case tutorialTap1
    case tutorialTap2
    case tutorialTap3
    case tapGebruikDeApp
}


class TutorialViewController: JSQMessagesViewController {
    
    
    
    var messages: [JSQMessage] = []
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    let rootRef = FIRDatabase.database().referenceFromURL("https://aphrodite-8623a.firebaseio.com/")
    var messageRef: FIRDatabaseReference!
    var userIsTypingRef: FIRDatabaseReference!
    
    var usersTypingQuery: FIRDatabaseQuery!
    var answer = answerState.start
    var button:UIButton?
    
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "ChatChat"
        let image = UIImage(named: "TUTORIAL_1.png")
        button = UIButton(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        button!.setTitle("Test Button", forState: .Normal)
        button!.setImage(image, forState: .Normal)
        button!.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
        
        setupBubbles()
        // No avatars!
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        messageRef = rootRef.child("messages")
    }
    
    func buttonAction(sender: UIButton!) {
        print("Button tapped")
        self.postAnswer()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        observeMessages()
        observeTyping()
        self.postAnswer()
        finishReceivingMessage()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView.textColor = UIColor.whiteColor()
        } else {
            cell.textView.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "text": text,
            "senderId": senderId
        ]
        
        print(messageRef)
        
        itemRef.setValue(messageItem)
        
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.postAnswer()
        })
        self.view.endEditing(true)
        self.inputToolbar.hidden = true;
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        isTyping = false
    }
    
    func postAnswer()
    {
        
        switch answer {
            
        case answerState.start:
            self.topContentAdditionalInset = 183
            //let tempView = UIView(frame: CGRectMake(0,0,375,233))
            let tempView = UIView(frame: CGRectMake(0,0,375,233))
            tempView.backgroundColor = UIColor(patternImage: UIImage(named: "OVERLAY_APHRODITE.png")!)
            self.view.addSubview(tempView)
            tempView.superview!.bringSubviewToFront(tempView)
            
            addMessage("foo", text: "Hallo, mijn naam is Aphrodite. Ik ga jou en je partner helpen in het proces van zwanger worden.")
            addMessage("foo", text: "Allereerst, wat is je naam?")
            finishReceivingMessage()
            answer = answerState.messageSent
            break;
            
            
        case answerState.messageSent:
            self.topContentAdditionalInset = 0
            addMessage("foo", text: "Hoi! Ik wil je graag verder helpen maar daarvoor moet je straks eerst jouw telefoon koppelen aan die van je partner. Nadat je dit hebt gedaan ga ik je vragen om wat interesses in te vullen.")
            finishReceivingMessage()
            
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.addMessage("foo", text: "Dit kun je later bij “interesses” doen.")
            self.finishReceivingMessage()
                
                let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    self.view.addSubview(self.button!)
                })
            })
            
            
            
            answer = answerState.tutorialTap1
            break;
            
        case answerState.tutorialTap1:
            button!.hidden = true
            
            let image = UIImage(named: "TUTORIAL_2.png")
            self.button!.setImage(image, forState: .Normal)
            addMessage("foo", text: "Bij “Aphrodite” ga ik met je praten en kun je al mijn adviezen inzien. Als je hulp nodig hebt kan ik je hier ook helpen.")
            finishReceivingMessage()
            
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.button!.hidden = false
                })
            
            answer = answerState.tutorialTap2
            break;
            
        case answerState.tutorialTap2:
            button!.hidden = true
            
            let image = UIImage(named: "TUTORIAL_3.png")
            self.button!.setImage(image, forState: .Normal)
            addMessage("foo", text: "Als laatste wil ik je graag leren hoe je de kans op zwangerschap nog meer kunt vergroten. Dit doe ik aan de hand van de “Vraag van de dag”. Denk jij dat je deze goed kunt beantwoorden?")
            finishReceivingMessage()
            
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.button!.hidden = false
            })
            
            answer = answerState.tutorialTap3
            break;
            
            
        case answerState.tutorialTap3:
            button!.hidden = true
            let image = UIImage(named: "TUTORIAL_4.png")
            self.button!.setImage(image, forState: .Normal)
            
            addMessage("foo", text: "Je kunt nu gebruik maken van de app! ")
            finishReceivingMessage()
            
            
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.button!.hidden = false
            })
            
            answer = answerState.tapGebruikDeApp
            break;
        
        
        case answerState.tapGebruikDeApp:
            
        self.performSegueWithIdentifier("start", sender: nil)
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("tabBar2") as! UITabBarController
        nextViewController.selectedIndex = 1;
        self.presentViewController(nextViewController, animated:true, completion: nil)
        
        break;
        }
    }
    
    
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    private func observeMessages() {
        let messagesQuery = messageRef.queryLimitedToLast(25)
        
        messagesQuery.observeEventType(.ChildAdded, withBlock: { snapshot in
            let id = snapshot.value!["senderId"] as! String
            let text = snapshot.value!["text"] as! String
            self.addMessage(id, text: text)
            self.finishReceivingMessage()
        })
    }
    
    private func observeTyping() {
        let typingIndicatorRef = rootRef.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)
        usersTypingQuery.observeEventType(.Value, withBlock: { snapshot in
            // You're the only one typing, don't show the indicator
            if snapshot.childrenCount == 1 && self.isTyping { return }
            
            // Are there others typing?
            self.showTypingIndicator = snapshot.childrenCount > 0
            self.scrollToBottomAnimated(true)
        })
    }
    
    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message)
    }
    

    
}