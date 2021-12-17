//
//  Mole.swift
//  MoleyMayhem
//
//  Created by Tom on 05/11/2015.
//  Copyright © 2015 Tom. All rights reserved.
//

import SpriteKit

enum MoleType: String{
    
    case Normal = "Normal", Dummy = "Dummy", Armour = "Armour", Wrestler = "Wrestler", Sister = "Sister", Bonus = "Bonus"
    
    var Score: Int{
        switch self{
        case .Normal: return 10
        case .Dummy: return 0
        case .Armour: return 20
        case .Wrestler: return 50
        case .Sister: return 25 //Player will get 2x sister score as they always hit two
        case .Bonus: return 100
        }
    }
    
    var Texture: SKTexture{
        switch self{
        case .Normal: return Mole.moleStandardTexture
        case .Dummy: return Mole.moleDummyTexture
        case .Armour: return Mole.moleArmourTexture
        case .Wrestler: return Mole.moleWrestlerTexture
        case .Sister: return Mole.moleSisterTexture
        case .Bonus: return Mole.moleBonusTexture
        }
    }
    
    //Put in # where the description is to split onto separate lines
    var Description: String{
        switch self{
        case .Normal: return "Your normal pesky mole. #Squish him quick!"
        case .Dummy: return "A trap made by the moles. #Avoid at all costs"
        case .Armour: return "A mole with extra defences. #A double hit should do it"
        case .Wrestler: return "This mole likes a good grapple. #Keep hold to take him down"
        case .Sister: return "Only seen in pairs. #Must hit them both at once"
        case .Bonus: return "The rarest mole. #Hit for a nice bonus"
        }
    }
    
    var UnlockCondition: (MoleType, Int){
        switch self{
        case .Normal: return (.Normal, 0)
        case .Dummy: return (.Normal, 0)
        case .Armour: return (.Normal, 5)
        case .Wrestler: return (.Armour, 50)
        case .Sister: return (.Armour, 100)
        case .Bonus: return (.Normal, 1000)
        }
    }
    
    static func ArrayOfTypes() ->[MoleType]{
        return [.Normal, .Dummy, .Armour, .Wrestler, .Sister, .Bonus]
    }
}

//--------------------------------------------------------------------------------------------------------------
enum MoleMode: Int{
    case play, gallery, practise
}

//--------------------------------------------------------------------------------------------------------------
class Mole : SKNode {
    
    //--------------
    ///Properties---
    //--------------
    
    //Create the sprite nodes for the mole and hole. Mole starts with "mole' standard texture.
    let hole = SKSpriteNode(imageNamed: "molehole")
    let mole = SKSpriteNode(imageNamed: "mole")
    
    
    //Textures for mole SpriteNode. The difference mole types are static so that they can be access by MoleType enum
    static let moleStandardTexture = SKTexture(imageNamed: "mole")
    static let moleDummyTexture = SKTexture(imageNamed: "dummyMole")
    static let moleArmourTexture = SKTexture(imageNamed: "armourMole")
    static let moleWrestlerTexture = SKTexture(imageNamed: "wrestlerMole")
    static let moleSisterTexture = SKTexture(imageNamed: "sisterMole")
    static let moleBonusTexture = SKTexture(imageNamed: "bonusMole")
    let bloodSplatTexture = SKTexture(imageNamed: "bloodsplat")
    let qMarkTexture = SKTexture(imageNamed: "qmark")
    
    //Set .Normal as the starting MoleType
    var CurrentMoleType = MoleType.Normal{
        willSet(type){
            mole.run(MyActions.ChangeTexture(type.Texture)) //Change texture when MoleType is changed
        }
    }
    
    
    //Gameplay Variable
    var HitCount = 0 //Set HitCount variable to count how many times the mole has been hit.
    var MoleTouched = false //Bool to tell if Mole is touched or not
    var HoleEmpty = true //Shows whether a mole is present or not. Mole.Hidden is not enough as it is triggered later in the action queue
    var Dead = false //Changed to true after mole is hit to prevent multiple scoring whilst bloodsplat is shown.
    var PairedMole: Mole?
    var Locked = false
    var currentMode: MoleMode!
    
    //Timers
    fileprivate var wrestlerTimer = Timer() //Timer for measuring how long wrestler mole is touched for
    fileprivate let wrestlerDuration: Double = 1 //Use this to change how long wrestler must be held for
    
    //Return the dimensions of the mole and hole for spacing in grid
    var MoleWidth: CGFloat{
        get{
            return hole.frame.size.width
        }
    }
    var MoleHeight: CGFloat{
        get{
            return hole.frame.size.height
        }
    }
    
    var MoleHidden: Bool{
        get{ return mole.isHidden}
        set{ mole.isHidden = newValue}
    }
    
