//
//  Entities.swift
//  gmission
//
//  Created by CHEN Zhao on 20/1/2016.
//  Copyright © 2016 CHEN Zhao. All rights reserved.
//

import Foundation

import SwiftyJSON




class JsonEntity{
    class var urlname:String{
        return "name"
    }
    class var restUrl:String{
        return "rest/\(urlname)"
    }
    class var evalUrl:String{
        return "rest/eval/\(urlname)"
    }
    
    // these restful function can be put anywhere..
    static func getAll<T:JsonEntity>(done:([T])->Void){
        HTTP.requestJSON(.GET, T.restUrl) { (jsonRes) -> () in
            let tArray = jsonRes["objects"].arrayValue.map({ (json) -> T in
                return T(jsonDict: json)
            })
            done(tArray)
        }
    }
    
    static func getOne<T:JsonEntity>(id:Int, done:(T)->Void){
        HTTP.requestJSON(.GET, "\(T.restUrl)/\(id)"){ (jsonRes) -> () in
            done(T(jsonDict: jsonRes))
            //            let tArray = jsonRes["objects"].arrayValue.map({ (json) -> T in
            //                return T(jsonDict: json)
            //            })
            //            done(tArray)
        }
    }
    
    static func query<T:JsonEntity>(q:[String:AnyObject], done:([T])->Void){
        let jsonQ = JSON(q)
        HTTP.requestJSON(.GET, T.restUrl, ["q": "\(jsonQ)"], .URL, nil) { (jsonRes) -> () in
            let tArray = jsonRes["objects"].arrayValue.map({ (json) -> T in
                return T(jsonDict: json)
            })
            done(tArray)
        }
    }
    
    class func queryJSON<T:JsonEntity>(q:[String:AnyObject], done:(JSON, T?)->Void){ // the last T? is for template
        let jsonQ = JSON(q)
        HTTP.requestJSON(.GET, T.restUrl, ["q": "\(jsonQ)"], .URL, nil) { (jsonRes) -> () in
            done(jsonRes, nil)
        }
    }
    
    static func postOne<T:JsonEntity>(t:T, done:F){
        HTTP.requestJSON(.POST, T.restUrl, t.jsonDict.dictionaryObject!, .JSON, nil) { (json) -> () in
            print("posted \(json)")
            done?()
        }
    }
    
    static func postOne<T:JsonEntity>(t:T, done:(T)->Void){
        HTTP.requestJSON(.POST, T.restUrl, t.jsonDict.dictionaryObject!, .JSON, nil) { (json) -> () in
            print("posted \(json)")
            let retT = T(jsonDict: json)
            done(retT)
        }
    }
    
    
    static func put<T:JsonEntity>(t:T, done:F){
        HTTP.requestJSON(.PUT, "\(T.restUrl)/\(t.id)", t.jsonDict.dictionaryObject!, .JSON, nil) { (json) -> () in
            print("put \(json)")
            done?()
        }
    }
    
    var jsonDict:JSON
    var id:Int{return jsonDict["id"].intValue}
    //    var dictToPost:[String:AnyObject]{return [String:AnyObject]()}
    
    required init(jsonDict:JSON){
        self.jsonDict = jsonDict
    }
    
    convenience init(dict:[String:AnyObject]){
        let json = JSON(dict)
        self.init(jsonDict:json)
    }
}

class Campaign:JsonEntity{
    override class var urlname:String{return "campaign"}
    var title:String{return jsonDict["title"].stringValue}
    var description:String{return jsonDict["brief"].stringValue}
    
    var hitCount:Int = 0
    var workerCount:Int = 0
    
    func refreshDetail(done:F){
        //"functions":[["name": "count", "field": "id"] ],  functions does not help as restless does not support function with filter
        let q = [ "filters" :  [["name":"campaign_id","op":"eq","val":self.id] ],
            "limit":0]
        
        Hit.queryJSON(q){ (json:JSON, _:Hit?)->Void in
            self.hitCount = json["num_results"].intValue
            print("hitcount: \(self.hitCount) \(json)")
            
            CampaignUser.count(self.id, done: { (workerCount) -> () in
                self.workerCount = workerCount
                print("workercount: \(self.workerCount)")
                done?()
            })
        }
    }
}


class CampaignUser:JsonEntity{
    override class var urlname:String{return "campaign_user"}
    
