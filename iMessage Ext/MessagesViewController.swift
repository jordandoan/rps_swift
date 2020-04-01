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
    var components: URLComponents!
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
                let message = conversation.selectedMessage?.url
                guard let components = URLComponents(url: message!, resolvingAgainstBaseURL: false) else {
                    fatalError("The message contains an invalid URL")
                }
                self.components = components
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
        let message = MSMessage(session: MSSession())
        message.layout = layout
        let components = composeInitialURL()
        message.url = components.url
        self.activeConversation?.insert(message, completionHandler: nil)
    }
    
    func gameViewControllerDidSubmit(caption: String) {
        reviseURL(move: caption)
        if checkStatus() {
            let layout = MSMessageTemplateLayout()
            layout.caption = caption
            let session = self.activeConversation?.selectedMessage?.session
            let message = MSMessage(session: session ?? MSSession())
            message.layout = layout
            message.url = self.components.url
            self.activeConversation?.send(message, completionHandler: nil)
            dismiss()
        }
    }
    
    private func checkStatus() -> Bool {
        let move1 = self.components.queryItems![4].value
        let move2 = self.components.queryItems![5].value
        // return true if only one is none
        if move1 == "None" && move2 != "None" {
            return true
        } else if move2 == "None" && move1 != "None" {
            return true
        } else {
            return false
        }
    }
    
    private func reviseURL(move: String) {
        let view = children[0] as? Game
        let id = self.activeConversation?.localParticipantIdentifier.uuidString
        // If you are player 1
        let result: Int?
        if id == self.components.queryItems![2].value {
            self.components.queryItems![4].value = move
            result = view?.determineRoundWinner(p1_move: move, p2_move: self.components.queryItems![5].value!)
        } else {
            self.components.queryItems![5].value = move
            result = view?.determineRoundWinner(p1_move: self.components.queryItems![4].value!, p2_move: move)
        }
        self.components = view!.renderResults(components: self.components, result: result!)
        self.components.queryItems![0].value = id
    }
    
    private func composeInitialURL() -> URLComponents {
        var components = URLComponents()
        let uuid = self.activeConversation?.localParticipantIdentifier.uuidString
        let user = URLQueryItem(name: "recent", value: uuid)
        let result = URLQueryItem(name: "result", value: "None")
        let player_1 = URLQueryItem(name: "p1", value: uuid)
        let uuid2 = self.activeConversation?.remoteParticipantIdentifiers[0].uuidString
        let player_2 = URLQueryItem(name: "p2", value: uuid2)
        let p1_move = URLQueryItem(name: "p1_move", value: "None")
        let p2_move = URLQueryItem(name: "p2_move", value: "None")
        let p1_score = URLQueryItem(name: "p1_score", value: "0")
        let p2_score = URLQueryItem(name: "p2_score", value: "0")
        components.queryItems = [user, result, player_1, player_2, p1_move, p2_move, p1_score, p2_score]
        return components
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
