//
//  GameViewController.swift
//  MoleyMayhem
//
//  Created by Tom on 05/11/2015.
//  Copyright (c) 2015 Tom. All rights reserved.
//

import iAd
import UIKit
import SpriteKit

open class GameViewController: UIViewController, ADBannerViewDelegate{
    
    let ViewSize = CGSize(width: 960, height: 540)
    
    //Load user data
    open static let userProfile = UserProfile()
    open static let asdf = SKLabelNode(text: "HELLO")
    
    var adBanner: ADBannerView!

    ///----------Initialiser
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        
        let titleScene = TitleScene(size: ViewSize)
            // Configure the view.
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            //gameScene.scaleMode = .AspectFill
            titleScene.scaleMode = .aspectFill
            
            skView.presentScene(titleScene)
    }
    
}
