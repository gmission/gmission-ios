//
//  CampaignList.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit

import SwiftyJSON


class HitListVM{
    let hits = ArrayForTableView<Hit>()
    
    init(){
    }
    
    func refresh(done:F = nil){
        self.hits.removeAll()
        let q = [ "filters" : [ ["name":"location_id","op":"neq","val":"null"] ] ]
        
        Hit.query(q){ (hits:[Hit])->Void in
            self.hits.appendContentsOf(hits)
            done?()
        }
    }
}

class HitListVC: EnhancedVC {
    @IBOutlet weak var tableView: UITableView!
    
    var vm = HitListVM()
    let binder:TableBinder<Hit> = TableBinder<Hit>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        binder.bind(tableView, items: vm.hits, refreshFunc: vm.refresh)
        binder.cellFunc = { indexPath in
            let hit = self.vm.hits[indexPath.row]
//            let cellMapping = ["image":"imageCell", "selection":"selectionCell", "text":"textCell"]
            let cellId = "hitCell"// cellMapping[hit.type] ?? "imageCell"
            let cell = self.tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
            cell.textLabel?.text = hit.title
            return cell
        }
        binder.selectionFunc = { indexPath in
            let hit = self.vm.hits[indexPath.row]
            self.pushHitView(hit)
        }
        binder.refreshTableContent()
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
