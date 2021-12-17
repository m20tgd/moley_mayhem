//
//  SpriteGrid.swift
//  MoleyMayhem
//
//  Created by Tom on 31/01/2016.
//  Copyright © 2016 Tom. All rights reserved.
//

import SpriteKit

class NodeGrid: SKNode{
    
    internal var grid : [SKNode]!
    internal var columns, rows, separation: Int!
    fileprivate var spriteSize: CGSize = CGSize(width: 0,height: 0)
    
    var totalNodes: Int{
        get {
            return columns * rows
        }
    }
    
    var spriteWidth: CGFloat!{
        get { return spriteSize.width }
        set { spriteSize.width = newValue }
    }
    var spriteHeight: CGFloat!{
        get { return spriteSize.height }
        set { spriteSize.height = newValue }
    }
    
    var gridWidth: Int{
        get{
            return (columns - 1) * Int(spriteWidth)
        }
    }
    var gridHeight: Int{
        get{
            return (rows - 1) * Int(spriteHeight)
        }
    }
    
    //--------------
    ///Initialiser--
    //--------------
    
    init(node: SKNode, columns: Int, rows: Int, separation: Int, position: CGPoint){
        super.init()
        
        self.columns = columns
        self.rows = rows
        self.separation = separation
        SetSpriteSize(node)
        self.grid = CreateGrid(node)
        self.position = CentreAnchor(position) //Position set after grid created so spriteWidth is set
    }
    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
    
    //---------------
    ///Methods
    //----------------
    
    internal func SetSpriteSize(_ node: SKNode){
        
        if node.isKind(of: SKSpriteNode.self){ //If the passed node is a sprite node, then sprite size is set using the size of the sprite node
            let sprite = node as! SKSpriteNode
            spriteWidth = sprite.size.width + CGFloat(separation)
            spriteHeight = sprite.size.height + CGFloat(separation)
        }
        else{
            for child in node.children{ //If passed node is note a sprite node, then find its largest sprite child and use that to set the size
                if child.isKind(of: SKSpriteNode.self){
                    let sprite = child as! SKSpriteNode
                    let width = sprite.size.width + CGFloat(separation)
                    let height = sprite.size.height + CGFloat(separation)
                    let spriteLargest = Maths.HighValue(width, b: height)
                    let sizeLargest = Maths.HighValue(spriteWidth, b: spriteHeight)
                    if spriteLargest > sizeLargest{
                        spriteSize = CGSize(width: width, height: height)
                    }
                }
            }
                
        }
    }
    
    internal func CreateGrid(_ node: SKNode) -> [SKNode]{
        
        //Create grid
        var grid = Array<SKNode>()
        
        //Fill with copies of passed node
        for i in 0..<totalNodes{
            grid.append(node.copy() as! SKNode)
            
            //Assign node position in grid
            let column = i % columns
            let row = i / columns
            grid[i].position = CGPoint(x: column * Int(spriteWidth), y: row * Int(-spriteHeight))
            addChild(grid[i])
        }
        
        return grid
    }
    
    internal func CentreAnchor(_ position: CGPoint) -> CGPoint{ //Use to centre node on position
        let x = Int(position.x)
        let y = Int(position.y)
        //print(gridWidth)
        //print(gridHeight)
        return CGPoint(x: x - gridWidth/2, y: y + gridHeight/2)
    }
    
}
