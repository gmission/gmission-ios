//
//  AppDelegate.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit
import GoogleMaps




let g_application = UIApplication.sharedApplication()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
    GMSServices.provideAPIKey("AIzaSyDnkJRC5XLTRA46VFRSxJzoE8b0Nsj3SVk");
        
        UserManager.global.loadUserInfo()
        
        setupPushNoti(application, launchOptions)
        handlePushNoti(launchOptions)
        return true
    }
    
    
    func handlePushNoti(launchOptions: [NSObject: AnyObject]?){
        let userInfo = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]
        if userInfo != nil{
            print("got some thing pushed", userInfo)
        }
    }
    
    
    func setupPushNoti(application:UIApplication, _ launchOptions: [NSObject: AnyObject]?){
        BPush.registerChannel(launchOptions, apiKey: "LQpGHpuTYA0lkjQj6zY3ZVfB", pushMode: BPushMode.Development, withFirstAction: "OK", withSecondAction: "Cancel", withCategory: "fuck", isDebug: false)
        
        if application.respondsToSelector("registerUserNotificationSettings:") {
            if #available(iOS 8.0, *) {
                let types:UIUserNotificationType = ([.Alert, .Sound, .Badge])
                let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
                application.registerUserNotificationSettings(settings)
                application.registerForRemoteNotifications()
            } else {
                application.registerForRemoteNotificationTypes([.Alert, .Sound, .Badge])
            }
        }
        else {
            // Register for Push Notifications before iOS 8
            application.registerForRemoteNotificationTypes([.Alert, .Sound, .Badge])
        }
        
//        BPush.unbindChannelWithCompleteHandler { (result, error) -> Void in
//            print("unbind then bind again:")
//        }
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("didRegisterForRemoteNotificationsWithDeviceToken:" + deviceToken.description)
        BPush.registerDeviceToken(deviceToken)
        BPush.bindChannelWithCompleteHandler { (result, error) -> Void in
            print("BPush.bindChannelWithCompleteHandler", result)
            if result != nil{
                let resDict = result as! [String:AnyObject]
                let baidu_user_id = resDict["user_id"] as? String ?? ""
                let baidu_channel_id = resDict["channel_id"] as? String ?? ""
                SettingManager.global.save(baidu_user_id, forKey: "baidu_user_id")
                SettingManager.global.save(baidu_channel_id, forKey: "baidu_channel_id")
                BPush.setTag("gmission", withCompleteHandler: { (result, error) -> Void in
                    print("BPush.setTag", result)
                })
                
                if UserManager.currentUser != nil{
                    UserManager.global.postPushInfo()
                }
            }
        }
        
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("didFailToRegisterForRemoteNotificationsWithError \(error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("didReceiveRemoteNotification:" + userInfo.description)
        let alert:NSString = userInfo["aps"]?.objectForKey("alert") as! NSString
        //        var alert:NSString = (userInfo["aps"] as NSDictionary).objectForKey("alert")
        
        if(application.applicationState == UIApplicationState.Active){
            let alertView: UIAlertView = UIAlertView(title: "gMission Notice:", message: alert as String, delegate: self, cancelButtonTitle: "OK")
            alertView.show()
            NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
        }else{
            print("applictaion state inactive")
        }
        BPush.handleNotification(userInfo)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

