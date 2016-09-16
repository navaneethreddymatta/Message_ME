//
//  UserProfileViewController.swift
//  HW03
//
//  Created by student on 8/3/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import MBProgressHUD

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameField: UILabel!
  
    @IBOutlet weak var emailField: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    let imagePicker = UIImagePickerController()
    let ref = FIRDatabase.database().reference()
    
    @IBAction func changeProfilePhoto(sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }

    @IBOutlet weak var messageUser: UIBarButtonItem!
    
    @IBOutlet weak var profilePic: UIButton!
    
    var curUser = FIRAuth.auth()?.currentUser
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.text = (user?.firstName)! + " " + (user?.lastName)!
        emailField.text = user?.email
        if curUser!.email == user!.email {
            profilePic.hidden = false
            self.navigationItem.rightBarButtonItem = nil
        }
        profileImage.contentMode = .ScaleAspectFill
        let profileURL = user!.profileImageURL
        if profileURL != "" {
            let url = NSURL(string: profileURL)
            NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                print("---------------")
                print(url)
                if error != nil {
                    print("ERROR")
                    print(error)
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    print("done")
                    self.profileImage?.image = UIImage(data: data!)
                })
            }).resume()
        }
        
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.blackColor().CGColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.label.text = "Loading"
        
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] {
            selectedImageFromPicker = editedImage as? UIImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] {
            selectedImageFromPicker = originalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            self.profileImage.image = selectedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        let imageName = NSUUID().UUIDString
        let storageRef = FIRStorage.storage().reference().child("\(imageName).png")
        if let uploadData = UIImagePNGRepresentation(profileImage.image!) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error)
                    return
                } else {
                    print("updated")
                    let profileImageURLVal = metadata?.downloadURL()?.absoluteString
                    self.ref.child("Users").child(self.curUser!.uid).child("profileImageURL").setValue(profileImageURLVal)
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let messageVC = segue.destinationViewController as? MessageViewController {
            messageVC.toUser = user
            messageVC.fromUser = curUser
        }
    }
}
