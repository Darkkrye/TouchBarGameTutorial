//
//  NSTouchBarExtensions.swift
//  TouchBarTest
//
//  Created by Openfield Mobility on 16/12/2016.
//  Copyright © 2016 Openfield Mobility. All rights reserved.
//

import Foundation
import Cocoa

extension NSTouchBarCustomizationIdentifier {
    static let customTouchBar = NSTouchBarCustomizationIdentifier("com.openfield.TouchBarTest.customTouchBar")
}

extension NSTouchBarItemIdentifier {
    static let customView = NSTouchBarItemIdentifier("com.openfield.TouchBarTest.items.customView")
    static let playButton = NSTouchBarItemIdentifier("com.openfield.TouchBarTest.itmes.playButton")
    static let label = NSTouchBarItemIdentifier("com.openfield.TouchBarTest.itmes.label")
    static let scoreLabel = NSTouchBarItemIdentifier("com.openfield.TouchBarTest.itmes.scoreLabel")
}
