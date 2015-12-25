//
//  HTTP.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON


let defaultUrlPrefix = "http://lccpu3.cse.ust.hk/gmission-dev/"

class HTTP{
    typealias OnFailFunc = (Int?, String?)->()
    
    static func isAuthError(statusCode:Int, content:String)->Bool{
        if statusCode == 401{
            return true
        }
        if statusCode == 400{
            if content.containsString("Invalid JWT"){
                return true
            }
        }
        return false
    }
    
    static func handleErrors(url:String, statusCode:Int?, content:String?){
        print("Global handler: status: \(statusCode) content: \(content)")
        
        if let statusCode=statusCode{
            if statusCode == 503{
                
                EnhancedVC.showAlert("Server is unavailable now.", msg: "Please try again later.")
            }else if isAuthError(statusCode, content: content!){
                print("auth error happened..")
                EnhancedVC.showModalLoginView()
            }else{
                EnhancedVC.showAlert("HTTP Error \(statusCode)", msg: "request \(url) failed: \(content!)")
            }
        }else{
            
            EnhancedVC.showAlert("Network error", msg: "Please try again later.")
        }
    }
    
    static func newRequest(method: Alamofire.Method, var _ url: String, parameters: [String : AnyObject]? = nil, encoding: Alamofire.ParameterEncoding = .JSON, headers: [String : String]? = nil, onFail:OnFailFunc? = nil) -> Alamofire.Request{
        if !(url.hasPrefix("http://") || url.hasPrefix("https://")){
            url = "\(defaultUrlPrefix)\(url)"
        }
        print("HTTP request: \(url)  \(parameters)")
        let alamofireRequest = Alamofire.request(method, url, parameters: parameters, encoding:encoding, headers:headers).validate(statusCode: 200..<300).response { (req, resp, data, err) -> Void in
            print("status: \(resp?.statusCode)")
            if let e = err{
                print("\(url) error: \(e)")
                let content = NSString(data: data!, encoding:NSUTF8StringEncoding) as? String
                if let onFail = onFail{
                    onFail(resp?.statusCode, content)
                }else{
                    HTTP.handleErrors(url, statusCode: resp?.statusCode, content: content )
                }
            }
        }
        return alamofireRequest
    }
    
    static func requestJSON(method: Alamofire.Method, _ url:String, paras:[String:AnyObject]?, onFail:OnFailFunc?, _ onSucceed:(JSON)->()) -> Request{
        var header = [String : String]()
        let token = UserManager.global.token
        if token != ""{
            header["Authorization"] = "gMission \(token)"
        }
        return newRequest(method, url, parameters: paras, headers:header, onFail:onFail).responseJSON{
            response in
            switch response.result{
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print("HTTP return:", json)
                    onSucceed(json)
                }
            case .Failure(let error):
                print(error)
            }
        }
        
     }
    
}