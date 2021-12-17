//
//  GameScene.swift
//  MoleyMayhem
//
//  Created by Tom on 05/11/2015.
//  Copyright (c) 2015 Tom. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gsm: GKStateMachine!
    
    let START_LIVES = 5
    let columns = 3
    let rows = 2
    let moleSeparation = 20
    
    let unlockedTypes = GameViewController.userProfile.molesUnlocked
    
    var moleGrid: MoleGrid!
    var heartGrid: NodeGrid!
    var scoreText: SKLabelNode!
    var multiText: SKLabelNode!
    var beginText: AttrText!
    var gameOverBox: TwoButtonTextSprite!
    var pausedBox: TwoButtonTextSprite!
    var pauseButton: TextButtonWithRect!
    let label = SKLabelNode()
    
    var Stats: [String:Int] = [ //Creates a dictionary to contain the In-Game Stats
    "GamesPlayed" : 1,
    "NormalHits" : 0,
    "DummyHits" : 0,
    "ArmourHits" : 0,
    "WrestlerHits" : 0,
    "SisterHits" : 0,
    "BonusHits" : 0,
    "TotalHits" : 0
    ]
    
    var score: Int = 0{
        willSet(newScore){
            scoreText.text = "Score: \(newScore)" //Update score text when score is changed
        } 
    }
    
    var CentrePosition: CGPoint{
        get{
            return CGPoint(x: size.width/2, y: size.height/2)
        }
    }
    
    var Lives: Int = 5 {
        didSet{
            self.UpdateHeartGrid(Lives)
            if Lives < 1{
                self.EndGame(self.score)
            }
            else{
                self.UpdateHeartGrid(Lives)
            }
        }
    }
    
    var Multi: Int = 1{
        willSet(newMulti){
            multiText.text = "\(newMulti)X"
        }
    }
    
    override func didMove(to view: SKView) {
        
        backgroundColor = UIColor.green
        
        //Create Mole Grid
        moleGrid = MoleGrid(columns: columns, rows: rows, separation: moleSeparation, position: CentrePosition, mode: .play)
        addChild(moleGrid)
        
        //Create Life Bar
        heartGrid = NodeGrid(node: SKSpriteNode(imageNamed: "heart"), columns: 5, rows: 1, separation: 5, position: CGPoint(x: 175, y:  500))
        addChild(heartGrid)
        
        //Create Scene Labels
        scoreText = CreateSceneLabel("Score: \(score)", position: CGPoint(x: self.size.width / 2, y: self.size.height - 50))
        multiText = CreateSceneLabel("\(Multi)X", position: CGPoint(x: self.size.width * 0.75, y: self.size.height - 50))
        
        //Create 'Touch To Begin' Box
        beginText = AttrText(text: "TOUCH SCREEN TO BEGIN", tColour: UIColor.red, bColour: UIColor.white, tSize: 70)
        beginText.position = self.CentrePosition
        beginText.zPosition = 10
        addChild(beginText)
        
        //Create 'Game Over' Box
        CreateGameOverBox()
        gameOverBox.run(SKAction.scale(to: 0, duration: 0))
        
        //Create 'Paused' Box + Button
        CreatePausedBox()
        pausedBox.run(SKAction.scale(to: 0, duration: 0))
//        UICreator.CreateButton(pauseButton, text: "||", position: CGPoint(x: (scene?.size.width)! - 50, y: (scene?.size.height)! - 50))
//        pauseButton.fontColor = UIColor.red
        pauseButton = TextButtonWithRect(areaSize: CGSize(width: 200, height: 200), position: CGPoint(x: (scene?.size.width)! - 50, y: (scene?.size.height)! - 25),
                                         text: "||")
        addChild(pauseButton)
        
        //Create Debug Tools
        //CreateDebugCoordLabel()
        
        //Create Game State Manager
        gsm = GKStateMachine(states: [
            BeginState(scene: self),
            GameOverState(scene: self),
            PlayingState(),
            PauseState(scene: self)])
        gsm.enter(BeginState.self)
        
    }
    
    //-----------------
    ///Touches-------
    //-----------------
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Show touch location for development
        if let touch = touches.first{
            let touchLocation = touch.location(in: self)
            let x = Int(touchLocation.x)
            let y = Int(touchLocation.y)
            label.text = "X = \(x) Y = \(y)"
        }
        
    
        //Touch responses for different Game States
        //-----------------------------------------
        switch gsm.currentState{
                
            case is BeginState:
                gsm.enter(PlayingState.self)
            
                //----------------------------------
            case is GameOverState:
                if let touch = touches.first{
                    let positionInBox = touch.location(in: gameOverBox)
                    let touchedNode = gameOverBox.atPoint(positionInBox)
                    if let name = touchedNode.name{
                        switch name{
                            case "Play Again":
                                gsm.enter(BeginState.self)
                            case "Quit":
                                gameOverBox.run(SKAction.sequence([SKAction.scale(to: 0, duration: 0.1),
                                    SKAction.run({self.scene!.view?.presentScene(TitleScene(size: (self.scene?.size)!), transition: SKTransition.doorsCloseHorizontal(withDuration: 1))})]))
                            
                            default:
                                break
                            
                        }
                    }
                }
                
            
                //-----------------------------------
            case is PlayingState:
                
                for touch in touches{
                    //Activate MoleHit if a mole is touched. The touched node will be the mole spritenode rather than the Mole node,
                    //so its parent is returned to access MoleHit
                    let positionInGrid = touch.location(in: moleGrid)
                    let touchedNode = moleGrid.atPoint(positionInGrid)
                    if let name = touchedNode.name{
                        if name == "mole"{
                            let m = touchedNode.parent as! Mole
                            m.MoleHit()
                        }
                    }
                    
                    let positionInPauseButton = touch.location(in: pauseButton)
//                    let touchedNode2 = self.atPoint(positionInPauseButton)
//                    if let name = touchedNode2.name{
//                        if name == pauseButton.name{
//                            gsm.enter(PauseState.self)
//                        }
//                    }
                    if pauseButton.touchArea.contains(positionInPauseButton){
                        gsm.enter(PauseState.self)
                    }
            }
            
                    
                    
                //-----------------------------------
            case is PauseState:
                if let touch = touches.first{
                    let positionInBox = touch.location(in: pausedBox)
                    let touchedNode = pausedBox.atPoint(positionInBox)
                    if let name = touchedNode.name{
                        switch name{
                        case "Continue":
                            gsm.enter(PlayingState.self)
                        case "Quit":
                            pausedBox.run(SKAction.sequence([SKAction.scale(to: 0, duration: 0.1),
                                SKAction.run({self.scene!.view?.presentScene(TitleScene(size: (self.scene?.size)!), transition: SKTransition.doorsCloseHorizontal(withDuration: 1))})]))
                        
                    default:
                        break
                        
                    }
                }
            }
            
            default:
                break
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
    
    //--------------------
    ///Game State Methods-
    //--------------------
    
    func StartTimer(){
        moleGrid.StartTimer()
    }
    
    func Reset(){
        self.score = 0
        self.Lives = 5
        self.Multi = 1
        self.beginText.run(SKAction.scale(to: 1, duration: 0))
        for key in Stats.keys{
            Stats.updateValue(0, forKey: key)
        }
        Stats.updateValue(1, forKey: "GamesPlayed")
    }
    
    //----------------
    ///Private Methods
    //----------------
    
    fileprivate func CreateSceneLabel(_ text: String, position: CGPoint) ->SKLabelNode{
        let label = SKLabelNode()
        label.text = text
        label.position  = position
        label.fontColor = UIColor.red
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 50
        label.zPosition = 9
        
        addChild(label)
        return label
    }
    
    fileprivate func CreateGameOverBox(){
        
        gameOverBox = TwoButtonTextSprite(file: "touchbeginbox", size: CGSize(width: 500, height: 500), text: "Game Over!", Button1Text: "Play Again",
                            Button2Text: "Quit")
        
        let label1 = CreateBoxText(text: "You scored 0 points", name: "scoretext", vertPos: 50)
        gameOverBox.addChild(label1)
        
        let label2 = CreateBoxText(text: "NEW HIGH SCORE!", name: "highscoretext", vertPos: 0)
        gameOverBox.addChild(label2)
        
        let label3 = CreateBoxText(text: "You squished \(Stats["TotalHits"]! as Int) moles", name: "molecounttext", vertPos: -50)
        gameOverBox.addChild(label3)
        
        let label4 = CreateBoxText(text: "NEW MOLE UNLOCKED", name: "newmoletext", vertPos: -100)
        gameOverBox.addChild(label4)
        
        gameOverBox.position = self.CentrePosition
        gameOverBox.zPosition = 10
        addChild(gameOverBox)
    }
    
    fileprivate func CreatePausedBox(){
        
        pausedBox = TwoButtonTextSprite(file: "touchbeginbox", size: CGSize(width: 500, height: 500), text: "Game Paused", Button1Text: "Quit", Button2Text: "Continue")
        pausedBox.position = self.CentrePosition
        pausedBox.zPosition = 10
        addChild(pausedBox)
    }
    
    fileprivate func CreateBoxText(text: String, name: String, vertPos: CGFloat = 0, horPos: CGFloat = 0) -> SKLabelNode{ //Use this for creating Label Nodes in display boxes
        let label = SKLabelNode(text: text)
        label.position = CGPoint(x: 0, y: vertPos)
        label.fontColor = UIColor.black
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 30
        label.zPosition = 9
        label.name = name
        
        return label
    }
    
    fileprivate func CreateDebugCoordLabel(){
        label.position = CGPoint(x: 450, y: 50)
        label.fontColor = UIColor.white
        label.fontName = "Chalkduster"
        label.fontSize = 50.0
        label.zPosition = 100
        addChild(label)
    }
    
    fileprivate func UpdateHeartGrid(_ x: Int){ //This is used by the Lives variable to ensure the hearts displayed reflect the score.
        for i in 0..<heartGrid.grid.count{
            if i < x{
                heartGrid.grid[i].isHidden = false
            }
            else
            {
                heartGrid.grid[i].isHidden = true
            }
        }
    }
    
    fileprivate func PauseMoles(pause: Bool){ //Use this to pause and unpause moles for Paused mode

        moleGrid.isPaused = pause
    }
    
    fileprivate func EndGame(_ finalScore: Int){ //This is called by the Lives programmable variable
        
        moleGrid.Reset()
        
        //Update GameOverBox score text
        let scoreText = gameOverBox.childNode(withName: "scoretext") as! SKLabelNode
        scoreText.text = "You scored \(finalScore) points"
        
        //Update GameOverBox molecount text
        let moleCountText = gameOverBox.childNode(withName: "molecounttext") as! SKLabelNode
        moleCountText.text = "You squished \(Stats["TotalHits"]! as Int) moles"
        
        //Get reference to highscoretext on gameOverBox
        let highScoreText = gameOverBox.childNode(withName: "highscoretext") as! SKLabelNode
        
        //Dispaly highscoretext if new high score
        if GameViewController.userProfile.UpdateHighScore(finalScore){
            highScoreText.isHidden = false
        }
        else{
            highScoreText.isHidden = true
        }
        
        //Update UserProfile Stats with Game Stats
        GameViewController.userProfile.UpdateStats(Stats)
        
        //After updating stats, check whether any new moles are unlocked and show label is they are
        //This also actually marks the mole as unlokced 
        let newMoleText = gameOverBox.childNode(withName: "newmoletext") as! SKLabelNode
        if GameViewController.userProfile.NewUnlockedMolesCheck(){
            newMoleText.isHidden = false
        }
        else {
            newMoleText.isHidden = true
        }
        
        gsm.enter(GameOverState.self)
    }
   
    
    
}

