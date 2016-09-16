//
//  NewForumViewController.swift
//  HW03
//
//  Created by student on 8/5/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import MBProgressHUD

class NewForumViewController: UIViewController {
    let currentUser = FIRAuth.auth()?.currentUser
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelForumCreation(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitForum(sender: AnyObject) {
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.label.text = "Loading"
        
        let ref = FIRDatabase.database().reference()
        let msgText = forumDescription.text
        let cDate = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .MediumStyle
        let dateString = formatter.stringFromDate(cDate)
        //ref.child("Forums").childByAutoId().setValue(["owner": currentUser?.uid,"description": msgText, "date":dateString])
        ref.child("Forums").childByAutoId().setValue(["owner": currentUser?.uid,"description": msgText, "date":dateString]) { (error, ref) in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }

        dismissViewControllerAnimated(true, completion: nil)
    }
   
    @IBOutlet weak var forumDescription: UITextView!
}
