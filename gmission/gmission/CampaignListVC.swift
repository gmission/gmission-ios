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

    // these restful function can be put anywhere..
    static func getAll<T:JsonEntity>(done:([T])->Void){
        
        HTTP.requestJSON(.GET, T.restUrl, paras: nil, onFail: nil){ (jsonRes) -> () in
            let tArray = jsonRes["objects"].arrayValue.map({ (json) -> T in
                return T(jsonDict: json)
            })
            done(tArray)
        }
    }
    
    static func getOne<T:JsonEntity>(done:([T])->Void){
        HTTP.requestJSON(.GET, T.restUrl, paras: nil, onFail: nil){ (jsonRes) -> () in
            let tArray = jsonRes["objects"].arrayValue.map({ (json) -> T in
                return T(jsonDict: json)
            })
            done(tArray)
        }
    }
    
    static func query<T:JsonEntity>(done:([T])->Void){
        HTTP.requestJSON(.GET, T.restUrl, paras: nil, onFail: nil){ (jsonRes) -> () in
            let tArray = jsonRes["objects"].arrayValue.map({ (json) -> T in
                return T(jsonDict: json)
            })
            done(tArray)
        }
    }
    
    let jsonDict:JSON
    var id:Int = 0
    
    required init(jsonDict:JSON){
        self.jsonDict = jsonDict
    }
}

class Campaign:JsonEntity{
    override class var urlname:String{return "campaign"}
    var title:String{return jsonDict["title"].stringValue}
    var description:String{return jsonDict["brief"].stringValue}
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
        self.campaigns.removeAll()
//        fillFakeContent()
//        done?()
//        return;
        Campaign.getAll{ (campaigns:[Campaign])->Void in
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
        
//        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        binder.bind(tableView, items: vm.campaigns, refreshFunc: vm.refresh)
        binder.cellFunc = { indexPath in
            let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            let campaign = self.vm.campaigns[indexPath.row]
            cell.textLabel?.text = campaign.title
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
