//
//  LoginVC.swift
//  gmission
//
//  Created by CHEN Zhao on 6/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit


class LoginVM{
    static let global = LoginVM()
    
    var loginUsername:String!
    var loginPassword:String!
    func login(ok:F){
        let paras = ["username":loginUsername, "password":loginPassword]
        HTTP.requestJSON(.POST, "user/auth", paras) { (json) -> () in
            print("login OK", json)
            UserManager.global.afterLogin(self.loginUsername, pwd: self.loginPassword, tkn:json["token"].stringValue)
            ok?()
        }
    }
    
    var regUsername:String!
    var regPassword:String!
    var regEmail:String!
    func register(ok:F){
        let paras = ["username":regUsername, "password":regPassword, "email":regEmail]
        HTTP.requestJSON(.POST, "user/register", paras) { (json) -> () in
            print("register OK", json)
            self.loginUsername = self.regUsername
            self.loginPassword = self.regPassword
            self.login(ok)
        }
    }
    
}

class LoginVC: EnhancedVC, UITextFieldDelegate {
    let vm = LoginVM.global
    
    @IBOutlet weak var loginUsernameField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var registerEmailField: UITextField!
    @IBOutlet weak var registerUsernameField: UITextField!
    @IBOutlet weak var registerPasswordField: UITextField!
    
    @IBAction func loginBtnClicked(sender: AnyObject) {
        vm.loginUsername = loginUsernameField.text
        vm.loginPassword = loginPasswordField.text
        vm.login { () -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            print("loginVC removed")
        }
    }
    
    @IBAction func registerBtnClicked(sender: AnyObject) {
        vm.regUsername = registerUsernameField.text
        vm.regPassword = registerPasswordField.text
        vm.regEmail = registerEmailField.text
        vm.register { () -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            print("loginVC removed")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textFields = [loginUsernameField, loginPasswordField, registerEmailField, registerUsernameField, registerPasswordField]
        let defaultTexts = ["zchenah", "123456", "zchenah@ust.hk", "zchenah", "123456"]
        
        zip(textFields, defaultTexts).forEach{$0.text = $1}
        textFields.forEach{$0.delegate = self}
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField{
        case loginUsernameField:
            loginPasswordField.becomeFirstResponder()
        case loginPasswordField:
            loginBtnClicked(loginPasswordField)
        case registerEmailField:
            registerUsernameField.becomeFirstResponder()
        case registerUsernameField:
            registerPasswordField.becomeFirstResponder()
        case registerPasswordField:
            registerBtnClicked(registerPasswordField)
        default: break
        }
        return false
    }
    
    override func viewWillAppear(animated: Bool) {
        loginUsernameField.becomeFirstResponder()
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