//
//  UICreater.swift
//  MoleyMayhem
//
//  Created by Tom on 09/05/2016.
//  Copyright © 2016 Tom. All rights reserved.
//

import Foundation
import SpriteKit

open class UICreator{
    
    open static func CreateButton(_ node: SKLabelNode, text: String, position pos: CGPoint) -> SKLabelNode{
        let button = node
        button.text = text
        button.name = text
        button.position = pos
        button.fontColor = UIColor.orange
        button.fontName = "AvenirNext-Bold"
        button.fontSize = 40
        button.zPosition = 10
        return button
    }
    
    open static func CreateLabel(_ name: String) -> SKLabelNode{
        let label = SKLabelNode()
        label.name = name
        label.fontColor = UIColor.black
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 30
        label.zPosition = 9
        
        return label
    }

}
