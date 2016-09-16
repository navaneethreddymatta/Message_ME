//
//  MessageDetailViewController.swift
//  HW03
//
//  Created by student on 8/3/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class MessageDetailViewController: UIViewController {
    var message:Message?

    @IBOutlet weak var imageViewField: UIImageView!

    @IBOutlet weak var senderName: UILabel!
    
    @IBOutlet weak var messageContent: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let ref = FIRDatabase.database().reference()
        let sender = message?.fromUser
        var senderNameVal = ""
        if message?.isRead == "0" {
            message?.isRead = "1"
            ref.child("Messages").child(message!.key).child("isRead").setValue("1")
        }
        ref.child("Users").child(sender!).observeEventType(.Value, withBlock: { (snapshot) -> Void in
            senderNameVal = ((snapshot.value!["firstName"] as? String)!) + " " + ((snapshot.value!["lastName"] as? String)!)
            self.senderName.text = senderNameVal
            let profileURL = (snapshot.value!["profileImageURL"] as? String)!
            if profileURL != "" {
                let url = NSURL(string: profileURL)
                NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.imageViewField?.image = UIImage(data: data!)
                    })
                }).resume()
            }
            
            self.imageViewField.layer.borderWidth = 1
            self.imageViewField.layer.masksToBounds = false
            self.imageViewField.layer.borderColor = UIColor.blackColor().CGColor
            self.imageViewField.layer.cornerRadius = self.imageViewField.frame.height/2
            self.imageViewField.clipsToBounds = true
        }) { (error) in
            print(error.localizedDescription)
        }
        messageContent.text = message!.messageStr
    
        
    }
}
