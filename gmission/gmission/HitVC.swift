//
//  CampaignList.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit

import SwiftyJSON



class HitVM{
    var hit:Hit
    
    var isRequester:Bool {return hit.requester_id == UserManager.currentUser.id}
    var closed:Bool {return hit.status == "closed"}
    var hasAnswered:Bool {return  answers.array.map{$0.worker_id}.contains(UserManager.currentUser.id) }
    var enoughAnswers:Bool {return  answers.array.count >= hit.required_answer_count }
    var canAnswer:Bool {return !(isRequester || hasAnswered || enoughAnswers || closed) }
    
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
    
    let selections = ArrayForTableView<Selection>()
    
    var selected = [Int]()
    
    func loadSelections(done:F = nil){
        let q = ["filters":[ ["name":"hit_id","op":"eq","val":self.hit.id] ] ]
        Selection.query(q){ (selections:[Selection])->Void in
            self.selections.removeAll()
            self.selections.appendContentsOf(selections)
            
            self.loadAnswers(done)
        }
    }
//    func refresh(done:F = nil){
//        Hit.query{ (hits:[Hit])->Void in
//            self.hits.appendContentsOf(hits)
//        }
//    }
}

extension UIButton{
    func simpleSetImage(urlStr:String){
        let placeHolder = UIImage(named: "imgPlaceHolder")!
        let url = NSURL(string: urlStr)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in  // why? cannot remember..
            self.imageView?.contentMode = .ScaleAspectFit
            self.sd_setImageWithURL(url, forState: .Normal, placeholderImage: placeHolder)
        })
    }
}


class HitContentVC: EnhancedVC {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setHit(hit:Hit){
        statusLabel.text = hit.status
        desTextView.text = hit.description != "" ? hit.description : "This HIT does not have more information."
        datetimeLabel.text = hit.created_on
        
        self.buttonWidth.constant = 0
        hit.refreshAttachment({ () -> Void in
            self.buttonWidth.constant = 80
            self.imgBtn.simpleSetImage(hit.attachment!.imageURL)
        })
        
    }
    
    var fullImgMask:UIView = UIView()
    
    @IBAction func fullScreenImage(sender: AnyObject) {
        let fullFrame:CGRect = UIScreen.mainScreen().bounds
        fullImgMask.backgroundColor = UIColor.blackColor()
        fullImgMask.frame = fullFrame
        view.window!.addSubview(fullImgMask)
        //        let imageView = UIImageView(frame: fullFrame)
        
        //        self.window!.addSubview(self.fullImgBlurMask)
        let image = imgBtn.imageView?.image
        let imgButton = UIButton(frame: fullFrame)
        imgButton.setImage(image, forState:UIControlState.Normal)
        imgButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        imgButton.backgroundColor = UIColor.clearColor();
        imgButton.addTarget(self, action: "dismissHelper:", forControlEvents: UIControlEvents.TouchUpInside)
        view.window!.addSubview(imgButton)
    }
    
    func dismissHelper(sender:UIButton)
    {
        self.fullImgMask.removeFromSuperview()
        sender.removeFromSuperview()
    }
    
    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var desTextView: UITextView!
    @IBOutlet weak var buttonWidth: NSLayoutConstraint!
    @IBOutlet weak var imgBtn: UIButton!
}

class HitVC: EnhancedVC {
    var vm:HitVM! = nil
    var contentVC:HitContentVC{return self.childViewControllers.last as! HitContentVC}
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = vm.hit.title
        contentVC.setHit(vm.hit)
        
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Submit", style: UIBarButtonItemStyle.Plain, target: self, action: "submitAnswer"), animated: true)
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
