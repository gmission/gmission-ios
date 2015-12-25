//
//  SettingManager.swift
//  gmission
//
//  Created by CHEN Zhao on 6/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import Foundation


class SettingManager{
    static let global = SettingManager()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    func save(strVal:String, forKey key:String){
        defaults.setValue(strVal, forKey: key)
    }
    
    func load(key:String)->String?{
        return defaults.valueForKey(key) as? String
    }
    
}

let settings = SettingManager.global