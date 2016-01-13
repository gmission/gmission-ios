//
//  UserManager.swift
//  gmission
//
//  Created by CHEN Zhao on 6/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import Foundation
import SwiftyJSON



class User{
//    class UserModel:JsonEntity{
//        override class var urlname:String{return "user"}
//    }

    func refresh(done:F){
        let paras = ["username":username, "password":password]
        print(paras)
        HTTP.requestJSON(.POST, "user/auth", paras) { (json) -> () in
            print("refresh OK", json)
            UserManager.global.afterLogin(json, pwd: self.password)
            self.email = json["email"].stringValue
            self.credit = json["credit"].intValue
            done?()
        }
    }

    var credit:Int!
    var email:String!

//    var model:UserModel! = nil
    
    var id:Int = 0
    var token:String = ""
    var username:String = ""
    var password:String = ""
    init(id:Int, username:String, password:String,token:String){
        self.id = id
        self.token = token
        self.username = username
        self.password = password
    }
}


class BaiduPushInfo:JsonEntity{
    override class var urlname:String {return "baidu_push_info"}
    
}


class UserManager{
    static let global = UserManager()
    static var currentUser:User! = nil
    
    static func logout(){
        settings.save("", forKey: "loginUsername")
        settings.save("", forKey: "loginPassword")
        settings.save("", forKey: "loginToken")
        settings.save("", forKey: "loginUserID")
        settings.save("", forKey: "baidu_info_posted")
        currentUser = nil
    }
    
    func postPushInfo(){
        let bdPosted = settings.load("baidu_info_posted")
        
        if bdPosted == ""{
            let uid = UserManager.currentUser.id
            let buid = SettingManager.global.load("baidu_user_id") ?? ""
            let bcid = SettingManager.global.load("baidu_channel_id") ?? ""
            let baiduPushInfo = BaiduPushInfo(jsonDict:["baidu_user_id":buid, "baidu_channel_id":bcid, "user_id":uid, "type":"ios", "is_valid":true])
            BaiduPushInfo.postOne(baiduPushInfo) { (bpi:BaiduPushInfo) -> Void in
                print("bpi posted")
                settings.save("true", forKey: "baidu_info_posted")
            }
        }
    }
    
    func saveUserInfo(user:User){
        settings.save(user.username, forKey: "loginUsername")
        settings.save(user.password, forKey: "loginPassword")
        settings.save(user.token, forKey: "loginToken")
        settings.save("\(user.id)", forKey: "loginUserID")
    }
    
    func loadUserInfo(){
        let username = settings.load("loginUsername") ?? ""
        let password = settings.load("loginPassword") ?? ""
        let token = settings.load("loginToken") ?? ""
        let id = Int(settings.load("loginUserID") ?? "0") ?? 0
        
        if id != 0 {
            UserManager.currentUser = User(id:id, username:username, password:password, token:token)
        }else{
            print("no login user")
        }
    }
    
    func afterLogin(json:JSON, pwd:String){
        let user = User(id: json["id"].intValue, username: json["username"].stringValue, password: json["password"].stringValue, token: json["token"].stringValue)
        
        user.password = pwd
        user.credit = json["credit"].intValue
        user.email = json["email"].stringValue
        
        UserManager.currentUser = user
        saveUserInfo(user)
        postPushInfo()
    }
    
    
    init(){
    }
    
}


//user = UserManager.global
