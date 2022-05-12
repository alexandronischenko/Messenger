//
//  ChatViewController.swift
//  Messenger
//
//  Created by Alexandr Onischenko on 29.01.2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public var isNewConversation = false
    
    public let otherUserEmail: String
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
                                                      
        return Sender(photoURL: "", senderId: email, displayName: "Joe Smith")
    }
    
    init(with email: String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
        let messageID = createMessageId() else {
                  return
              }
        
        print("Sending: \(text)")
        
        // send message
        if isNewConversation {
            //create convo in db
            
            let message = Message(sender: selfSender, messageId: messageID, sentDate: Date(), kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: message, completion: { success in
                if success {
                    print("message sent")
                }
                print("error sending messages")
            })
        }
        else {
            //append to existing conv data
        }
    }
    
    func createMessageId() -> String? {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeUserEmail = DatabaseManager.safeEmail(emailAdress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newId = "\(otherUserEmail)_\(safeUserEmail)_\(dateString)"
        
        print("Created message: \(newId)")
        return newId
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self sender is nil, email should be cached")
        return Sender(photoURL: "", senderId: "12", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}
