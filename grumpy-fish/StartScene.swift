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
    var oceanFloor: SKSpriteNode!
    var oceanFloor2: SKSpriteNode!
    var musicPlaylist: [String] = ["1asteroid", "2ugol", "3look", "4pair", "5crash"]
    
    override func didMove(to view: SKView) {
        startButton = childNode(withName: "startGame") as! SKLabelNode
        
        oceanFloor = childNode(withName: "oceanFloor") as! SKSpriteNode
        oceanFloor2 = childNode(withName: "oceanFloor2") as! SKSpriteNode
        
        // add cycled movement to ocean floor
        let oceanMovement = SKAction.move(by:  CGVector(dx: -oceanFloor.size.width, dy: 0), duration: 10)
        let oceanReset = SKAction.move(by: CGVector(dx: oceanFloor.size.width, dy: 0), duration: 0)
        let oceanSequence = SKAction.repeatForever(SKAction.sequence([oceanMovement, oceanReset]))
        oceanFloor.run(oceanSequence)
        oceanFloor2.run(oceanSequence)
        
        // add background music randomly from playlist
        let bgMusic = SKAudioNode(fileNamed: musicPlaylist[Int(arc4random_uniform(UInt32(musicPlaylist.count)))])
        bgMusic.autoplayLooped = true
        self.addChild(bgMusic)
        
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
