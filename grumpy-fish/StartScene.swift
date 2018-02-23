//
//  StartScene.swift
//  grumpy-fish
//
//  Created by Sergey Kozak on 23/02/2018.
//  Copyright © 2018 Centennial. All rights reserved.
//

import UIKit
import SpriteKit

class StartScene: SKScene {
    
    var startButton: SKLabelNode!
    var settingsButton: SKLabelNode!
    
    override func didMove(to view: SKView) {
        startButton = childNode(withName: "startGame") as! SKLabelNode

    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // check which label was clicked and present the next scene accordingly
        for touch in touches {
            let location = touch.location(in: self)
            if atPoint(location).name == "startGame" {
                startButton.fontColor = UIColor.yellow
                if let gameScene = GameScene(fileNamed: "GameScene") {
                    gameScene.scaleMode = .aspectFill
                    view?.presentScene(gameScene)
                }
            }
            else if atPoint(location).name == "settings" {
                print("settings pressed")
            }
        }
    }
    
  

}
