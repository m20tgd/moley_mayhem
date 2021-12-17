//
//  UserProfile.swift
//  MoleyMayhem
//
//  Created by Tom on 24/02/2016.
//  Copyright © 2016 Tom. All rights reserved.
//

import Foundation

open class UserProfile{
    
    let FileName = "UserData"
    var userData: NSMutableDictionary!
    var molesUnlocked = NSMutableDictionary()
    var stats = NSMutableDictionary()
    
    var HighScore = 0
    
    //---------------
    ///Initialiser---
    //---------------
    
    init(){
        //Get user data from file
        userData = MyFileManager.GetDictionaryFromFile(FileName)
        
        //Get high score from user data
        self.HighScore = userData.object(forKey: "High Score") as! Int

        //Create reference dictionary of which moles are unlocked
        self.molesUnlocked = userData.object(forKey: "Unlocked Moles") as! NSMutableDictionary
        
        //Create reference disctionary of Stats
        self.stats = userData.object(forKey: "Stats") as! NSMutableDictionary
        
        //self.NewUnlockedMolesCheck() //Call this to ensure that at least .Normal and .Dummy are always unlocked
    }
    
    //---------------------------
    
    
    
    
    //---------------------------
    ///Methods for Updating Data-
    //---------------------------
    
    func UpdateHighScore(_ newScore: Int) -> Bool{
        
        //See if score is new high score. Return false if not
        if newScore <= HighScore {
            return false
        }
        
        //Update user data with new high score
        HighScore = newScore
        userData.setObject(HighScore, forKey: "High Score" as NSCopying)
        
        //Save user data as new UserData plist
        MyFileManager.WriteDictionaryToFile(userData, file: FileName)
        
        return true
    }
    
    func UpdateStats(_ newStats: Dictionary<String, Int>){
        
        for key in newStats.keys{
            if let value = self.stats.object(forKey: key){
                let oldValue = value as! Int
                let newValue = oldValue + newStats[key]!
                self.stats.setValue(newValue, forKey: key)
            }
            else { print("Key: " + key + " - Does Not Exist")}
        }
        
        //Save user data as new UserData plist
        MyFileManager.WriteDictionaryToFile(userData, file: FileName)
    }
    
    func UnlockMoleType(_ type: MoleType){
        
        //Set type as unlocked
        molesUnlocked.setValue(true, forKey: type.rawValue)
        
        //Save user data as new UserData plist
        MyFileManager.WriteDictionaryToFile(userData, file: FileName)
        
    }
    
    
    //---------------------------
    ///Methods for checking data-
    //---------------------------
    
    func NewUnlockedMolesCheck() -> Bool{ //Call this to unlock new moles. Returns true if at least one new mole is unlocked
        
        var newMoleUnlocked = false
        
        for type in MoleType.ArrayOfTypes(){
            let unlocked = molesUnlocked.value(forKey: type.rawValue) as! Bool
            if !unlocked{
                let (typeRequired, numberRequired) = type.UnlockCondition
                let numberHit = stats.value(forKey: typeRequired.rawValue + "Hits") as! Int
                if numberHit >= numberRequired{
                    UnlockMoleType(type)
                    newMoleUnlocked = true
                }
            }
        }
        return newMoleUnlocked
    }
    
    func IsTypeUnlocked(type: MoleType) -> Bool{
        return molesUnlocked.value(forKey: type.rawValue) as! Bool
    }
    
}
