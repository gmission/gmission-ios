//
//  UserManager.swift
//  gmission
//
//  Created by CHEN Zhao on 6/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import Foundation


class User{
    
    static var current:User{
        return User()
    }
}

class UserManager{
    static let global = UserManager()
    
    var token:String = ""
    var username:String = ""
    var password:String = ""
    
    func saveUserInfo(){
        settings.save(username, forKey: "loginUsername")
        settings.save(password, forKey: "loginPassword")
        settings.save(token, forKey: "loginToken")
    }
    
    func loadUserInfo(){
        username = settings.load("loginUsername") ?? ""
        password = settings.load("loginPassword") ?? ""
        token = settings.load("loginToken") ?? ""
    }
    
    func afterLogin(un:String, pwd:String, tkn:String){
        username = un
        password = pwd
        token = tkn
        saveUserInfo()
    }
    
    init(){
        loadUserInfo()
    }
    
}


//user = UserManager.global
