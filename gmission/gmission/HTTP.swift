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
    
    static func newRequest(method: Alamofire.Method, var _ url: String, _ parameters: [String : AnyObject]?, _ encoding: Alamofire.ParameterEncoding, _ headers: [String : String]?, onFail:OnFailFunc?) -> Alamofire.Request{
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
                    print("to global handle error.", "url:", req?.URLString)
                    HTTP.handleErrors(url, statusCode: resp?.statusCode, content: content )
                }
            }
        }
        return alamofireRequest
    }
    
    static func newRequestWithToken(method: Alamofire.Method, _ url: String, _ parameters: [String : AnyObject]?, _ encoding: Alamofire.ParameterEncoding,  onFail:OnFailFunc?) -> Alamofire.Request{
        var headers = [String : String]()
        let token = UserManager.currentUser?.token ?? ""
        if token != ""{
            headers["Authorization"] = "gMission \(token)"
        }
        
        return newRequest(method, url, parameters, encoding, headers, onFail:onFail)
    }
    
    static func requestJSON(method: Alamofire.Method, _ url:String, _ parameters:[String:AnyObject]?=nil, _ encoding:Alamofire.ParameterEncoding = .JSON, _ onFail:OnFailFunc?=nil, _ onJSONSucceed:(JSON)->()) -> Request{
        return newRequestWithToken(method, url, parameters, encoding, onFail:onFail).responseJSON{
            response in
            switch response.result{
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
//                    print("HTTP return:", json)
                    onJSONSucceed(json)
                }
            case .Failure(let error):
                print(error)
            }
        }
        
     }
    
}