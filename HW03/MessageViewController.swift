//
//  MessageViewController.swift
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

protocol messageReceiverDelegate {
    func setMessageReceiver(receivingUser: User)
}

class MessageViewController: UIViewController, messageReceiverDelegate {
    
    var toUser:User?
    var fromUser:FIRUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
    }
    
    func loadUI() {
        if toUser != nil {
            selectUsersBtn.hidden = true
            toUserImage.hidden = false
            toUserName.hidden = false
            toUserName.text = (toUser?.firstName)! + " " + (toUser?.lastName)!
            
            toUserImage.contentMode = .ScaleAspectFill
            let profileURL = toUser!.profileImageURL
            if profileURL != "" {
                let url = NSURL(string: profileURL)
                NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.toUserImage?.image = UIImage(data: data!)
                    })
                }).resume()
            }
            toUserImage.layer.borderWidth = 1
            toUserImage.layer.masksToBounds = false
            toUserImage.layer.borderColor = UIColor.blackColor().CGColor
            toUserImage.layer.cornerRadius = toUserImage.frame.height/2
            toUserImage.clipsToBounds = true
        }
    }
    
    @IBAction func cancelMessage(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitMessage(sender: UIButton) {
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.label.text = "Loading"
        
        let ref = FIRDatabase.database().reference()
        let msgText = messageEditor.text
        let cDate = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .MediumStyle
        let dateString = formatter.stringFromDate(cDate)
        
        //ref.child("Messages").childByAutoId().setValue(["sender": fromUser?.uid,"receiver": toUser?.key,"message": msgText, "date":dateString, "isRead":"0"])
        ref.child("Messages").childByAutoId().setValue(["sender": fromUser?.uid,"receiver": toUser?.key,"message": msgText, "date":dateString, "isRead":"0"]) { (error, ref) in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let userListVC = segue.destinationViewController as? UsersListTableViewController {
            userListVC.delegateObj = self
        }
    }
    
    @IBOutlet weak var messageEditor: UITextView!
    
    @IBOutlet weak var selectUsersBtn: UIButton!
    
    @IBAction func selectUsers(sender: UIButton) {
    }
    
    @IBOutlet weak var toUserImage: UIImageView!
    
    @IBOutlet weak var toUserName: UILabel!
    
    func setMessageReceiver(receivingUser: User) {
        toUser = receivingUser
        fromUser = FIRAuth.auth()?.currentUser
        loadUI()
    }
}
