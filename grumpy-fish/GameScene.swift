//
//  GameScene.swift
//  grumpy-fish
//
//  Created by Sergey Kozak on 19/02/2018.
//  Copyright © 2018 Centennial. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: -- GAME VARIABLES --
    
    // obstacle arrays
    var bottomTextures = ["rock1", "rock2", "rock3", "rock4", "rock5", "rock6", "rock7"]
    var topTextures = ["coral1", "coral2", "coral3", "coral4", "coral5", "coral6"]
    var itemTextures = ["starfish1", "starfish2", "starfish3"]
    
    // game objects and info
    var scoreLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var oceanFloor: SKSpriteNode!
    var oceanFloor2: SKSpriteNode!
    var fish: SKSpriteNode?
    var bottomObstacle: SKSpriteNode?
    var topObstacle: SKSpriteNode?
    var item: SKSpriteNode?
    var score = 40
    var collided = false
    var highscore = UserDefaults().integer(forKey: "highscore")
    
    // time intervals to slightly randomize obstacles
    var bottomObstacleInterval: TimeInterval = 4
    var timeSinceBottomObstacleCreated: TimeInterval = 0
    var topObstacleInterval: TimeInterval = 3.5
    var timeSinceTopObstacleCreated: TimeInterval = 0
    var itemTimeInterval: TimeInterval = 2.5
    var timeSinceItemCreated: TimeInterval = 0
    var previousTime: TimeInterval = 0
    
    // categories for collisions
    
    var noCategory: UInt32 = 0
    var playerCategory: UInt32 = 0b1
    var obstacleCategory: UInt32 = 0b1 << 1
    var itemCategory: UInt32 = 0b1 << 2
    
    // MARK: -- SCENE START --
    
    override func didMove(to view: SKView) {
        
        // set self as delegate to register collisions
        self.physicsWorld.contactDelegate = self
        
        // add nodes
        
        scoreLabel = self.childNode(withName: "scoreLabel") as? SKLabelNode
        scoreLabel.text = "you: \(score)"
        scoreLabel.position = CGPoint(x: self.frame.width * 0.15, y: self.frame.height * 0.85)
        
        highScoreLabel = self.childNode(withName: "highScoreLabel") as? SKLabelNode
        highScoreLabel.text = "top: \(highscore)"
        
        oceanFloor = (self.childNode(withName: "oceanFloor") as? SKSpriteNode)!
        oceanFloor2 = (self.childNode(withName: "oceanFloor2") as? SKSpriteNode)!
        
        fish = self.childNode(withName: "fish") as? SKSpriteNode
        fish?.physicsBody?.categoryBitMask = playerCategory
        fish?.physicsBody?.contactTestBitMask = obstacleCategory | itemCategory
        
        // add cycled movement to ocean floor
        let oceanMovement = SKAction.move(by:  CGVector(dx: -oceanFloor.size.width, dy: 0), duration: 10)
        let oceanReset = SKAction.move(by: CGVector(dx: oceanFloor.size.width, dy: 0), duration: 0)
        let oceanSequence = SKAction.repeatForever(SKAction.sequence([oceanMovement, oceanReset]))
        oceanFloor.run(oceanSequence)
        oceanFloor2.run(oceanSequence)
 
    }
    
    // MARK: -- GENERATE GAME OBJESTS --
    // Create items, top and bottom obstacles randomly
    
    func addBottomObstacle(_ frameRate: TimeInterval) {
        
        timeSinceBottomObstacleCreated += frameRate
        if timeSinceBottomObstacleCreated < bottomObstacleInterval {
            return
        }
        
        // create node from one of the textures
        let randomTexture = Int(arc4random_uniform(UInt32(bottomTextures.count)))
        let bottomTexture = SKTexture(imageNamed: bottomTextures[randomTexture])
        bottomObstacle = SKSpriteNode(texture: bottomTexture, size: bottomTexture.size())
        bottomObstacle?.position = CGPoint(x: self.frame.width + (bottomObstacle?.size.width)!, y: bottomTexture.size().height / 2 - 10)
        bottomObstacle?.physicsBody = SKPhysicsBody(texture: bottomTexture, size: bottomTexture.size())
        bottomObstacle?.physicsBody?.isDynamic = false
        bottomObstacle?.physicsBody?.affectedByGravity = false
        bottomObstacle?.physicsBody?.categoryBitMask = obstacleCategory
        bottomObstacle?.physicsBody?.contactTestBitMask = playerCategory
        bottomObstacle?.zPosition = 2
        let bottomObstacleMovement = SKAction.move(by: CGVector(dx: -self.frame.width * 2, dy: 0), duration: 12 - drand48())
        bottomObstacle?.run(bottomObstacleMovement)
        self.addChild(bottomObstacle!)
        
        // remove node after time period for optimization
        let waitAction = SKAction.wait(forDuration: 13)
        let removeFromParent = SKAction.removeFromParent()
        bottomObstacle?.run(SKAction.sequence([waitAction, removeFromParent]))
        
        // update time since the last obstacle created and set a little offset
        timeSinceBottomObstacleCreated = drand48()
    }
    
    func addTopObstacle(_ frameRate: TimeInterval) {
        
        timeSinceTopObstacleCreated += frameRate
        if timeSinceTopObstacleCreated < topObstacleInterval {
            return
        }
        
        // create node from one of the textures in the array
        let randomTexture = Int(arc4random_uniform(UInt32(topTextures.count)))
        let topTexture = SKTexture(imageNamed: topTextures[randomTexture])
        topObstacle = SKSpriteNode(texture: topTexture, size: topTexture.size())
        topObstacle?.position = CGPoint(x: self.frame.width + (topObstacle?.size.width)!, y: self.frame.height - (topObstacle?.size.height)! / 2) // check this
        topObstacle?.physicsBody = SKPhysicsBody(texture: topTexture, size: topTexture.size())
        topObstacle?.physicsBody?.isDynamic = false
        topObstacle?.physicsBody?.affectedByGravity = false
        topObstacle?.physicsBody?.categoryBitMask = obstacleCategory
        topObstacle?.physicsBody?.contactTestBitMask = playerCategory
        topObstacle?.zPosition = 2
        
        // move obstacle and remove node after time period for optimization
        let topObstacleMovement = SKAction.move(by: CGVector(dx: -self.frame.width * 2, dy: 0), duration: 12 + drand48())
        let waitAction = SKAction.wait(forDuration: 13)
        let removeFromParent = SKAction.removeFromParent()
        self.addChild(topObstacle!)
        topObstacle?.run(SKAction.sequence([topObstacleMovement, waitAction, removeFromParent]))
        
        
        // update time since the last obstacle created
        timeSinceTopObstacleCreated = drand48()

    }
    
    func addItem(_ frameRate: TimeInterval) {
        
        timeSinceItemCreated += frameRate
        if timeSinceItemCreated < itemTimeInterval {
            return
        }
        
        // create node from one of the textures in the array
        let randomTexture = Int(arc4random_uniform(UInt32(itemTextures.count)))
        let itemTexture = SKTexture(imageNamed: itemTextures[randomTexture])
        item = SKSpriteNode(texture: itemTexture, size: itemTexture.size())
        item?.position = CGPoint(x: Double(self.frame.width) + Double(itemTexture.size().width), y: Double(self.frame.height) * drand48())
    
        
        item?.physicsBody = SKPhysicsBody(texture: itemTexture, size: itemTexture.size())
        item?.physicsBody?.linearDamping = 0
        item?.physicsBody?.isDynamic = false
        item?.physicsBody?.affectedByGravity = false
        item?.physicsBody?.categoryBitMask = itemCategory
        item?.physicsBody?.contactTestBitMask = playerCategory
        item?.zPosition = 2
        
        // move obstacle and remove node after time period for optimization
        let itemMovement = SKAction.move(by: CGVector(dx: -self.frame.width * 2, dy: 0), duration: 15 + drand48())
        let waitAction = SKAction.wait(forDuration: 17)
        let removeFromParent = SKAction.removeFromParent()
        self.addChild(item!)
        item?.run(SKAction.sequence([itemMovement, waitAction, removeFromParent]))
        
        
        // update time since the last obstacle created
        timeSinceItemCreated = drand48()
        
    }
    
   
    
    
    // MARK: -- COLLISION HANDLING --
    // Respond to contacts and check if player collided with item or obstacle
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == playerCategory || contact.bodyB.categoryBitMask == playerCategory {
            
            let otherNode: SKNode = ((contact.bodyA.categoryBitMask == playerCategory) ? contact.bodyB.node : contact.bodyA.node)!
            
            if otherNode.physicsBody?.categoryBitMask == itemCategory {
                self.run(SKAction.playSoundFileNamed("zing", waitForCompletion: false))
                otherNode.removeFromParent()
                score += 10
            }
            else if otherNode.physicsBody?.categoryBitMask == obstacleCategory {
                score -= 20
                self.run(SKAction.playSoundFileNamed("bubble", waitForCompletion: false))
                let bubbles: SKEmitterNode = SKEmitterNode(fileNamed: "Smoke")!
                bubbles.position = CGPoint(x: otherNode.frame.midX, y: otherNode.frame.midY)
                otherNode.addChild(bubbles)
                otherNode.physicsBody?.categoryBitMask = noCategory
            }
            scoreLabel.text = String(score)
        }
    }
    

    
    // MARK: -- RESPOND TO TOUCH --
    // Touches began - start playing only after touching screen
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if fish?.parent == nil {
            let startScene = StartScene(fileNamed: "StartScene")
            startScene?.scaleMode = .aspectFill
            view?.presentScene(startScene)
        } else {
            fish?.physicsBody?.isDynamic = true
            fish?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30))
        }
    }
    
    
    // MARK: -- CHECK SCORE --
    // Check score and end game if lower than 0
    
    func checkScore() {
        if score <= 0 {
            fish?.removeFromParent()
            scoreLabel.text = "you: \(score)"
            gameOverLabel = childNode(withName: "gameOverLabel") as! SKLabelNode
            gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        } else if score > highscore {
            UserDefaults().set(score, forKey: "highscore")
            highscore = UserDefaults().integer(forKey: "highscore")
            highScoreLabel.text = "top: \(highscore)"
            
        }
    }
    
    
    // MARK: -- Update --
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        addBottomObstacle(currentTime - previousTime)
        addTopObstacle(currentTime - previousTime)
        addItem(currentTime - previousTime)
        checkScore()
        previousTime = currentTime
    }
}
