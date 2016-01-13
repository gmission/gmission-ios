//
//  MessageList.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit


class Message:JsonEntity{
    override class var urlname:String{return "message"}
    var type:String{return jsonDict["type"].stringValue}
    var status:String{return jsonDict["status"].stringValue}
    var content:String{return jsonDict["content"].stringValue}
    var att_type:String{return jsonDict["att_type"].stringValue}
    var attachment:String{return jsonDict["attachment"].stringValue}
    
    var created_on:String{return jsonDict["created_on"].stringValue}
}

class MessageListVM{
    static let global = MessageListVM()
    let messages = ArrayForTableView<Message>()
    
    func refresh(done:F = nil){
        let q = [ "filters" : [ ["name":"receiver_id","op":"eq","val":UserManager.currentUser.id] ],
                "order_by":[ ["field":"created_on", "direction":"desc"] ] ]
        
        Message.query(q) { (messages:[Message])->Void in
            self.messages.removeAll()
            self.messages.appendContentsOf(messages)
            done?()
        }
    }
}

class MessageListVC: EnhancedVC {
    @IBOutlet weak var tableView: UITableView!
    let vm = MessageListVM.global
    let binder = TableBinder<Message>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Messages"
        binder.bind(tableView, items: vm.messages, refreshFunc: vm.refresh)
        binder.cellFunc = { indexPath in
            let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            let message = self.vm.messages[indexPath.row]
            cell.textLabel?.text = message.content
            if message.status == "new"{
                cell.textLabel?.textColor = UIColor.blueColor()
            }else{
                cell.textLabel?.textColor = UIColor.blackColor()
            }
            return cell
        }
        binder.selectionFunc = {indexPath in
            let msg = self.vm.messages[indexPath.row]
            msg.jsonDict["status"] = "read"
            Message.put(msg){
                print("msg put done")
            }
            if msg.att_type == "HIT"{
                self.gotoHitView(Int(msg.attachment)!)
            }else{
                print("invalid type")
            }
        }
        self.showHUD("Loading ...")
        binder.refreshThen { () -> Void in
            self.hideHUD()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    func gotoHitView(hitId:Int){
        print("goto hit view")
        self.showHUD("Loading..")
        Hit.getOne(hitId) { (hit:Hit) -> Void in
            self.hideHUD()
            self.pushHitView(hit)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("segue")
        if segue.identifier == "showMessage"{
            let messageVC = segue.destinationViewController as! MessageVC
            messageVC.vm = MessageVM(m: vm.messages[tableView.indexPathForSelectedRow!.row])
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
