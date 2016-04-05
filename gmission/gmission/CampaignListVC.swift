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
        let q = [ "order_by":[ ["field":"created_on", "direction":"desc"] ] ]
        
        Campaign.query(q){ (campaigns:[Campaign])->Void in
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
