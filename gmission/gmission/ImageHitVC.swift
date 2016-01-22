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




class ImageHitVM:HitVM{
    
}

class ImageAnswerCell:UITableViewCell{
    @IBOutlet weak var answerImageView: UIImageView!
    @IBOutlet weak var createdOnLabel: UILabel!
    @IBOutlet weak var workerNameLabel: UILabel!
    @IBOutlet weak var answerImageButton: UIButton!
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                answerImageView.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                answerImageView.addConstraint(aspectConstraint!)
            }
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
    }
    
    var fullImgMask:UIView = UIView()
    
    @IBAction func fullScreenImage(sender: AnyObject) {
        let fullFrame:CGRect = UIScreen.mainScreen().bounds
        fullImgMask.backgroundColor = UIColor.blackColor()
        fullImgMask.frame = fullFrame
        self.window!.addSubview(fullImgMask)
        let image = self.answerImageButton.imageView?.image
        let imgButton = UIButton(frame: fullFrame)
        imgButton.setImage(image, forState:UIControlState.Normal)
        imgButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        imgButton.backgroundColor = UIColor.clearColor();
        imgButton.addTarget(self, action: "dismissHelper:", forControlEvents: UIControlEvents.TouchUpInside)
        self.window!.addSubview(imgButton)
    }
    
    func dismissHelper(sender:UIButton)
    {
        self.fullImgMask.removeFromSuperview()
        sender.removeFromSuperview()
    }
    

}

class ImageHitVC: HitVC, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    var imageVM:ImageHitVM {return vm as! ImageHitVM}
    @IBOutlet weak var viewForWorker: UIView!
    @IBOutlet weak var answerTableView: UITableView!
    
    @IBOutlet weak var requesterBar: UIToolbar!
//    @IBOutlet weak var hitStatusLabel: UILabel!
//    @IBOutlet weak var hitCreatedOn: UILabel!
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    
    let binder:TableBinder<Answer> = TableBinder<Answer>()
    override func viewDidLoad() {
        super.viewDidLoad()
//        answerTableView.rowHeight = UITableViewAutomaticDimension
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        footerView.backgroundColor = UIColor.clearColor()
        answerTableView.tableFooterView = footerView
    
        self.binder.bind(answerTableView, items: self.vm.answers, refreshFunc: vm.loadAnswers)
        self.binder.cellFunc = { indexPath in
            let answer = self.vm.answers[indexPath.row]
            let cell = self.answerTableView.dequeueReusableCellWithIdentifier("imageAnswerCell", forIndexPath: indexPath) as! ImageAnswerCell
            
            Attachment.getOne(answer.att_id, done: { (att:Attachment) -> Void in
                cell.answerImageButton.simpleSetImage(att.imageURL)
            })
            cell.workerNameLabel.text = ""
            cell.createdOnLabel.text = answer.created_on
            return cell
        }
        
        
        self.showHUD("Loading...")
        binder.refreshThen { () -> Void in
            self.hideHUD()
            
            self.requesterBar.hidden = !self.vm.isRequester
            
            if self.vm.hit.status == "closed"{
                self.closeBtn.enabled = false
                self.viewForWorker.hidden = true
                self.answerTableView.hidden = false
                self.navigationItem.rightBarButtonItem?.title = "Closed"
                self.navigationItem.rightBarButtonItem?.enabled = false
            }else if self.vm.hasAnswered{
                print("answered")
                self.viewForWorker.hidden = true
                self.answerTableView.hidden = false
                self.navigationItem.rightBarButtonItem?.title = "Answered"
                self.navigationItem.rightBarButtonItem?.enabled = false
            }else{
                print("has not answered")
                if self.vm.isRequester{
                    self.viewForWorker.hidden = true
                    self.answerTableView.hidden = false
                    self.navigationItem.rightBarButtonItem?.title = "Requested"
                    self.navigationItem.rightBarButtonItem?.enabled = false
                }else{
                    self.viewForWorker.hidden = false
                    self.answerTableView.hidden = true
                    self.navigationItem.rightBarButtonItem?.title = "Submit"
                    self.navigationItem.rightBarButtonItem?.enabled = true
                }
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
//        self.textView.contentOffset = CGPointZero;
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
    
    @IBAction override func closeHit(){
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