    var Game: GameScene{
        get
        {
            return self.scene! as! GameScene
        }
    }
    
    var grid: MoleGrid{
        get {return self.parent as! MoleGrid}
    }
    
    //let points = SKLabelNode() //This is used to display the points when the mole is hit. See "ShowPoints" under Actions
    
    //------------
    ///Initialiser
    //------------
    
    init(position: CGPoint, mode: MoleMode){
        super.init()
        
        //Set position as passed position
        self.position = position
        
        //Set MoleMode
        self.currentMode = mode
        
        //Add hole and mole sprites
        hole.position = CGPoint.zero
        hole.zPosition = 1
        addChild(hole)
        mole.name = "mole" //Set name as mole for touch ID
        mole.position = CGPoint.zero
        mole.zPosition = 2
        mole.isHidden = true
        self.MoleReset()
        addChild(mole)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //----------------
    ///Actions--------
    //----------------
    
    let scaleToZero = SKAction.scale(to: 0, duration: TimeInterval.init(0))
    let scaleToNormal = SKAction.scale(to: 1, duration: TimeInterval.init(1))
    
    
    func RandomMoleAppears(_ seconds: Float){
        self.HoleEmpty = false
        self.CurrentMoleType = ChooseRandomType(seconds) //Randomly select MoleType
        //print(self.CurrentMoleType)
        let scaleUp = SKAction.scale(to: 1, duration: TimeInterval.init(seconds/2))
        let scaleDown = SKAction.scale(to: 0, duration: TimeInterval.init(seconds/2))
        //This action sequence causes the mole to start small, become visible and the come out and go back in again. If it does this without being hit
        // then a life is deducted
        mole.run(SKAction.sequence([scaleToZero, SKAction.unhide(), scaleUp, scaleDown, SKAction.run({self.MoleNotHit()})]))
    }
    
    
    func MoleAppears(_ seconds: Float, type: MoleType){
        self.CurrentMoleType = type
        self.HoleEmpty = false
        //print(self.CurrentMoleType)
        let scaleUp = SKAction.scale(to: 1, duration: TimeInterval.init(seconds/2))
        let scaleDown = SKAction.scale(to: 0, duration: TimeInterval.init(seconds/2))
        //This action sequence causes the mole to start small, become visible and the come out and go back in again. If it does this without being hit
        // then a life is deducted
        mole.run(SKAction.sequence([scaleToZero, SKAction.unhide(), scaleUp, scaleDown, SKAction.run({self.MoleNotHit()})]))
    }
    
    
    func DisplayMole(_ type: MoleType){ //Used for gallery mode to show mole permanently
        self.CurrentMoleType = type
        self.HoleEmpty = false
        mole.run(SKAction.sequence([SKAction.unhide(), scaleToNormal]))
    }
    
    
    func ShowPoints(){ //This function shows either points or a sprite when a mole is hit
        var risingNode = SKNode()
        if (Dead){
            if (CurrentMoleType != .Dummy){
                risingNode = SKLabelNode()
                let points = risingNode as! SKLabelNode
                points.text = String(CurrentMoleType.Score)
                points.fontColor = UIColor.red
                points.fontName = "AvenirNext-Bold"
                points.fontSize = 40
            }
            else{
                risingNode = SKSpriteNode(imageNamed: "heartbroken")
            }
            
        }
        else if (!Dead){
            if (CurrentMoleType != .Dummy){
                risingNode = SKSpriteNode(imageNamed: "heartbroken")
            }
        }
        risingNode.zPosition = 20
        addChild(risingNode)
        let targetY = risingNode.position.y + (self.MoleHeight / 2)
        let targetPoint = CGPoint(x: risingNode.position.x, y: targetY)
        let rise = SKAction.move(to: targetPoint, duration: 0.5)
        risingNode.run(SKAction.sequence([SKAction.unhide(), rise, SKAction.hide()]))
    }
    
    //----------------
    ///Methods-
    //----------------
    
    func MoleReset(){
        
        mole.removeAllActions() //End current actions
        mole.run(scaleToZero) //Reduce to zero so it will start at zero when it next appears
        mole.run(SKAction.hide()) //Hide mole until it next appears
        //CurrentMoleType = .Normal //Sets type to Normal, this will also change texture.
        HitCount = 0 //Reset HitCount
        MoleTouched = false
        HoleEmpty = true
        Dead = false
        PairedMole = nil
    }
    
    func MoleNotHit(){
        
        if currentMode == .play{
            if CurrentMoleType != .Dummy{
                Game.Lives-=1
            }
        }
        ShowPoints()
        MoleReset()
    }
    
    
    func MoleUntouched(){ //Activated when touch is lifted or moved away from Mole
        
        MoleTouched = false
        
        switch CurrentMoleType{
        case .Normal:
            break
        case .Dummy:
            break
        case .Armour:
            break
        case .Wrestler:
            CancelWrestlerTimer()
        case .Sister:
            break
        case .Bonus:
            break
        }
    }
    
    
    func MoleDead(){//Not made a private method so it can be accessed by Wrestler Timer
        mole.isPaused = false //Ensure mole is not paused
        if currentMode == .play{
            Game.score += CurrentMoleType.Score * Game.Multi //Adjust score. Add new score times bonus multiplier
            UpdateStatsWithHit()
        }
        mole.removeAllActions()
        mole.run(SKAction.sequence([MyActions.ChangeTexture(bloodSplatTexture), MyActions.Delay(1), SKAction.run({self.MoleReset()})]))
        Dead = true
        ShowPoints() //This needs to be after Dead = true to ensure that points are shown rather than broken heart
    }
    
    
    func MoleHit(){
        
        if !self.isHidden && !self.Dead{
            MoleTouched = true //Mark that mole is touched
            self.HitCount+=1 //Increment HitCount by 1 to record hit
            PerformTypeSpecificCode() //Carry out type specific actions. See func below.
        }
    }
    
    
    func ShowQuestionMark(){
        mole.run(MyActions.ChangeTexture(qMarkTexture))
    }
    
    //----------------
    ///Private Methods
    //----------------
    
    fileprivate func PerformTypeSpecificCode(){
        
        switch CurrentMoleType{
        case .Normal:
            MoleDead()
        case .Dummy:
            if currentMode == .play{
                Game.Lives-=1
            }
            MoleDead()
        case .Armour:
            if self.HitCount >= 2{
                MoleDead()
            }
        case .Wrestler:
            StartWrestlerTimer()
        case .Sister:
        if self.PairedMole!.MoleTouched == true{
            self.PairedMole!.MoleDead()
            self.MoleDead()
            }
        case .Bonus :
            if currentMode == .play{
                Game.Multi+=1
                Game.Lives+=1
            }
            MoleDead()
        }
        
    }
    
    
    fileprivate func ChooseRandomType(_ seconds: Float) -> MoleType{ //Seconds is passed to allow sister mole to create sister
        
        let x = Maths.RandomInt(100)
        var type = MoleType.Normal
        
        if x > 60{
            return type
        }
        else if x > 40{
            type = .Dummy
        }
        else if x > 20{
            if !grid.TypeAlreadyActive(.Armour){
                type = .Armour
            }
        }
        else if x > 10{
            if !grid.TypeAlreadyActive(.Wrestler){
                type = .Wrestler
            }
        }
        else if x > 1{
            if !grid.TypeAlreadyActive(.Sister){
                if let m = grid.ReturnEmptyHole(butNot: self){ //If there is not a free hole then switch will fall through to .Normal
                    m.MoleAppears(seconds, type: .Sister)
                    m.PairedMole = self
                    self.PairedMole = m
                    type = .Sister
                }
            }
        }
        else if x == 1{
            type = .Bonus   
        }
        
        if Game.unlockedTypes.value(forKey: type.rawValue) as! Bool == true{ //Only return in MoleType is unlocked
            return type
        }
        self.PairedMole?.MoleReset()
        return .Normal //If all else fails, .Normal will be returned
    }
    
    
    fileprivate func UpdateStatsWithHit(){
        
        //Update Type Count
        let key = CurrentMoleType.rawValue + "Hits" //Get appropriate keys for current mole type.
        
        if let statTypeCount = Game.Stats[key]{
            let newCount = statTypeCount + 1
            Game.Stats.updateValue(newCount, forKey: key)
        }
        else {
            print("Key: " + key + " - Does Not exist" )
        }
        
        //Update Total Count
        if let statTotalCount = Game.Stats["TotalHits"]{
            let newCount = statTotalCount + 1
           Game.Stats.updateValue(newCount, forKey: "TotalHits")
        }
        else {
            print("Key: TotalHits - Does Not Exist")
        }
        
    }
    
    //-----------------------
    ///Wrestler Timer Methods
    //-----------------------
    
    fileprivate func StartWrestlerTimer(){
        mole.isPaused = true
        wrestlerTimer = Timer.scheduledTimer(timeInterval: wrestlerDuration, target: self, selector: #selector(Mole.MoleDead), userInfo: nil, repeats: false)
    }
    
    func CancelWrestlerTimer(){
        mole.isPaused = false
        wrestlerTimer.invalidate()
    }
    
    //-----------------
    ///Override Methods
    //-----------------
    
    override func copy(with zone: NSZone?) -> Any {
        return Mole(position: self.position, mode: self.currentMode)
    }
    
    
    
}

