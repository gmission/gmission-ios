//
//  LoginVC.swift
//  gmission
//
//  Created by CHEN Zhao on 6/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit

class LoginVC: EnhancedVC {
    
    @IBOutlet weak var loginUsernameField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var registerEmailField: UITextField!
    @IBOutlet weak var registerUsernameField: UITextField!
    @IBOutlet weak var registerPasswordField: UITextField!
    
    @IBAction func loginBtnClicked(sender: AnyObject) {
    }
    
    @IBAction func registerBtnClicked(sender: AnyObject) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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