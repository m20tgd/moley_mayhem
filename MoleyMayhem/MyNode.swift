//
//  MyNode.swift
//  MoleyMayhem
//
//  Created by Tom on 03/12/2015.
//  Copyright © 2015 Tom. All rights reserved.
//

import SpriteKit

class MyNode: SKNode{
    
    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
    
    var ReturnScene: SKScene!{
        get{
            if let par = self.parent{
                if par.isKindOfClass(SKScene){
                    //If parent is scene, return parent
                    return par as! SKScene
                }
                //If parent is not a scene, return parent of parent until scene is found
                let myPar = par as! MyNode
                return myPar.ReturnScene
            }
            return nil //Return nil if node has no parent. This should also prevent an endless loop in hierarchy without a scene
        }
    }
}