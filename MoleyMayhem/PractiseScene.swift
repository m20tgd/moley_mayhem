//
//  PractiseScene.swift
//  MoleyMayhem
//
//  Created by Tom on 11/07/2016.
//  Copyright © 2016 Tom. All rights reserved.
//

import SpriteKit

class PractiseScene: SKScene{

    var moleGrid: MoleGrid!

    //Buttons
    var exitButton = SKLabelNode()
    let ExitButtonTitle = "X"

    var CentrePosition: CGPoint{
        get{
            return CGPoint(x: size.width/2, y: size.height/2)
        }
    }

    //------------
    ///Initialiser
    //------------

    override func didMove(to view: SKView) {
    
        backgroundColor = UIColor.green
    
        moleGrid = MoleGrid(columns: 2, rows: 2, separation: 20, position: CentrePosition, mode: .practise)
        addChild(moleGrid)
    
        //Create Exit Button
        UICreator.CreateButton(exitButton, text: ExitButtonTitle, position: CGPoint(x: self.size.width - 50, y: self.size.height - 50))
        addChild(exitButton)
        
        if let mole = self.userData?.object(forKey: "practisemole"){ //Stored in UserData by Gallery Scene
            let m = mole as! Mole
            moleGrid.StartPractiseTimer(m)
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
                switch name{
                //ExitButton
                case ExitButtonTitle:
                    self.scene!.view?.presentScene(GalleryScene(size: (self.scene?.size)!), transition: SKTransition.push(with: SKTransitionDirection.right, duration: 1))
                case "mole":
                    let m = touchedNode.parent as! Mole
                    m.MoleHit()
                default:
                    break
                }
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Perform actions on mole when touch moves. Needed to invalidate timer for Wrestler mole if touch moves off mole
        //Gets previous positions and tests to see if it was in a mole
        //If so, it tests to see if it has moved out of the mole
        for touch in touches{
            let previousPosition = touch.previousLocation(in: moleGrid)
            let nodeAtPreviousPosition = moleGrid.atPoint(previousPosition)
            if let name = nodeAtPreviousPosition.name{
                if name == "mole"{
                    let m = nodeAtPreviousPosition.parent as! Mole
                    if !nodeAtPreviousPosition.contains(touch.location(in: m)){
                        m.MoleUntouched()
                    }
                }
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Perform actions on moles if touch ends on them. Needed to invalidate timer for Wrestler mole
        for touch in touches{
            let positionInGrid = touch.location(in: moleGrid)
            let touchedNode = moleGrid.atPoint(positionInGrid)
            if let name = touchedNode.name{
                if name == "mole"{
                    let m = touchedNode.parent as! Mole
                    m.MoleUntouched()
                }
            }
        }
    }
    
    
    
}




