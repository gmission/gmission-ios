//
//  MessageList.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit


class Message:JsonEntity{
    override class var urlname:String{return "Message"}
    var title:String{return jsonDict["title"].stringValue}
}

class MessageListVM{
    static let global = MessageListVM()
    let messages = ArrayForTableView<Message>()
    
    func refresh(done:F = nil){
        self.messages.removeAll()
        
        self.messages.appendContentsOf([Message(jsonDict:["title":"a title"]),
            Message(jsonDict:["title":"b title"]),
            Message(jsonDict:["title":"c title"]),
            Message(jsonDict:["title":"d title"]),
            Message(jsonDict:["title":"e title"]),
            Message(jsonDict:["title":"f title"]),
            Message(jsonDict:["title":"g title"])])
        done?()
        return;
        
        Message.getAll{ (messages:[Message])->Void in
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
        
        //        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        binder.bind(tableView, items: vm.messages, refreshFunc: vm.refresh)
        binder.cellFunc = { indexPath in
            let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            let message = self.vm.messages[indexPath.row]
            cell.textLabel?.text = message.title
            return cell
        }
        //        binder.selectionFunc = {indexPath in
        //            self.gotoMessageView(self.vm.Messages[indexPath.row])
        //        }
        
        binder.refreshTableContent()
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
