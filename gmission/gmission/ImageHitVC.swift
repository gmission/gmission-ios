//
//  CampaignList.swift
//  gmission
//
//  Created by CHEN Zhao on 4/12/2015.
//  Copyright © 2015 CHEN Zhao. All rights reserved.
//

import UIKit

import SwiftyJSON


class ImageHitVM:HitVM{
    
//    func refresh(done:F = nil){
//        Hit.query{ (hits:[Hit])->Void in
//            self.hits.appendContentsOf(hits)
//        }
//    }
}

class ImageHitVC: HitVC, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    var vm:ImageHitVM! = nil
//    let binder:TableBinder<Hit> = TableBinder<Hit>()
    @IBOutlet weak var viewForWorker: UIView!

    @IBOutlet weak var answerTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = vm.hit.title
        descriptionLabel.text = vm.hit.description
        
        if vm.isRequester{
            viewForWorker.hidden = true
            answerTableView.hidden = false
        }else{
            viewForWorker.hidden = false
            answerTableView.hidden = true
        }
    }
    
    @IBAction func takePhotoClicked(sender: AnyObject) {
        var imagePicker: UIImagePickerController!
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func choosePhotoClicked(sender: AnyObject) {
        var imagePicker: UIImagePickerController!
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageView.image = image
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
