//
//  CampaignList.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit

import SwiftyJSON



class Selection:JsonEntity{
    override class var urlname:String{return "selection"}
    var brief:String{return jsonDict["brief"].stringValue}
}

class SelectionHitVM:HitVM{
    let selections = ArrayForTableView<Selection>()
    
    var selected = [Int]()
    
    func refresh(done:F = nil){
        Selection.getAll{ (selections:[Selection])->Void in
            self.selections.appendContentsOf(selections)
            
            let q = ["filters":[ ["name":"hit_id","op":"eq","val":self.hit.id] ] ]
            
            Answer.query(q) { (answers:[Answer]) -> Void in
                print("load answers", answers)
                self.answers.removeAll()
                self.answers.appendContentsOf(answers)
                done?()
            }
        }
    }
}

class SelectionHitVC: HitVC {
//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    
    var vm:SelectionHitVM! = nil
//    let binder:TableBinder<Hit> = TableBinder<Hit>()
    
    @IBOutlet weak var selectionTableView: UITableView!
    let binder:TableBinder<Selection> = TableBinder<Selection>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = vm.hit.title
        descriptionLabel.text = vm.hit.description
        
        
        self.binder.bind(selectionTableView, items: self.vm.selections, refreshFunc: vm.refresh)
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
                }
            }else if self.vm.isRequester{
                print("TODO")
                
            }
            
            print("selection: \(selection.id) \(selection.brief)")
            return cell
            
//            let answer = self.vm.answers[indexPath.row]
//            let cellId =  "textSelectionCell"
//            let cell = self.selectionTableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
//            cell.textLabel?.text = answer.brief
//            cell.detailTextLabel?.text = answer.created_on
//            print("answer: \(answer.id) \(answer.brief) \(answer.created_on)")
//            return cell
        }
        self.binder.selectionFunc = { indexPath in
            if self.vm.canAnswer{
                let cell = self.selectionTableView.cellForRowAtIndexPath(indexPath)!
                let selection = self.vm.selections[indexPath.row]
    //            if selection.id
                if self.vm.selected.contains(selection.id){
                    cell.detailTextLabel?.text = ""
                    self.vm.selected.removeAtIndex(self.vm.selected.indexOf(selection.id)!)
                }else{
                    cell.detailTextLabel?.text =  "✓"
                    self.vm.selected.append(selection.id)
                }
                
                print("select selection: \(selection.id) \(selection.brief)")
            }
        }
        binder.refreshTableContent()
    }
    
    override func submitAnswer(){
        print("children submit answer, selection")
        for selectionID in vm.selected{
            let answerDict:[String:AnyObject] = ["brief":selectionID, "hit_id":vm.hit.id, "type":"text", "worker_id":UserManager.currentUser.id]
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
