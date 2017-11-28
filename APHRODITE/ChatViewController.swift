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



class ChatViewController: JSQMessagesViewController {
    var chats: [JSQMessage] = []
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
        func buttonAction(sender: UIButton!) {
            print("Button tapped")
        }
        /*let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.backgroundColor = .greenColor()
        button.setTitle("Test Button", forState: .Normal)
        button.addTarget(self, action: "buttonAction", forControlEvents: .TouchUpInside)
        self.view.addSubview(tempView)
        tempView.superview!.bringSubviewToFront(tempView)*/

        
        senderId = "1234567"
        senderDisplayName = "test"
        
       
            setupBubbles()
            collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
            collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero

            messageRef = rootRef.child("chats")

        
        // No avatars!
        
        self.topContentAdditionalInset = 123
        //let tempView = UIView(frame: CGRectMake(0,0,375,233))
        let tempView = UIView(frame: CGRectMake(0,0,375,233))
        tempView.backgroundColor = UIColor(patternImage: UIImage(named: "OVERLAY_APHRODITE.png")!)
        self.view.addSubview(tempView)
        tempView.superview!.bringSubviewToFront(tempView)
        
        
        addMessage("foo", text: "Hoi Nico, koppel nog even je telefoon met die van je partner voordat ik je verder kan helpen.")
        addMessage("foo", text: "Super, je bent vanaf nu gekoppeld met Lisa. Ik ga jullie nu regelmatig advies geven op basis van jullie interesses")
        addMessage("foo", text: "Bij details kun je instellen wanneer, waar en hoe je benaderd wil worden door mij. Ook kun je mij ten alle tijde zelf benaderen door op de knop vraag advies te drukken.")
        addMessage("foo", text: "Onthoud dat zin en lust niet vanzelf komt. Werk samen naar het doel toe. Maak de omstandigheden gunstig, stel je open voor seksuele prikkels en geniet van elkaar! ")
        addMessage("foo", text: "Weet je nog hoe belangrijk opwinding is? ")
        finishReceivingMessage()
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
        self.topContentAdditionalInset = 0
        self.addMessage("foo", text: "Misschien een idee om eens wat extra tijd uit te trekken voor het voorspel. Denk aan het geven van een erotische massage, een uitgebreide zoensessie of door met Lisa samen douchen. ")
        self.finishReceivingMessage()
        })
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(appDelegate.ChatLoaded == false)
        {
            observeMessages()
            observeTyping()
        }
        appDelegate.ChatLoaded = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return chats[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chats.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = chats[indexPath.item]
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
        let chat = chats[indexPath.item]
        
        if chat.senderId == senderId {
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Chat"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        chats.append(message)
    }
    
}