//
//  CampaignList.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit

import SwiftyJSON


class Hit:JsonEntity{
    override class var urlname:String{return "hit"}
    var title:String{return jsonDict["title"].stringValue}
    var description:String{return jsonDict["description"].stringValue}
    var type:String{return jsonDict["type"].stringValue}
}

class CampaignVM{
    let campaign:Campaign
    let hits = ArrayForTableView<Hit>()
    
    init(c:Campaign){
        campaign = c
    }
    
    func refresh(done:F = nil){
        self.hits.removeAll()
        Hit.query{ (hits:[Hit])->Void in
            self.hits.appendContentsOf(hits)
            done?()
        }
    }
}

class CampaignVC: EnhancedVC {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    var vm:CampaignVM! = nil
    let binder:TableBinder<Hit> = TableBinder<Hit>()

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = vm.campaign.title
        descriptionLabel.text = vm.campaign.description
        
//        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        binder.bind(tableView, items: vm.hits, refreshFunc: vm.refresh)
        binder.cellFunc = { indexPath in
            let hit = self.vm.hits[indexPath.row]
            let cellMapping = ["image":"imageCell", "selection":"selectionCell", "text":"textCell"]
            let cellId = cellMapping[hit.type] ?? "imageCell"
            let cell = self.tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
            cell.textLabel?.text = hit.title
            return cell
        }
        binder.refreshTableContent()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("segue of campaign -> hit")
        if segue.identifier == "showHit"{
            let hitVC: HitVC = segue.destinationViewController as! HitVC
            hitVC.vm = HitVM(h: vm.hits[tableView.indexPathForSelectedRow!.row])
        }
    }
    

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
