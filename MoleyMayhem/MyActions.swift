//
//  MyActions.swift
//  MoleyMayhem
//
//  Created by Tom on 25/01/2016.
//  Copyright © 2016 Tom. All rights reserved.
//

import SpriteKit

open class MyActions{
    
    open static func Delay(_ seconds: Int) -> SKAction{
        return SKAction.wait(forDuration: TimeInterval.init(seconds))
    }
    
    open static func ChangeTexture(_ texture: SKTexture) -> SKAction{
        return SKAction.setTexture(texture)
    }
    
}
