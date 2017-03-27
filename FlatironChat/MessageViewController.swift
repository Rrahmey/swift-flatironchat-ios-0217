//
//  MessageViewController.swift
//  FlatironChat
//
//  Created by Johann Kerr on 3/23/17.
//  Copyright © 2017 Johann Kerr. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseAuth

class MessageViewController: JSQMessagesViewController  {
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    var messages = [JSQMessage]()
    var channelId = ""
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
        getMessages()
        navigationItem.title = channelId
        
    }
    
    
    
    
    func getMessages() {
        
        self.messages.removeAll()
        
        FIRDatabase.database().reference().child("messages").child(channelId).observe(.childAdded, with: {snapshot in
            
            
            let channelName = snapshot.key
            print("The channel name is", channelName)
            
            if let channelDict = snapshot.value as? [String: Any] {
                print("channel Dic is ", channelDict)
            
                guard let messageContent = channelDict["content"] as? String else {return}
                guard let senderID = channelDict["from"] as? String else {return}
                
            
                if let newMessage = JSQMessage(senderId: senderID, displayName: senderID, text: messageContent) {
                    self.messages.append(newMessage) }
            }
            self.collectionView.reloadData()
            
        }
            
        )}
    
    
    
    
    
    
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        
        
        
        let preferences = UserDefaults.standard
        guard let name = preferences.string(forKey: "screenName") else { return }
        FIRDatabase.database().reference().child("channels").child(channelId).child("lastMessage").setValue(text)
        FIRDatabase.database().reference().child("messages").child(channelId).childByAutoId().setValue(["content": text, "from":name])
        
FIRDatabase.database().reference().child("users").child(name).child("channels").setValue([channelId: true])
        FIRDatabase.database().reference().child("channels").child(channelId).child("participants").setValue([name: true])
        
        self.finishSendingMessage(animated: true)
    }
    
    
    
    
}
//MARK: - CollectionView


extension MessageViewController {
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
}


//MARK: - Layout stuff


extension MessageViewController {
    
    fileprivate func setUpView() {
        collectionView.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = .zero
    }
    
    fileprivate func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    fileprivate func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        let message = messages[indexPath.item]
        switch message.senderId {
        case senderId:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
    }
}
