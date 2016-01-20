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
    
    func refresh(done:F = nil){
        self.loadAnswers(done)
    }
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
        print("full")
        
        let fullFrame:CGRect = UIScreen.mainScreen().bounds
        fullImgMask.backgroundColor = UIColor.blackColor()
        fullImgMask.frame = fullFrame
        self.window!.addSubview(fullImgMask)
//        let imageView = UIImageView(frame: fullFrame)
        
//        self.window!.addSubview(self.fullImgBlurMask)
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
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    var vm:ImageHitVM! = nil
    @IBOutlet weak var viewForWorker: UIView!
    @IBOutlet weak var answerTableView: UITableView!
    
    @IBOutlet weak var requesterBar: UIToolbar!
    @IBOutlet weak var hitStatusLabel: UILabel!
    @IBOutlet weak var hitCreatedOn: UILabel!
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    
    let binder:TableBinder<Answer> = TableBinder<Answer>()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = vm.hit.title
        self.textView.text = vm.hit.description
        self.hitStatusLabel.text = vm.hit.status
        self.hitCreatedOn.text = vm.hit.created_on
        
//        answerTableView.estimatedRowHeight = 300
//        answerTableView.rowHeight = UITableViewAutomaticDimension
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        footerView.backgroundColor = UIColor.clearColor()
        answerTableView.tableFooterView = footerView
    
        self.binder.bind(answerTableView, items: self.vm.answers, refreshFunc: vm.refresh)
        self.binder.cellFunc = { indexPath in
            let answer = self.vm.answers[indexPath.row]
            let cell = self.answerTableView.dequeueReusableCellWithIdentifier("imageAnswerCell", forIndexPath: indexPath) as! ImageAnswerCell
            
            Attachment.getOne(answer.att_id, done: { (att:Attachment) -> Void in
                let url = NSURL(string: att.imageURL)
                print("set url \(url)")
                
                    cell.answerImageButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                
                    let placeHolder = UIImage(named: "imgPlaceHolder")!
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.answerImageButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                    print("placeHolder\(placeHolder)")
                    cell.answerImageButton.sd_setImageWithURL(url, forState: .Normal, placeholderImage: placeHolder)
//                        let aspect = image.size.width / image.size.height
//                        print("aspect \(aspect)")
////
////                        for c in cell.constraints{
////                        }
//                        cell.aspectConstraint = NSLayoutConstraint(item: cell.answerImageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: cell.answerImageView, attribute: NSLayoutAttribute.Height, multiplier: aspect, constant: 0.0)
//                        cell.aspectConstraint = NSLayoutConstraint(item: cell.answerImageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: cell.answerImageView, attribute: NSLayoutAttribute.Width, multiplier: 1/aspect, constant: 0.0)
//                        cell.answerImageView.image = image
//                    })
                })
            })
            cell.workerNameLabel.text = "worker"
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
