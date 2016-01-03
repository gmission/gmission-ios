//
//  CampaignList.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit

import SwiftyJSON


class Attachment:JsonEntity{
    override class var urlname:String{return "attachment"}
    var image:UIImage!
    
    static func newWithImage(image:UIImage, done:(Attachment)->()){
        let imageData = UIImageJPEGRepresentation(image, 0.8)!
        HTTP.uploadImage(imageData, fileName: "ios.jpg") { (nameFromServer, error) -> () in
            print("image uploaded")
                let attDict:[String:AnyObject] = ["type":"image", "value":nameFromServer!]
                let att = Attachment(jsonDict: JSON(attDict))
                Attachment.postOne(att) { (att:Attachment) -> Void in
                print("att posted")
                    done(att)
            }
        }
    }
}


class ImageHitVM:HitVM{
    
//    func refresh(done:F = nil){
//        Hit.query{ (hits:[Hit])->Void in
//            self.hits.appendContentsOf(hits)
//        }
//    }
}

class ImageHitVC: HitVC, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    var vm:ImageHitVM! = nil
//    let binder:TableBinder<Hit> = TableBinder<Hit>()
    @IBOutlet weak var viewForWorker: UIView!

    @IBOutlet weak var answerTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = vm.hit.title
        self.textView.text = vm.hit.description
        
        if vm.isRequester{
            viewForWorker.hidden = true
            answerTableView.hidden = false
            switchToRequester()
        }else{
            viewForWorker.hidden = false
            answerTableView.hidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.textView.contentOffset = CGPointZero;
    }
    
    var imagePicker: UIImagePickerController!
    @IBAction func takePhotoClicked(sender: AnyObject) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func choosePhotoClicked(sender: AnyObject) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageView.image = image
        imageView.contentMode = .ScaleAspectFit
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func closeHit(){
        print("children close, image")
        vm.hit.jsonDict["status"] = "closed"
        Hit.postOne(vm.hit) { (hit:Hit) -> Void in
            self.vm.hit = hit
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func submitAnswer(){
        print("children submit answer, image")
        if imageView.image == nil{
            self.flashHUD("A photo is needed.", 1)
            return
        }
        self.showHUD("Submitting ..")
        
        let imageData = UIImageJPEGRepresentation(imageView.image!, 0.8)!
        HTTP.uploadImage(imageData, fileName: "ios.jpg") { (nameFromServer, error) -> () in
            if let e = error{
                print("upload image error", e)
            }else{
                let attDict:[String:AnyObject] = ["type":"image", "value":nameFromServer!]
                let att = Attachment(jsonDict: JSON(attDict))
                Attachment.postOne(att) { (att:Attachment) -> Void in
                    let answerDict:[String:AnyObject] = ["brief":"", "hit_id":self.vm.hit.id, "type":"image", "attachment_id":att.id,"worker_id":UserManager.currentUser.id]
                    self.vm.postAnswer(Answer(dict: answerDict)){
                        self.hideHUD()
                        self.flashHUD("Done!", 1)
                        self.viewDidLoad()
                        self.viewWillAppear(true)
                    }
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("segue of campaign")
        if segue.identifier == "showHit"{
//            let hitVC: HitVC = segue.destinationViewController as! HitVC
//            hitVC.vm = HitVM(c: vm.hits[tableView.indexPathForSelectedRow!.row])
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
