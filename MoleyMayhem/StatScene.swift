//
//  StatScene.swift
//  MoleyMayhem
//
//  Created by Tom on 26/01/2017.
//  Copyright © 2017 Tom. All rights reserved.
//

import SpriteKit

class StatScene: SKScene{
    
    
    //Buttons
    var exitButton = SKLabelNode()
    let ExitButtonTitle = "X"
    
    var title = AttrText(text: "Statistics", tColour: UIColor.red, bColour: UIColor.white)
    
    
    
    //------------------------
    ///---INITIALISER---------
    //------------------------
    
    override func didMove(to view: SKView) {
        
        backgroundColor = UIColor.green
        
        //Create Exit Button
        UICreator.CreateButton(exitButton, text: ExitButtonTitle, position: CGPoint(x: self.size.width - 50, y: self.size.height - 50))
        addChild(exitButton)
        
        //Create Title
        title.position = CGPoint(x: self.size.width / 2, y: self.size.height - 50)
        addChild(title)
        
        //Create array of list of stat texts
        let statTexts: [String:AttrText] = [
            "GamesPlayed" : AttrText(text: "Games Played - ", tColour: UIColor.orange, bColour: UIColor.white,
                                     position: CGPoint(x: self.size.width / 2, y: self.size.height - 125), tSize: 25),
            "NormalHits" : AttrText(text: "Normal Moles Squished - ", tColour: UIColor.orange, bColour: UIColor.white,
                                    position: CGPoint(x: self.size.width / 2, y: self.size.height - 175), tSize: 25),
            "DummyHits" : AttrText(text: "Dummy Moles Exploded - ", tColour: UIColor.orange, bColour: UIColor.white,
                                   position: CGPoint(x: self.size.width / 2, y: self.size.height - 225), tSize: 25),
            "ArmourHits" : AttrText(text: "Armour Moles Squished - ", tColour: UIColor.orange, bColour: UIColor.white,
                                    position: CGPoint(x: self.size.width / 2, y: self.size.height - 275), tSize: 25),
            "WrestlerHits" : AttrText(text: "Wrestler Moles Grappled - ", tColour: UIColor.orange, bColour: UIColor.white,
                                      position: CGPoint(x: self.size.width / 2, y: self.size.height - 325), tSize: 25),
            "SisterHits" : AttrText(text: "Sister Moles Squished - ", tColour: UIColor.orange, bColour: UIColor.white,
                                    position: CGPoint(x: self.size.width / 2, y: self.size.height - 375), tSize: 25),
            "BonusHits" : AttrText(text: "Bonus Moles Squished - ", tColour: UIColor.orange, bColour: UIColor.white,
                                   position: CGPoint(x: self.size.width / 2, y: self.size.height - 425), tSize: 25),
            "TotalHits" : AttrText(text: "Total Moles Squished - ", tColour: UIColor.orange, bColour: UIColor.white,
                                   position: CGPoint(x: self.size.width / 2, y: self.size.height - 475), tSize: 25)
        ]
        
        //Get stats
        let Stats = GameViewController.userProfile.stats
        
        let keys = Stats.allKeys
        for key in keys{
            let x = key as! String
            if statTexts.keys.contains(x){
                let value = Stats.value(forKey: x) as! Int
                statTexts[x]?.AppendText(with: "\(value)")
                addChild(statTexts[x]!)
            }
        }
        
    }
    
    //-----------------
    ///-Touch Responses
    //-----------------
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let touchPosition = touch.location(in: self)
            let touchedNode = self.atPoint(touchPosition)
            if let name = touchedNode.name{
                switch name{                //-------------Button Actions--------
                case ExitButtonTitle:
                    self.scene!.view?.presentScene(TitleScene(size: (self.scene?.size)!), transition: SKTransition.push(with: SKTransitionDirection.down, duration: 1))
                default: break
                }
            }
        }
    }
    
    
}
