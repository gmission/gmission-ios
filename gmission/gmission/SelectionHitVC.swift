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

}

class SelectionHitVC: HitVC {
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    
    var selectionVM:SelectionHitVM{return vm as! SelectionHitVM}
    
    @IBOutlet weak var selectionTableView: UITableView!
    @IBOutlet weak var requesterBar: UIToolbar!
    
    @IBOutlet weak var answerLimitLabel: UILabel!
    @IBOutlet weak var hitStatusLabel: UILabel!
    @IBOutlet weak var hitCreatedOn: UILabel!
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    let binder:TableBinder<Selection> = TableBinder<Selection>()
    
    override func viewDidLayoutSubviews() {
        self.descriptionLabel.contentOffset = CGPointZero;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        titleLabel.text = vm.hit.title
        descriptionLabel.text = vm.hit.description
        self.hitStatusLabel.text = vm.hit.status
        self.hitCreatedOn.text = vm.hit.created_on
        selectionTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        var answerLimit:String
        if vm.hit.min_choices == vm.hit.max_choices{
            answerLimit = "\(vm.hit.min_choices) answer"
        }else{
            answerLimit = "\(vm.hit.min_choices) to \(vm.hit.max_choices) answers"
        }
        answerLimitLabel.text = "Choose \(answerLimit) from below."
        
        self.binder.bind(selectionTableView, items: self.vm.selections, refreshFunc: vm.loadSelections)
        self.binder.cellFunc = { indexPath in
            let selection = self.vm.selections[indexPath.row]
            let cellId =  "textSelectionCell"
            let cell = self.selectionTableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
            cell.textLabel?.text = selection.brief
            if self.vm.hasAnswered{
                let answeredSelections = self.vm.answers.array.map{$0.selection_id}
                print("answered", answeredSelections, selection.id )
                if answeredSelections.contains(selection.id){
                    cell.detailTextLabel?.text = "✓"
                    cell.detailTextLabel?.textColor = UIColor.grayColor()
                }
            }else if self.vm.isRequester{
                print("TODO")
                let count = self.vm.answers.array.filter{$0.selection_id==selection.id}.count
                cell.detailTextLabel?.text = "\(count)"
            }
            
            print("selection: \(selection.id) \(selection.brief)")
            return cell
        }
        self.binder.selectionFunc = { indexPath in
            if self.vm.canAnswer{
                print("can answer")
                let cell = self.selectionTableView.cellForRowAtIndexPath(indexPath)!
                let selection = self.vm.selections[indexPath.row]
    //            if selection.id
                if self.vm.selected.contains(selection.id){
                    cell.detailTextLabel?.text = ""
                    self.vm.selected.removeAtIndex(self.vm.selected.indexOf(selection.id)!)
                }else{
                    cell.detailTextLabel?.text =  "✓"
                    cell.detailTextLabel?.textColor = UIColor.blueColor()
                    self.vm.selected.append(selection.id)
                }
                
                print("select selection: \(selection.id) \(selection.brief)")
            }else{
                print("cannot answer")
            }
        }
        
        self.showHUD("Loading HITs...")
        binder.refreshThen { () -> Void in
            self.hideHUD()
            
            self.requesterBar.hidden = !self.vm.isRequester
            
            if self.vm.closed{
                self.closeBtn.enabled = false
                self.navigationItem.rightBarButtonItem?.title = "Closed"
                self.navigationItem.rightBarButtonItem?.enabled = false
            } else if self.vm.hasAnswered{
                print("answered")
                self.navigationItem.rightBarButtonItem?.title = "Answered"
                self.navigationItem.rightBarButtonItem?.enabled = false
            }else{
                print("has not answered")
                if self.vm.isRequester{
                    self.navigationItem.rightBarButtonItem?.title = "Requested"
                    self.navigationItem.rightBarButtonItem?.enabled = false
                }else{
                    self.navigationItem.rightBarButtonItem?.title = "Submit"
                    self.navigationItem.rightBarButtonItem?.enabled = true
                }
            }
        }
    }
    
    override func submitAnswer(){
        if vm.selected.count < vm.hit.min_choices{
            self.flashHUD("need to choose more", 1)
            return
        }
        if vm.selected.count > vm.hit.max_choices{
            self.flashHUD("need to choose less", 1)
            return
        }
        
        print("children submit answer, selection")
        for selectionID in vm.selected{
            let answerDict:[String:AnyObject] = ["brief":selectionID, "hit_id":vm.hit.id, "type":"selection", "worker_id":UserManager.currentUser.id]
            let done:F = (selectionID == vm.selected.last!) ? {
                self.viewDidLoad()
                self.viewWillAppear(true)
                } : nil
            vm.postAnswer(Answer(dict: answerDict), done)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("segue of campaign")
        if segue.identifier == "showHit"{
            let hitVC: HitVC = segue.destinationViewController as! HitVC
//            hitVC.vm = HitVM(c: vm.hits[tableView.indexPathForSelectedRow!.row])
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
