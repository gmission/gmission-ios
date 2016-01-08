//
//  AskVC.swift
//  gmission
//
//  Created by CHEN Zhao on 3/1/2016.
//  Copyright © 2016 CHEN Zhao. All rights reserved.
//

import Foundation

import GoogleMaps


class AskVC:EnhancedVC, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "a new HIT"
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Request", style: UIBarButtonItemStyle.Plain, target: self, action: "request"), animated: true)
    }
    
    @IBOutlet weak var creditTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var maxAnswerTextField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    var locName:String! = nil
    var clLoc: CLLocation! = nil
    
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
    
    func hitDict()->[String:AnyObject]{
        let dict:[String:AnyObject] = ["type":"image", "title":titleTextField.text!, "description":descriptionTextField.text!, "required_answer_count":maxAnswerTextField.text!, "credit":creditTextField.text!, "requester_id":UserManager.currentUser.id]
        return dict
    }
    
    func request(){
        LocationManager.global.newCustomLocation(locName, clLoc: clLoc){ location in
            var dict = self.hitDict()
            dict["location_id"] = location.id
            if let image = self.imageView.image{
                Attachment.newWithImage(image) { (att) -> () in
                    dict["attachment_id"] = att.id
                    print("got att id")
                    Hit.postOne(Hit(dict: dict), done: { (hit:Hit) -> Void in
                    print("asked with image")
                    self.navigationController?.popViewControllerAnimated(true)
                    })
                }
            }else{
                Hit.postOne(Hit(dict: dict), done: { (hit:Hit) -> Void in
                    print("asked without image")
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }
        }
    }
}