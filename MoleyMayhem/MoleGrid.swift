//
//  MoleGrid.swift
//  MoleyMayhem
//
//  Created by Tom on 05/11/2015.
//  Copyright © 2015 Tom. All rights reserved.
//

import SpriteKit

class MoleGrid : NodeGrid{
    
    let MAX_MOLES : Int = 3
    let MAX_SECONDS : Float = 1.75
    let MIN_SECONDS : Float = 0.75
    let MAX_TIMER_LENGTH : Float = 2
    let MIN_TIMER_LENGTH : Float = 0.5
    
    //--------------
    ///Properties---
    //--------------
    
    fileprivate var moleTimer: Timer = Timer()
    fileprivate var practiseTimer = Timer()
    
    //--------------
    ///Initialiser--
    //--------------
    
    init(columns: Int, rows: Int, separation: Int, position: CGPoint, mode: MoleMode){
        super.init(node: Mole(position: CGPoint.zero, mode: mode), columns: columns, rows: rows, separation: separation, position: position)
        
        self.xScale = 1.0
        self.yScale = 1.0
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //----------------
    ///Methods
    //----------------
    
    //Gallery Methods
    //---------------
    
    func ShowUnlockedMoles(){
        
        let unlockedMoles = GameViewController.userProfile.molesUnlocked
        let types = MoleType.ArrayOfTypes()
        
        var i = 0 //Grid index. Is increased by one for very cycle
        
        guard types.count > rows * columns else{
        for type in types{
            let m = grid[i] as! Mole
            m.DisplayMole(type)
            if unlockedMoles.value(forKey: type.rawValue) as! Bool == false{
                m.Locked = true
                m.ShowQuestionMark()
                }
                i+=1
            }
            return 
        }
    }
    
    //Practise Methods
    //----------------
    
    
    func StartPractiseTimer(_ mole: Mole){
        practiseTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(MoleGrid.FirePractiseTimer), userInfo: mole, repeats: false)
    }
    
    func FirePractiseTimer(){
        if let m = ChooseRandomMole(){
            let dataMole = practiseTimer.userInfo as! Mole //Called DataMole to differentiate from mole chosen from grid
            m.MoleAppears(2, type: dataMole.CurrentMoleType)
            if m.CurrentMoleType == .Sister{
                if let m2 = ReturnEmptyHole(butNot: m){
                     m2.MoleAppears(2, type: .Sister)
                    m2.PairedMole = m
                    m.PairedMole = m2
                }
            }
            StartPractiseTimer(dataMole)
        }
    }
    
    fileprivate func ShowMole(_ type: MoleType, duration: Float){
        let mole = ChooseRandomMole()
        mole?.MoleAppears(duration, type: type)
    }
    
    
    //Gameplay methods
    //----------------
    
    func StartTimer(){
        SetMoleTimer()
    }
    
    func PauseGrid(paused: Bool){
        self.isPaused = paused
        HideMoles(hide: paused)
        if paused{
            moleTimer.invalidate()
        }
        else{
            SetMoleTimer()
        }
    }
    
    fileprivate func HideMoles(hide: Bool){
        for mole in grid{
            let m = mole as! Mole
            m.mole.isHidden = hide
        }
    }
    
    fileprivate func ChooseRandomMole() -> Mole?{
        
        var mole: Mole
        
        if EmptyHoles().count > 0{
        repeat{
            let randomIndex = Int(Maths.RandomInt(grid.count))
            mole = grid[randomIndex] as! Mole
        } while mole.HoleEmpty == false
        
        return mole
        }
        return nil
    }
    
    fileprivate func SetMoleTimer(){
        //Get random number between range for time until next moles
        let randomNumber = (Maths.RandomFloatBetweenLimits(MIN_TIMER_LENGTH * 2, max: (MAX_TIMER_LENGTH * 2)+1)) / 2
        //Turn float into time interval
        let duration = TimeInterval(randomNumber)
        //Start timer
        moleTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(MoleGrid.ChooseMolesToShow), userInfo: nil, repeats: false)
    }
    
    
    
    func Reset(){
        moleTimer.invalidate()
        for node in grid{
            let mole = node as! Mole
            mole.MoleReset()
        }
    }
    
    func ChooseMolesToShow(){ //Do not make private so timer can access it
        let numberOfMoles = Maths.RandomInt(MAX_MOLES) + 1 //Choose random number of moles up to max amount
        
        for _ in 1...numberOfMoles{
            let secondsToShow = Maths.RandomFloatBetweenLimits(MIN_SECONDS, max: MAX_SECONDS) //Chose random number of seconds up to max
            if let mole = ChooseRandomMole(){
                mole.RandomMoleAppears(secondsToShow)
            }
        }
        
        SetMoleTimer()
    }
    
    fileprivate func EmptyHoles() ->[Mole] { //Returns an array of all the empty holes
        var holes = [Mole]()
        for m in grid{
            let mole = m as! Mole
            if mole.HoleEmpty{
                holes.append(mole)
            }
        }
        return holes
    }
    
    func TypeAlreadyActive(_ type: MoleType) -> Bool{ //Use this for seeing if there is already a mole of a certain type active, Makes sure that certain types of mole
        for obj in grid{                            //don't have more than one active at a time.
            let mole = obj as! Mole
            if mole.CurrentMoleType == type{
                return true
            }
        }
        return false
    }
    
    func ReturnEmptyHole() -> Mole?{ //Returns a random empty hole or nil if there are no empty holes
        let holes = EmptyHoles()
        if holes.count > 0{
            let randomIndex = Maths.RandomInt(holes.count)
            return holes[randomIndex]
        }
        return nil
    }
    func ReturnEmptyHole(butNot m: Mole) -> Mole?{ //THis version will return any empty hole as long as it is not the passed one
                                                    //which prevents Sister mole from pairing with itself
        let holes = EmptyHoles()
        var randomIndex = 0
        
        if holes.count > 1{
            repeat{
            randomIndex = Maths.RandomInt(holes.count)
            }while holes[randomIndex] == m
            return holes[randomIndex]
        }
        else if holes.count == 1{
            if holes[0] != m{
                return holes[randomIndex]
            }
        }
        return nil
    }
    
}
