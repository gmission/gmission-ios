//
//  CampaignList.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit

import SwiftyJSON


class CampaignVM{
    let campaign:Campaign
    let hits = ArrayForTableView<Hit>()
    
    init(c:Campaign){
        campaign = c
    }
    
    func refresh(done:F = nil){
        let q = [ "filters" : [ ["name":"campaign_id","op":"eq","val":campaign.id] ] ]
        
        Hit.query(q){ (hits:[Hit])->Void in
            self.hits.removeAll()
            self.hits.appendContentsOf(hits)
            done?()
        }
    }
}

class CampaignVC: EnhancedVC {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    var vm:CampaignVM! = nil
    let binder:TableBinder<Hit> = TableBinder<Hit>()

    override func viewDidLayoutSubviews() { // stupid bug
        super.viewDidLayoutSubviews()
        self.descriptionLabel.setContentOffset(CGPoint.zero, animated: false)
        self.descriptionLabel.scrollRangeToVisible(NSRange(location:0, length:0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = vm.campaign.title
        
        descriptionLabel.scrollEnabled = false
        if vm.campaign.description != ""{
            descriptionLabel.text = vm.campaign.description
        }else{
            descriptionLabel.text = "This campaign does not have more information."
        }
        
        binder.bind(tableView, items: vm.hits, refreshFunc: vm.refresh)
        binder.cellFunc = { indexPath in
            let hit = self.vm.hits[indexPath.row]
            let cellMapping = ["image":"imageCell", "selection":"selectionCell", "text":"textCell"]
            let cellId = cellMapping[hit.type] ?? "imageCell"
            let cell = self.tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
            cell.textLabel?.text = hit.title
            return cell
        }
        
        self.showHUD("Loading HITs...")
        binder.refreshThen { () -> Void in
            self.hideHUD()
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("segue of campaign -> hit")
        switch segue.identifier!{
            case "showTextHit":
            let hitVC: TextHitVC = segue.destinationViewController as! TextHitVC
            hitVC.vm = TextHitVM(h: vm.hits[tableView.indexPathForSelectedRow!.row])
            case "showImageHit":
            let hitVC: ImageHitVC = segue.destinationViewController as! ImageHitVC
            hitVC.vm = ImageHitVM(h: vm.hits[tableView.indexPathForSelectedRow!.row])
            case "showSelectionHit":
            let hitVC: SelectionHitVC = segue.destinationViewController as! SelectionHitVC
            hitVC.vm = SelectionHitVM(h: vm.hits[tableView.indexPathForSelectedRow!.row])
        default:
            let hitVC: SelectionHitVC = segue.destinationViewController as! SelectionHitVC
            hitVC.vm = SelectionHitVM(h: vm.hits[tableView.indexPathForSelectedRow!.row])
            
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
