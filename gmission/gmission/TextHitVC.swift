//
//  CampaignList.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit

import SwiftyJSON


class TextHitVM:HitVM{
//    func refresh(done:F = nil){
//        Hit.query{ (hits:[Hit])->Void in
//            self.hits.appendContentsOf(hits)
//        }
//    }
}

class TextHitVC: HitVC {
//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var answerLabel: UILabel!
    var vm:TextHitVM! = nil
    @IBOutlet weak var requesterBar: UIToolbar!
    @IBOutlet weak var hitStatusLabel: UILabel!
    @IBOutlet weak var hitCreatedOn: UILabel!
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    
    @IBOutlet weak var answerTableView: UITableView!
    let binder:TableBinder<Answer> = TableBinder<Answer>()
    
    override func viewDidLayoutSubviews() {
        self.descriptionLabel.contentOffset = CGPointZero;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = vm.hit.title
        descriptionLabel.text = vm.hit.description
        self.hitStatusLabel.text = vm.hit.status
        self.hitCreatedOn.text = vm.hit.created_on
        answerTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.binder.bind(answerTableView, items: self.vm.answers, refreshFunc: vm.loadAnswers)
        self.binder.cellFunc = { indexPath in
            let answer = self.vm.answers[indexPath.row]
            let cellId =  "textAnswerCell"
            let cell = self.answerTableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
            cell.textLabel?.text = answer.brief
            cell.detailTextLabel?.text = answer.created_on
            print("answer: \(answer.id) \(answer.brief) \(answer.created_on)")
            return cell
        }
        self.showHUD("Loading...")
        binder.refreshThen{
            self.hideHUD()
            self.requesterBar.hidden = !self.vm.isRequester
            
            if self.vm.hit.status == "closed"{
                self.closeBtn.enabled = false
                 self.answerTextField.hidden = true
                self.answerLabel.hidden =  true
                self.answerTableView.hidden = false
                self.navigationItem.rightBarButtonItem?.title = "Closed"
                self.navigationItem.rightBarButtonItem?.enabled = false
            }else if self.vm.hasAnswered{
                print("answered")
                 self.answerTextField.hidden = true
                self.answerLabel.hidden =  true
                self.answerTableView.hidden = false
                self.navigationItem.rightBarButtonItem?.title = "Answered"
                self.navigationItem.rightBarButtonItem?.enabled = false
            }else{
                print("has not answered")
                if self.vm.isRequester{
                    self.answerLabel.hidden =  true
                    self.answerTextField.hidden = true
                    self.answerTableView.hidden = false
                    self.navigationItem.rightBarButtonItem?.title = "Requested"
                    self.navigationItem.rightBarButtonItem?.enabled = false
                }else{
                    self.answerTableView.hidden = true
                    self.answerTextField.hidden = false
                    self.answerLabel.hidden =  false
                    self.navigationItem.rightBarButtonItem?.title = "Submit"
                    self.navigationItem.rightBarButtonItem?.enabled = true
                }
            }
        }
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        print("segue of campaign")
//        if segue.identifier == "showHit"{
//            let hitVC: HitVC = segue.destinationViewController as! HitVC
////            hitVC.vm = HitVM(c: vm.hits[tableView.indexPathForSelectedRow!.row])
//        }
//    }
    
    override func submitAnswer(){
        print("children submit answer")
        let answerDict:[String:AnyObject] = ["brief":answerTextField.text!, "hit_id":vm.hit.id, "type":"text", "worker_id":UserManager.currentUser.id]
        vm.postAnswer(Answer(dict: answerDict)){
           self.viewDidLoad()
            self.viewWillAppear(true)
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
