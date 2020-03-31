//
//  MessagesViewController.swift
//  iMessage Ext
//
//  Created by Sara Ryane on 3/29/20.
//  Copyright © 2020 Jordan Doan. All rights reserved.
//

import UIKit


protocol GameViewControllerDelegate: class {
    func gameViewControllerDidSubmit (caption: String)
}
class Game: UIViewController {
    
    weak var delegate : GameViewControllerDelegate!
    @IBAction func paper(_ sender: Any) {
        addMessage(type: "paper")
    }
    
    @IBAction func rock(_ sender: Any) {
        addMessage(type: "rock")
    }
    
    @IBAction func scissors(_ sender: Any) {
        addMessage(type: "scissors")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addMessage(type: String) {

        self.delegate.gameViewControllerDidSubmit(caption: type)
    }
}