//-------------------------------------------------------

//----------------------
///----GAME STATES------
//----------------------

class PlayingState: GKState{
    
}

class BeginState: GKState{
    
    var scene: GameScene!
    
    init(scene: GameScene) {
        super.init()
        self.scene = scene
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.Reset()
    }
    
    override func willExit(to nextState: GKState) {
        scene.beginText.run(SKAction.scale(to: 0, duration: 0.1))
        scene.StartTimer()
    }
    
}

class PauseState: GKState{
    
    var scene: GameScene!
    
    init(scene: GameScene){
        super.init()
        self.scene = scene
        
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.moleGrid.PauseGrid(paused: true)
        scene.pausedBox.run(SKAction.scale(to: 1, duration: 0.5))
    }
    
    override func willExit(to nextState: GKState) {
        scene.moleGrid.PauseGrid(paused: false)
        scene.pausedBox.run(SKAction.scale(to: 0, duration: 0.1))
    }
    
    
}

class GameOverState: GKState{
    
    var scene: GameScene!
    
    init(scene: GameScene) {
        super.init()
        self.scene = scene
    }
    
    override func didEnter(from previousState: GKState?) {
        scene.gameOverBox.run(SKAction.scale(to: 1, duration: 0.5))
    }
    
    override func willExit(to nextState: GKState) {
        scene.gameOverBox.run(SKAction.scale(to: 0, duration: 0.1))
    }
    
}

