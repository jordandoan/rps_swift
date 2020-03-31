//
//  MessagesViewController.swift
//  iMessage Ext
//
//  Created by Sara Ryane on 3/29/20.
//  Copyright © 2020 Jordan Doan. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController, StartGameViewControllerDelegate, GameViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
        
    }
    
    override func didBecomeActive(with conversation: MSConversation) {
        presentViewController(for: conversation, with: presentationStyle)
    }
    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        removeAllChildViewControllers()
        var controller: UIViewController
        if presentationStyle == .compact {
            controller = instantiateStartGameViewController()
        } else {
            controller = UIViewController()
            if let session = conversation.selectedMessage?.session {
//                let message = conversation.selectedMessage?.url
//                guard let components = URLComponents(url: message!, resolvingAgainstBaseURL: false) else {
//                    fatalError("The message contains an invalid URL")
//                }
                NSLog("hi")
                controller = instatiateGameViewController()
            } else {
                controller = instantiateStartGameViewController()
            }
//            controller = instatiateGameViewController()
        }
        addChild(controller)
        controller.view.frame = view.bounds
//        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        controller.didMove(toParent: self)
        if let expanded = controller as? Game {
            if let url = conversation.selectedMessage?.url {
                expanded.checkSelf(from: url, self_id: self.activeConversation!.localParticipantIdentifier.uuidString)
            }
        }
    }
    
    func startGameViewControllerDidSubmit() {
        let layout = MSMessageTemplateLayout()
        layout.caption = "Rock, Paper, Scissors!"
        let session = self.activeConversation?.selectedMessage?.session
        let message = MSMessage(session: session ?? MSSession())
        message.layout = layout
        var components = URLComponents()
        let uuid = self.activeConversation?.localParticipantIdentifier.uuidString
        let user = URLQueryItem(name: "user", value: uuid)
        components.queryItems = [user]
        message.url = components.url
        self.activeConversation?.insert(message, completionHandler: nil)
    }
    
    func gameViewControllerDidSubmit(caption: String) {
        let layout = MSMessageTemplateLayout()
        layout.caption = caption
        
        let session = self.activeConversation?.selectedMessage?.session
        let message = MSMessage(session: session ?? MSSession())
        message.layout = layout
        
        self.activeConversation?.send(message, completionHandler: nil)
        dismiss()
    }
    
    private func instatiateGameViewController() -> UIViewController {
        guard let controller = self.storyboard!.instantiateViewController(withIdentifier: "Game") as? Game else {
        fatalError("Game not found")
        }
        controller.delegate = self
        return controller
    }
    
    private func instantiateStartGameViewController() -> UIViewController {
        guard let controller = self.storyboard!.instantiateViewController(withIdentifier: "StartGame") as? StartGame else {
        fatalError("StartGame not found")
        }
        controller.delegate = self
        return controller
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
//    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
//        // Called when the user taps the send button.
//    }

    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
        // Use this method to finalize any behaviors associated with the change in presentation style.
        guard let conversation = self.activeConversation else { fatalError("Expected an active conversation")}
        presentViewController(for: conversation, with: presentationStyle)
    }
    
    private func removeAllChildViewControllers() {
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
}
