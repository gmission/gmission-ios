//
//  UserVC.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit


class UserVM{
    static let global = UserVM()
    let hits = ArrayForTableView<Hit>()
    
    var user:User{return UserManager.currentUser}
    
    func refresh(done:F = nil){
        self.hits.removeAll()
        let q = [ "filters" : [ ["name":"requester_id","op":"eq","val":UserManager.currentUser.id] ] ]
        
        Hit.query(q) { (hits:[Hit])->Void in
            self.hits.appendContentsOf(hits)
            done?()
        }
    }
    
}

class UserVC: EnhancedVC {
    
    let vm = UserVM.global
    let binder:TableBinder<Hit> = TableBinder<Hit>()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "User"
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout"), animated: true)
        self.usernameLabel.text = self.vm.user.username
        vm.user.refresh{
            self.emailLabel.text = self.vm.user.email
            self.creditLabel.text = String(self.vm.user.credit)
        }
        binder.bind(tableView, items: vm.hits, refreshFunc: vm.refresh)
        binder.cellFunc = { indexPath in
            let hit = self.vm.hits[indexPath.row]
            let cell = self.tableView.dequeueReusableCellWithIdentifier("hitCell", forIndexPath: indexPath)
            customizeHitCell(hit, cell)
            return cell
        }
        
        binder.selectionFunc = { indexPath in
            let hit = self.vm.hits[indexPath.row]
            self.pushHitView(hit)
        }
        
        binder.refreshTableContent()
    }
    
    func logout(){
        UserManager.logout()
        EnhancedVC.showModalLoginView()
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
