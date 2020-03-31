//
//  MessagesViewController.swift
//  iMessage Ext
//
//  Created by Sara Ryane on 3/29/20.
//  Copyright © 2020 Jordan Doan. All rights reserved.
//

import UIKit

protocol StartGameViewControllerDelegate : class {
    func startGameViewControllerDidSubmit()
}
class StartGame: UIViewController {
    
    weak var delegate : StartGameViewControllerDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func button(_ sender: Any) {
        addMessage()
    }
    
    func addMessage() {
        self.delegate.startGameViewControllerDidSubmit()
    }
    
    
}
