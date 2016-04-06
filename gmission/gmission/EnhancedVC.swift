//
//  EnhancedVC.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit
import ImageViewer

    class NaiveProvider:ImageProvider{
        var image:UIImage!
        func provideImage(completion: UIImage? -> Void) {
            completion(image)
        }
        
        func provideImage(atIndex index: Int, completion: UIImage? -> Void){
            
        }
    }

class EnhancedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    static func showAlert(title:String, msg:String){
        
    }
    
    let hud = MBProgressHUD()
    
    func showHUD(content:String){
        self.view.addSubview(self.hud)
        hud.mode = MBProgressHUDMode.Indeterminate
        hud.labelText = content
        hud.show(true)
    }
    func hideHUD(){
        self.hud.removeFromSuperview()
    }
    func flashHUD(content:String, _ time:Double){
        self.view.addSubview(self.hud)
        hud.labelText = content
        hud.mode = MBProgressHUDMode.Text
        hud.show(true)
        hud.hide(true, afterDelay: time)
    }
    
    
    func pushHitView(hit:Hit){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch hit.type{
        case "text":
            let vc = storyboard.instantiateViewControllerWithIdentifier("textHitVC") as! TextHitVC
            vc.vm = TextHitVM(h:hit)
            self.navigationController!.pushViewController(vc, animated:true)
        case "image":
            let vc = storyboard.instantiateViewControllerWithIdentifier("imageHitVC") as! ImageHitVC
            vc.vm = ImageHitVM(h:hit)
            self.navigationController!.pushViewController(vc, animated:true)
        case "selection":
            let vc = storyboard.instantiateViewControllerWithIdentifier("selectionHitVC") as! SelectionHitVC
            vc.vm = SelectionHitVM(h:hit)
            self.navigationController!.pushViewController(vc, animated:true)
        default:
            return
        }
    }
    
    static func showModalLoginView(){
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginVC")
        topViewController()?.presentViewController(loginVC, animated: true, completion: { () -> Void in
            print("popped out loginVC")
        })
    }
    
    
    func showFullImageView(image:UIImage){
        let imageProvider = NaiveProvider()
        imageProvider.image = image
        
        let buttonConfiguration = CloseButtonAssets(normal:UIImage(named: "close_normal")!, highlighted:UIImage(named: "close_highlighted")!)
        let configuration = ImageViewerConfiguration(imageSize: image.size, closeButtonAssets: buttonConfiguration)
        
        let imageViewer = ImageViewer(imageProvider: imageProvider, configuration: configuration, displacedView: self.view)
        
        self.presentImageViewer(imageViewer)
    }
    
    
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
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
