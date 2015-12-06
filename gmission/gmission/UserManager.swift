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
    
}


//user = UserManager.global
