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

class AntwoordViewController: JSQMessagesViewController {
    
    var explanation = ""
    var answer = ""
    var correct = ""
    var shared = false
    var askedQuestion: Question!
    
    var answers: [JSQMessage] = []
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    let rootRef = FIRDatabase.database().referenceFromURL("https://aphrodite-8623a.firebaseio.com/")
    var messageRef: FIRDatabaseReference!
    var userIsTypingRef: FIRDatabaseReference!
    
    var usersTypingQuery: FIRDatabaseQuery!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputToolbar.hidden = true;
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        title = correct
        senderId = "1234567"
        senderDisplayName = "test"
        
        
        setupBubbles()
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        messageRef = rootRef.child("answers")
        
        
        // No avatars!
       
        self.topContentAdditionalInset = 183
        
        //let tempView = UIView(frame: CGRectMake(0,0,375,233))
        let tempView = UIView(frame: CGRectMake(0,0,375,182))
        tempView.backgroundColor = UIColor(patternImage: UIImage(named: "OVERLAY_APHRODITE")!)
        self.view.addSubview(tempView)
        tempView.superview!.bringSubviewToFront(tempView)
        self.inputToolbar.hidden = true;
        
        addAnswer("1234567", text: answer)
        addAnswer("foo", text: explanation)
        addAnswer("foo", text: "Kom morgen terug voor een nieuwe vraag van de dag!")
        finishReceivingMessage()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(appDelegate.ChatLoaded == true)
        {
            observeMessages()
            observeTyping()
        }
        appDelegate.ChatLoaded = false
        let attrs = NSMutableAttributedString(
            string: "",
            attributes: [
                NSForegroundColorAttributeName : UIColor.redColor(),
                NSFontAttributeName : UIFont.systemFontOfSize(28, weight: UIFontWeightRegular)
            ]
        )
        let label = UILabel(frame: CGRectMake(0, 0, 375, 335))
        label.center = CGPointMake(375, 335)
        label.textAlignment = NSTextAlignment.Center
        label.text = "I'am a test label"
        label.attributedText = attrs
        self.view.addSubview(label)
        
        label.layer.zPosition = 1
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return answers[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return answers.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = answers[indexPath.item]
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
        let message = answers[indexPath.item]
        
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
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        isTyping = false
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
        let answersQuery = messageRef.queryLimitedToLast(25)
        
        answersQuery.observeEventType(.ChildAdded, withBlock: { snapshot in
            let id = snapshot.value!["senderId"] as! String
            let text = snapshot.value!["text"] as! String
            self.addAnswer(id, text: text)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Chat"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    func addAnswer(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        answers.append(message)
    }
    
    @IBAction func btnShare(sender: AnyObject) {
    
    
        if askedQuestion.shared == false {
            askedQuestion.shared = true
            var alertView =
                UIAlertView(
                    title: "Gedeeld!",
                    message:"De vraag van de dag is gedeeld met je partner. Vraag vanavond eens wat ze ingevuld had en praat er eens over! ",
                    delegate: nil,
                    cancelButtonTitle: "Oke!" )
            alertView.show()
        }
        else {
            var alertView =
                UIAlertView(
                    title: "Al gedeeld!",
                    message:"Je hebt deze vraag al gedeeld met je partner. Morgen komt er weer een nieuwe vraag!  ",
                    delegate: nil,
                    cancelButtonTitle: "Oke!" )
            alertView.show()
        }
    }

    
}
