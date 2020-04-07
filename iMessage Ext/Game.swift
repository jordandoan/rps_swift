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
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var opp_score: UILabel!
    @IBOutlet weak var self_score: UILabel!
    var delegate : GameViewControllerDelegate?
    @IBAction func paper(_ sender: Any) {
        addMessage(type: "paper")
    }
    
    func renderScore(p1: String = "0", p2: String = "0") {
        self.self_score.text = p1
        self.opp_score.text = p2
    }
    
    @IBAction func rock(_ sender: Any) {
        addMessage(type: "rock")
    }
    
    @IBAction func scissors(_ sender: Any) {
        addMessage(type: "scissors")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.label.text = ""
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func addMessage(type: String) {
        self.delegate?.gameViewControllerDidSubmit(caption: type)
    }
    
    
    func checkSelf(with components: URLComponents, self_id: String) {
        for item in components.queryItems! {
            if item.name == "recent" {
                let value = item.value
                if value == self_id {
                    self.label.isHidden = false
                    self.label.text = "Waiting for player..."
                } else {
                    self.label!.isHidden = true
                }
            }
        }
    }
    
    func setSent() {
        self.label.isHidden = false
        self.label.text = "Waiting for player..."
    }
    func printMessage() {
        print("You are printing this message...")
    }
    
    func renderResults(components: URLComponents, result: Int) -> URLComponents {
//        self.result.text = components.queryItems![4].value! + components.queryItems![5].value!
        self.result.text = String(result)
        if result == -1 {
            return components
        }
        var new_components = components

        if result == 0 {
            self.result.text = "Player 1 wins this round"
            let next_value:Int? = Int(components.queryItems![6].value!)! + 1
            new_components.queryItems![6].value = String(next_value!)
        } else if result == 1 {
            self.result.text = "Tie"
        } else if result == 2 {
            self.result.text = "Player 2 wins this round"
            let next_value:Int? = Int(components.queryItems![7].value!)! + 1
            new_components.queryItems![7].value = String(next_value!)
        }
        new_components.queryItems![4].value = "None"
        new_components.queryItems![5].value = "None"
        return new_components
    }
    func determineRoundWinner(p1_move: String, p2_move: String) -> Int {
        if (p1_move == "None" || p2_move == "None") {
            return -1
        }
        if ((p1_move == "rock" && p2_move == "scissors") || (p1_move == "scissors" && p2_move == "paper") || (p1_move == "paper" && p2_move == "rock")) {
            return 0
        } else if p1_move == p2_move {
            return 1
        } else {
            return 2
        }
    }
}
    
