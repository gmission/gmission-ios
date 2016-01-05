//
//  CampaignList.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit

import SwiftyJSON

typealias F = (()->Void)?



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



class CampaignCell:UITableViewCell{
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var workerCountLabel: UILabel!
    @IBOutlet weak var hitCountLabel: UILabel!
}

class CampaignListVM{
    static let global = CampaignListVM()
    let campaigns = ArrayForTableView<Campaign>()
    
    func fillFakeContent(){
        self.campaigns.appendContentsOf([Campaign(jsonDict:["title":"a title"]),
            Campaign(jsonDict:["title":"b title"]),
            Campaign(jsonDict:["title":"c title"]),
            Campaign(jsonDict:["title":"d title"]),
            Campaign(jsonDict:["title":"e title"]),
            Campaign(jsonDict:["title":"f title"]),
            Campaign(jsonDict:["title":"g title"])])
    }
    
    func refresh(done:F = nil){
//        fillFakeContent()
//        done?()
//        return;
        Campaign.getAll{ (campaigns:[Campaign])->Void in
            self.campaigns.removeAll()
            self.campaigns.appendContentsOf(campaigns)
            done?()
        }
    }
}

class CampaignListVC: EnhancedVC {
    @IBOutlet weak var tableView: UITableView!
    let vm = CampaignListVM.global
    let binder:TableBinder<Campaign> = TableBinder<Campaign>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        EnhancedVC.showModalLoginView()
        self.title   = "Campaigns"
//        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        binder.bind(tableView, items: vm.campaigns, refreshFunc: vm.refresh)
        binder.cellFunc = { indexPath in
            let cell = self.tableView.dequeueReusableCellWithIdentifier("campaignCell", forIndexPath: indexPath) as! CampaignCell
            let campaign = self.vm.campaigns[indexPath.row]
            cell.titleLabel?.text = campaign.title
            cell.detailLabel?.text = campaign.description
            campaign.refreshDetail{
                cell.hitCountLabel.text = "\(campaign.hitCount)"
                cell.workerCountLabel.text = "\(campaign.workerCount)"
            }
            return cell
        }
//        binder.selectionFunc = {indexPath in
//            self.gotoCampaignView(self.vm.campaigns[indexPath.row])
//        }
        
        binder.refreshTableContent()
        
//        EnhancedVC.showModalLoginView()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("segue")
        if segue.identifier == "showCampaign"{
            let campaignVC: CampaignVC = segue.destinationViewController as! CampaignVC
            campaignVC.vm = CampaignVM(c: vm.campaigns[tableView.indexPathForSelectedRow!.row])
        }
    }
    
//    func gotoCampaignView(campaign:Campaign){
//        let naviVC = UINavigationController(rootViewController: self)
//        campaignVC.vm =
//        naviVC.pushViewController(campaignVC, animated: true)
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
