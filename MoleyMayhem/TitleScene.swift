//
//  TitleScene.swift
//  MoleyMayhem
//
//  Created by Tom on 19/01/2016.
//  Copyright © 2016 Tom. All rights reserved.
//

import SpriteKit

class TitleScene: SKScene{
    
    var highScoreText = SKLabelNode()
    
    var startButton = SKLabelNode()
    let StartButtonTitle = "Start"
    var galleryButton = SKLabelNode()
    let GalleryButtonTitle = "Gallery"
    var statsButton = SKLabelNode()
    let StatsButtonTitle = "View Stats"
    
    override func didMove(to view: SKView) {
        
        backgroundColor = UIColor.green
        
        //Create Buttons
        UICreator.CreateButton(startButton, text: StartButtonTitle, position: CGPoint(x: 475, y: 300))
        addChild(startButton)
        UICreator.CreateButton(galleryButton, text: GalleryButtonTitle, position: CGPoint(x:475, y: 225))
        addChild(galleryButton)
        UICreator.CreateButton(statsButton, text: StatsButtonTitle, position: CGPoint(x:475, y: 150))
        addChild(statsButton)
        
        //Create High Score Text
        highScoreText.text = "High Score = \(GameViewController.userProfile.HighScore)"
        highScoreText.position = CGPoint(x: self.size.width / 2, y: self.size.height - 50)
        highScoreText.fontColor = UIColor.red
        highScoreText.fontName = "AvenirNext-Bold"
        highScoreText.fontSize = 50
        highScoreText.zPosition = 10
        addChild(highScoreText)
    }
    
    //-----------------
    ///-Touch Responses
    //-----------------
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let touchPosition = touch.location(in: self)
            let touchedNode = self.atPoint(touchPosition)
            if let name = touchedNode.name{
                //StartButton
                if name == StartButtonTitle{
                    self.scene!.view?.presentScene(GameScene(size: (self.scene?.size)!), transition: SKTransition.doorsOpenHorizontal(withDuration: 1))
                }
                //GalleryButton
                else if name == GalleryButtonTitle{
                    self.scene!.view?.presentScene(GalleryScene(size: (self.scene?.size)!), transition: SKTransition.push(with: SKTransitionDirection.left, duration: 1))
                }
                //StatsButton
                else if name == StatsButtonTitle{
                    self.scene!.view?.presentScene(StatScene(size: (self.scene?.size)!), transition: SKTransition.push(with: SKTransitionDirection.up, duration: 1))
                }
            }
        }
    }

}//End of Class
    

