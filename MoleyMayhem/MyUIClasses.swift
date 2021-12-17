//
//  MyUIClasses.swift
//  MoleyMayhem
//
//  Created by Tom on 19/05/2016.
//  Copyright © 2016 Tom. All rights reserved.
//

import Foundation
import SpriteKit

//--------------Attribute Text-----------------------

class AttrText: SKNode{
    
    var tfattributes: [String: AnyObject]!
    var label: ASAttributedLabelNode!
    
    init(text: String, tColour: UIColor, bColour: UIColor, position: CGPoint = CGPoint.zero, tSize: CGFloat = 50, bSize: Int = 2, tFont: String = "AvenirNext-Bold"){
        super.init()
        
        let font = UIFont(name: tFont, size: tSize)
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        tfattributes = [NSFontAttributeName : font!,
                        NSParagraphStyleAttributeName: style,
                        NSForegroundColorAttributeName: tColour,
                        NSStrokeColorAttributeName : bColour,
                        NSStrokeWidthAttributeName: -bSize as AnyObject]
        let labelText = NSMutableAttributedString(string: text, attributes: tfattributes)
        
        label = ASAttributedLabelNode(size: labelText.size())
        label.attributedString = labelText
        label.position = position
        addChild(label)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //----Functions for Changing Text
    
    func UpdateText(newText: String){
        //The width of the label must be set to the new lenght of the string before the string is added otherwise it gets stretched
        let newAttString = NSMutableAttributedString(string: newText, attributes: tfattributes)
        label.size.width = newAttString.size().width
        label.attributedString = newAttString
    }
    
    func AppendText(with newText: String){
        var text = label.attributedString.string
        text.append(newText)
        //The width of the label must be set to the new lenght of the string before the string is added otherwise it gets stretched
        let newAttString = NSMutableAttributedString(string: text, attributes: tfattributes)
        label.size.width = newAttString.size().width
        label.attributedString = newAttString
    }
    
}


//--------------Text Buttons---------------------------------

class TextButtonWithRect: SKNode{
    
    var touchArea: CGRect!
    var tfattributes: [String: AnyObject]!
    
    
    
    init(areaSize: CGSize, position: CGPoint, text: String){
        super.init()
        
        self.position = position
        
        let font = UIFont(name: "AvenirNext-Bold", size: 40)
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        tfattributes = [NSFontAttributeName : font!,
                        NSParagraphStyleAttributeName: style,
                        NSForegroundColorAttributeName: UIColor.red,
                        NSStrokeColorAttributeName : UIColor.black,
                        NSStrokeWidthAttributeName: -4 as AnyObject]
        let labelText = NSMutableAttributedString(string: text, attributes: tfattributes)
        
    
        let label = ASAttributedLabelNode(size: labelText.size())
        
        label.attributedString = labelText
        label.name = "label"
        label.zPosition = 10
        addChild(label)
        
        touchArea = CGRect(x: -areaSize.width/2, y: -areaSize.height/2, width: areaSize.width, height: areaSize.height)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


//--------------Text centred on an image---------------------

class TextSprite: SKNode{
    
    var box: SKSpriteNode!
    var tfattributes: [String: AnyObject]!
    var texture: SKTexture!
    
    init(file: String!, size: CGSize, text: String){
        super.init()
        
        if file != nil{
            texture = SKTexture(imageNamed: file)
        }
        box = SKSpriteNode(texture: texture, size: size)
        addChild(box)
        
        let font = UIFont(name: "AvenirNext-Bold", size: 50)
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        tfattributes = [NSFontAttributeName : font!,
                            NSParagraphStyleAttributeName: style,
                            NSForegroundColorAttributeName: UIColor.red,
                            NSStrokeColorAttributeName : UIColor.black,
                            NSStrokeWidthAttributeName: -4 as AnyObject]
        let labelText = NSMutableAttributedString(string: text, attributes: tfattributes)
        
        
        //let label = ASAttributedLabelNode(size: CGSize(width: 600, height: 100))
        let label = ASAttributedLabelNode(size: box.size)

        label.attributedString = labelText
        label.name = "label"
        label.zPosition = 10
        addChild(label)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//---------------TextSprite with Two Buttons------------------

class TwoButtonTextSprite: TextSprite{
    
    init(file: String, size: CGSize, text: String, Button1Text: String, Button2Text: String){
        super.init(file: file, size: size, text: text)
        
        //Move title into the top quarter of the screen
        let label = childNode(withName: "label") as! ASAttributedLabelNode
        label.position = CGPoint(x: 0, y: box.frame.height / 4)
        
        let Button1Position = CGPoint(x: -box.frame.width / 4, y: -box.frame.height / 4) //This moves the text from the middle to the bottom left quadrant
        let button1 = UICreator.CreateButton(SKLabelNode(), text: Button1Text, position: Button1Position)
        button1.fontColor = UIColor.red
        addChild(button1)
        
        let Button2Position = CGPoint(x: box.frame.width / 4, y: -box.frame.height / 4) //This time 'x' is positive, so the text is in the bottom right quadrant
        let button2 = UICreator.CreateButton(SKLabelNode(), text: Button2Text, position: Button2Position)
        button2.fontColor = UIColor.red
        addChild(button2)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}




