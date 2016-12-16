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

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .customTouchBar
        touchBar.defaultItemIdentifiers = [.customView]
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

}

@available(OSX 10.12.2, *)
extension WindowController: NSTouchBarDelegate {
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItemIdentifier.customView:
            let gameView = SKView()
            let scene = GameScene()
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.view = gameView
            gameView.presentScene(scene)
            
            return item
        default:
            return nil
        }
    }
}
