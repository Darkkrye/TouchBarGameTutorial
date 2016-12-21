//
//  WindowController.swift
//  TouchBarTest
//
//  Created by Openfield Mobility on 16/12/2016.
//  Copyright © 2016 Openfield Mobility. All rights reserved.
//

import Cocoa
import SpriteKit

let jumpNotification = Notification.Name("JumpNotificationIdentifier")
let scoreNotification = Notification.Name("ScoreUpdate")
let gameScene = GameScene()

class WindowController: NSWindowController {
    
    var score: Int = 0

    override func windowDidLoad() {
        super.windowDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(WindowController.update), name: scoreNotification, object: nil)
    }
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .customTouchBar
        touchBar.defaultItemIdentifiers = [.playButton, .label, .scoreLabel, .customView]
        touchBar.customizationAllowedItemIdentifiers = [.customView]
        
        return touchBar
    }
    
    override func keyDown(with event: NSEvent) {
        // super.keyDown(with: event) // We don't want the beep sound...
        
        if event.keyCode == 49 {
            // If space is pressed
            NotificationCenter.default.post(name: jumpNotification, object: nil)
        }
    }

    func update() {
        self.score += 1
        didChangeValue(forKey: "score")
    }
}

@available(OSX 10.12.2, *)
extension WindowController: NSTouchBarDelegate {
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItemIdentifier.customView:
            let gameView = SKView()
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.view = gameView
            gameView.presentScene(gameScene)
            
            return item
            
        case NSTouchBarItemIdentifier.label:
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.view = NSTextField(labelWithString: "Score : ")
            
            return item
            
        case NSTouchBarItemIdentifier.scoreLabel:
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.view = NSTextField(labelWithString: "----")
            item.view.bind("value", to: self, withKeyPath: #keyPath(score), options: nil)
            
            return item
            
        case NSTouchBarItemIdentifier.playButton:
            let item = NSCustomTouchBarItem(identifier: identifier)
            let button = NSButton(title: "Play", target: gameScene, action: #selector(GameScene.play))
            button.bezelColor = NSColor(red: 0.35, green: 0.61, blue: 0.35, alpha: 1)
            item.view = button
            
            return item
        default:
            return nil
        }
    }
}
