//
//  CampaignList.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit

import SwiftyJSON


class SelectionHitVM:HitVM{
    let selections = ArrayForTableView<Hit>()
    
//    func refresh(done:F = nil){
//        Hit.query{ (hits:[Hit])->Void in
//            self.hits.appendContentsOf(hits)
//        }
//    }
}

class SelectionHitVC: EnhancedVC {
//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    var vm:SelectionHitVM! = nil
//    let binder:TableBinder<Hit> = TableBinder<Hit>()

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = vm.hit.title
        descriptionLabel.text = vm.hit.description
        
//        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        binder.bind(tableView, items: vm.hits, refreshFunc: vm.refresh)
//        binder.cellFunc = { indexPath in
//            let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
//            let hit = self.vm.hits[indexPath.row]
//            cell.textLabel?.text = hit.title
//            return cell
//        }
//        binder.selectionFunc = {indexPath in
//            self.gotoHitView(self.vm.hits[indexPath.row])
//        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("segue of campaign")
        if segue.identifier == "showHit"{
            let hitVC: HitVC = segue.destinationViewController as! HitVC
//            hitVC.vm = HitVM(c: vm.hits[tableView.indexPathForSelectedRow!.row])
        }
    }
    
    
    func gotoHitView(hit:Hit){
        
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
