//
//  CampaignList.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit

import SwiftyJSON


class Answer:JsonEntity{
    override class var urlname:String{return "answer"}
    
//    var hit_id:Int
//    var attachment_id:Int
//    var worker_id:Int
//    override var dictToPost:[String:AnyObject]{return jsonDict}
    
    var brief:String{return jsonDict["brief"].stringValue}
    var selection_id:Int{return jsonDict["brief"].int ?? 0}
    var type:String{return jsonDict["type"].stringValue}
    var worker_id:Int{return jsonDict["worker_id"].intValue}
    var att_id:Int{return jsonDict["attachment_id"].intValue}
    var created_on:String{return jsonDict["created_on"].stringValue}
}

class HitVM{
    var hit:Hit
    
    var isRequester:Bool {return hit.requester_id == UserManager.currentUser.id}
    var hasAnswered:Bool {return  answers.array.map{$0.worker_id}.contains(UserManager.currentUser.id) }
    var enoughAnswers:Bool {return  answers.array.count >= hit.required_answer_count }
    var canAnswer:Bool {return !(isRequester || hasAnswered || enoughAnswers) }
    
    var answers = ArrayForTableView<Answer>()
    
    init(h:Hit){
        hit = h
    }
    
    func postAnswer(answer:Answer, _ done:F){
        Answer.postOne(answer, done: done)
//        Answer.post
    }
    
    func loadAnswers(done:F){
        var q:[String:AnyObject]
        if isRequester{
            q = ["filters":[ ["name":"hit_id", "op":"eq", "val":hit.id] ] ]
        }else{
            q = ["filters":[ ["name":"hit_id", "op":"eq", "val":hit.id],
                             ["name":"worker_id", "op":"eq", "val":UserManager.currentUser.id] ] ]
        }
        
        Answer.query(q) { (answers:[Answer]) -> Void in
            print("load answers", answers)
            self.answers.removeAll()
            self.answers.appendContentsOf(answers)
            done?()
        }
    }
//    func refresh(done:F = nil){
//        Hit.query{ (hits:[Hit])->Void in
//            self.hits.appendContentsOf(hits)
//        }
//    }
}

class HitVC: EnhancedVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Submit", style: UIBarButtonItemStyle.Plain, target: self, action: "submitAnswer"), animated: true)
//        self.navigationItem.leftBarButtonItem?.width = 80
    }
    
    func switchToRequester(){
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Close this HIT", style: UIBarButtonItemStyle.Plain, target: self, action: "closeHit"), animated: true)
    }
    
    func closeHit(){
        print("parent close")
    }
    
    func submitAnswer(){
        print("parent submit")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
