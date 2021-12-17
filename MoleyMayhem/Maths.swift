//
//  Maths.swift
//  MoleyMayhem
//
//  Created by Tom on 03/12/2015.
//  Copyright © 2015 Tom. All rights reserved.
//

import Foundation
import SpriteKit

open class Maths{
    
    //----------------
    ///Random Numbers-
    //----------------
    
    open static func RandomInt(_ max: Int) ->Int{
        return Int(arc4random_uniform(UInt32(max)))
    }
    
    open static func RandomFloatBetweenLimits(_ min: Float, max: Float) -> Float{
        
        //Find difference between max and min
        let diff = Double(max - min)
        //Obtain random number up to diff and add min to get a value in the limits provided
        return Float(drand48() * diff + Double(min))
    }
    
    //-----------------
    ///Number Analysis-
    //-----------------
    
    open static func HighValue(_ a: Int, b: Int) -> Int{
        if a > b{
            return a
        }
        else{
            return b
        }
    }

    open static func HighValue(_ a: Float, b:Float) -> Float{
        if a > b{
            return a
        }
        else{
            return b
        }
    }

    open static func HighValue(_ a: CGFloat, b:CGFloat) -> CGFloat{
        if a > b{
            return a
        }
        else{
            return b
        }
   }

}

