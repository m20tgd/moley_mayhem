//
//  MyFileManager.swift
//  MoleyMayhem
//
//  Created by Tom on 25/02/2016.
//  Copyright © 2016 Tom. All rights reserved.
//

import Foundation

open class MyFileManager{
    
    static let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    static let fileManager = FileManager.default
    
    //File Reading
    //--------------
    
    open static func GetDictionaryFromFile(_ file: String) -> NSMutableDictionary?{
    
        let filePath = documentDirectory + "/" + file
        
        //File eraser. Uncomment to reset files to those in bundle
//        do { try fileManager.removeItem(atPath: filePath)}
//        catch _ {print(filePath)}
        
        if !fileManager.fileExists(atPath: filePath){ //Check for existing file and create new file from bundle if none exists
            if let bundlePath = Bundle.main.path(forResource: file, ofType: "plist"){
            do{ try fileManager.copyItem(atPath: bundlePath, toPath: filePath)}
            catch _ {print(bundlePath  )}
            }
            else{
                print("File not found in bundle")
            }
            
        }
        
        
        if let dict = NSMutableDictionary(contentsOfFile: filePath){
            return dict
        }
        print("File not found")
        return NSMutableDictionary()
    }
    
    //File Writing
    //------------
    
    open static func WriteDictionaryToFile(_ dict: NSMutableDictionary, file: String){
        
        let filePath = documentDirectory + "/" + file
        
        dict.write(toFile: filePath, atomically: true)
    }
    
    //File Erasing
    //------------
    
    open static func DeleteFile(_ file: String){
        
        let filePath = documentDirectory + "/" + file
        
        do{ try fileManager.removeItem(atPath: filePath)}
        catch _ {print(filePath  )}
    }
    
}
