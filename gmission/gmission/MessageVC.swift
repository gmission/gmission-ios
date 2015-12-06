//
//  MessageList.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit

import SwiftyJSON



class MessageVM{
    let message:Message
    let hits = ArrayForTableView<Hit>()
    
    init(m:Message){
        message = m
    }
    
//    func refresh(done:F = nil){
//        Hit.query{ (hits:[Hit])->Void in
//            self.hits.appendContentsOf(hits)
//        }
//    }
}

class MessageVC: EnhancedVC {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    var vm:MessageVM! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = vm.message.title
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
