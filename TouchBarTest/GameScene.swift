//
//  GameScene.swift
//  TouchBarTest
//
//  Created by Openfield Mobility on 16/12/2016.
//  Copyright © 2016 Openfield Mobility. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    let playerVelocity: CGFloat = 500
    
    var score: Int = 0
    
    enum PhysicsCategory: UInt32 {
        case player = 0
        case ground = 1
        case obstacle = 2
    }
    
    var ground: SKSpriteNode!
    var player: SKSpriteNode!
    
    let backgroundTime: CFTimeInterval = 1
    var backgroundPreviousTime: CFTimeInterval = 0
    var backgroundTimeCount: CFTimeInterval = 0
    var backgrounds: [SKSpriteNode] = []
    
    var obstacleTime: CFTimeInterval = 1
    var obstaclePreviousTime: CFTimeInterval = 0
    var obstacleTimeCount: CFTimeInterval = 0
    var obstacles: [SKSpriteNode] = []
}

extension GameScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // We set the scale of the view
        self.scaleMode = .resizeFill
        self.backgroundColor = .white
        
        // Some debug info
        let debug = false
        view.showsPhysics = debug
        view.showsFPS = debug
        view.showsNodeCount = debug
        
        // Make the ground
        let ground = self.createGround()
        self.ground = ground
        self.addChild(self.ground)
        
        // Add the player
        let player = self.createPlayer()
        self.player = player
        self.addChild(self.player)
        
        // Add a camera object
        let camera = SKCameraNode()
        camera.position = CGPoint(x: self.player.position.x, y: 15.5)
        self.camera = camera
        self.addChild(camera)
        
        // Collision delegate
        self.physicsWorld.contactDelegate = self
        
        // Add observer
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.jump), name: jumpNotification, object: nil)
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.obstacleTimeCount += currentTime - self.obstaclePreviousTime
        
        if self.obstacleTimeCount > self.obstacleTime {
            self.obstacleTimeCount = 0
            self.obstacleTime = Double.random(min: 0.5, max: 1.5)
            self.handleObstacles()
        }
        self.obstaclePreviousTime = currentTime
        
        self.backgroundTimeCount += currentTime - self.backgroundPreviousTime
        
        if self.backgroundTimeCount > self.backgroundTime {
            self.createBackground()
            
            self.backgroundTimeCount = 0
        }
        
        self.backgroundPreviousTime = currentTime
    }
    
    override func didFinishUpdate() {
        super.didFinishUpdate()
        
        self.player.physicsBody?.velocity.dx = self.playerVelocity
        
        self.ground.position.x = self.player.position.x
        self.camera?.position.x = self.player.position.x
    }
}

extension GameScene {
    func jump() {
        self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -15))
        NotificationCenter.default.post(name: scoreNotification, object: nil)
        
        if self.isPaused {
            self.isPaused = false
            self.alpha = 1
        }
    }
    
    func createGround() -> SKSpriteNode {
        let ground = SKSpriteNode()
        ground.size = CGSize(width: 1085, height: 0)
        ground.position = .zero
        ground.zPosition = 1
        
        let body = SKPhysicsBody(edgeLoopFrom: ground.frame)
        body.categoryBitMask = PhysicsCategory.ground.rawValue
        body.fieldBitMask = PhysicsCategory.ground.rawValue
        body.collisionBitMask = PhysicsCategory.player.rawValue
        body.isDynamic = false
        ground.physicsBody = body
        return ground
    }
    
    func createPlayer() -> SKSpriteNode {
        let frames = SKTextureAtlas(named: "pikachu").textureNames.map { SKTexture(imageNamed: $0) }
        let playerNode = SKSpriteNode(texture: frames.first)
        playerNode.size = CGSize(width: 30, height: 30)
        playerNode.position = .zero
        playerNode.zPosition = 1
        
        playerNode.run(SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 0.1, resize: false, restore: true)), withKey:"player-movement-animation")
        
        let body = SKPhysicsBody(rectangleOf: playerNode.size)
        body.isDynamic = true
        body.affectedByGravity = true
        body.allowsRotation = false
        body.velocity.dx = self.playerVelocity
        body.categoryBitMask = PhysicsCategory.player.rawValue
        body.collisionBitMask = PhysicsCategory.ground.rawValue
        body.contactTestBitMask = PhysicsCategory.obstacle.rawValue
        playerNode.physicsBody = body
        playerNode.physicsBody?.applyImpulse(CGVector(dx: self.playerVelocity, dy: 0))
        
        return playerNode
    }
    
    func createBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.size = CGSize(width: 1920, height: 60)
        background.zPosition = 0
        
        if let last = self.backgrounds.last {
            background.position.x = last.position.x + last.frame.width
        } else {
            background.position.x = 0
        }
        
        self.backgrounds.append(background)
        self.addChild(background)
        
        if self.backgrounds.count > 100 {
            self.backgrounds.first?.removeFromParent()
            self.backgrounds.removeFirst()
        }
    }
    
    func handleObstacles() {
        let x: CGFloat = self.player.position.x + 2000
        let y: CGFloat = 8
        let rect = CGRect(x: x, y: y, width: 18, height: 18)
        let obstacle = SKSpriteNode(texture: SKTexture(imageNamed: "obstacle"))
        obstacle.size = rect.size
        obstacle.position = rect.origin
        obstacle.zPosition = 2
        
        let body = SKPhysicsBody(rectangleOf: obstacle.frame.size)
        body.affectedByGravity = false
        body.allowsRotation = false
        body.categoryBitMask = PhysicsCategory.obstacle.rawValue
        body.contactTestBitMask = PhysicsCategory.player.rawValue
        obstacle.physicsBody = body
        
        self.obstacles.append(obstacle)
        self.addChild(obstacle)
        
        if self.obstacles.count > 100 {
            self.obstacles.first?.removeFromParent()
            self.obstacles.removeFirst()
        }
    }
    
    func play() {
        print("Play")
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        self.isPaused = true
        self.alpha = 0.5
    }
}

extension Double {
    static var random: Double {
        return Double(arc4random()) / 0xFFFFFF
    }
    
    static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}
