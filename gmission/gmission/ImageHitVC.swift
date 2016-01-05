//
//  CampaignList.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit

import SwiftyJSON
import WebImage


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
    
    var imageURL:String {return HTTP.imageURLForName(self.jsonDict["value"].stringValue)}
}


class ImageHitVM:HitVM{
    
    func refresh(done:F = nil){
        self.loadAnswers(done)
    }
}

class ImageAnswerCell:UITableViewCell{
    @IBOutlet weak var answerImageView: UIImageView!
    @IBOutlet weak var createdOnLabel: UILabel!
    @IBOutlet weak var workerNameLabel: UILabel!
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
    
    let binder:TableBinder<Answer> = TableBinder<Answer>()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = vm.hit.title
        self.textView.text = vm.hit.description
    
        self.binder.bind(answerTableView, items: self.vm.answers, refreshFunc: vm.refresh)
        self.binder.cellFunc = { indexPath in
            let answer = self.vm.answers[indexPath.row]
            let cell = self.answerTableView.dequeueReusableCellWithIdentifier("imageAnswerCell", forIndexPath: indexPath) as! ImageAnswerCell
            
            Attachment.getOne(answer.att_id, done: { (att:Attachment) -> Void in
                let url = NSURL(string: att.imageURL)
                print("set url \(url)")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.answerImageView?.contentMode = UIViewContentMode.ScaleAspectFit
                    let placeHolder = UIImage(named: "imgPlaceHolder")
                    print("placeHolder\(placeHolder)")
                    cell.answerImageView?.sd_setImageWithURL(url, placeholderImage: placeHolder)
                })
            })
            cell.workerNameLabel.text = "worker"
            cell.createdOnLabel.text = answer.created_on
            return cell
        }
        
        
        self.showHUD("Loading...")
        binder.refreshThen { () -> Void in
            self.hideHUD()
//        if vm.isRequester{
//            print("is requester")
//            viewForWorker.hidden = true
//            answerTableView.hidden = false
//            switchToRequester()
//        }else{
            print("is NOT requester")
            if self.vm.hasAnswered{
                print("answered")
                self.viewForWorker.hidden = true
                self.answerTableView.hidden = false
            }else{
                print("has not answered")
                self.viewForWorker.hidden = false
                self.answerTableView.hidden = true
            }
//        }
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
                    print("attachment posted")
                    let answerDict:[String:AnyObject] = ["brief":"", "hit_id":self.vm.hit.id, "type":"image", "attachment_id":att.id,"worker_id":UserManager.currentUser.id]
                    self.vm.postAnswer(Answer(dict: answerDict)){
                        print("answer posted")
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