    class func count(campaignId:Int, done:(Int)->()){
        let q = ["limit" : 1,
            "filters" :  [["name":"campaign_id","op":"eq","val":campaignId],
                ["name":"role_id","op":"eq","val":2] ] ] // warning: hardcode
        CampaignUser.queryJSON(q) { (json, t:CampaignUser?) -> Void in
            print("campaign user query: \(json)")
            done(json["num_results"].intValue)
        }
    }
}


class Coordinate:JsonEntity{
    override class var urlname:String{return "coordinate"}
    
}

class Location:JsonEntity{
    override class var urlname:String{return "location"}
    var coordinate_id:Int{return jsonDict["coordinate_id"].intValue}
    var coord:Coordinate?
    var lat:Double {return (coord?.jsonDict["latitude"].doubleValue)!}
    var lon:Double {return (coord?.jsonDict["longitude"].doubleValue)!}
    var z:Double {return (coord?.jsonDict["altitude"].doubleValue)!}
    
    func refreshCoordinate(done:F){
        Coordinate.getOne(coordinate_id) { (crd:Coordinate) -> Void in
            self.coord = crd
            done?()
        }
    }
}

class Hit:JsonEntity{
    override class var urlname:String{return "hit"}
    var title:String{return jsonDict["title"].stringValue}
    var description:String{return jsonDict["description"].stringValue}
    var type:String{return jsonDict["type"].stringValue}
    var requester_id:Int{return jsonDict["requester_id"].intValue}
    var required_answer_count:Int{return jsonDict["required_answer_count"].intValue}
    var location_id:Int{return jsonDict["location_id"].intValue}
    var status:String{return jsonDict["status"].stringValue}
    var created_on:String{return jsonDict["created_on"].stringValue}
    
    var max_choices:Int{return jsonDict["max_selection_count"].intValue}
    var min_choices:Int{return jsonDict["min_selection_count"].intValue}
    
    var att_id:Int{return jsonDict["attachment_id"].intValue}
    func refreshAttachment(done:F){
        if att_id == 0{
            return
        }
        if self.attachment != nil{
            done?()
        }
        else{
            Attachment.getOne(att_id) { (att:Attachment) -> Void in
                self.attachment = att
                done?()
            }
        }
    }
    var location:Location? = nil
    var attachment:Attachment? = nil
    func refreshLocation(done:F){
        if self.location != nil{
            done?()
        }
        else{
            Location.getOne(location_id) { (loc:Location) -> Void in
                self.location = loc
                loc.refreshCoordinate(done)
            }
        }
    }
}



class Answer:JsonEntity{
    override class var urlname:String{return "answer"}
    
    //    var hit_id:Int
    //    var attachment_id:Int
    //    var worker_id:Int
    //    override var dictToPost:[String:AnyObject]{return jsonDict}
    
    var brief:String{return jsonDict["brief"].stringValue}
    var selection_id:Int{return Int(jsonDict["brief"].string ?? "0") ?? 0}
    var type:String{return jsonDict["type"].stringValue}
    var worker_id:Int{return jsonDict["worker_id"].intValue}
    var att_id:Int{return jsonDict["attachment_id"].intValue}
    var created_on:String{return jsonDict["created_on"].stringValue}
}


class Attachment:JsonEntity{
    override class var urlname:String{return "attachment"}
    var image:UIImage!
    
    static func newWithImage(image:UIImage, done:(Attachment)->()){
        let imageData = UIImageJPEGRepresentation(image, 0.8)!
        HTTP.uploadImage(imageData, fileName: "ios.jpg") { (nameFromServer, error) -> () in
            print("image uploaded")
            let attDict:[String:AnyObject] = ["type":"image", "value":nameFromServer!]
            let att = Attachment(jsonDict: JSON(attDict))
            Attachment.postOne(att) { (att:Attachment) -> Void in
                print("att posted")
                done(att)
            }
        }
    }
    
    var imageURL:String {return HTTP.imageURLForName(self.jsonDict["value"].stringValue)}
}



class Selection:JsonEntity{
    override class var urlname:String{return "selection"}
    var brief:String{return jsonDict["brief"].stringValue}
}




class Message:JsonEntity{
    override class var urlname:String{return "message"}
    var type:String{return jsonDict["type"].stringValue}
    var status:String{return jsonDict["status"].stringValue}
    var content:String{return jsonDict["content"].stringValue}
    var att_type:String{return jsonDict["att_type"].stringValue}
    var attachment:String{return jsonDict["attachment"].stringValue}
    
    var created_on:String{return jsonDict["created_on"].stringValue}
}

