//
//  InboxListTableViewCell.swift
//  HW03
//
//  Created by student on 8/3/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class InboxListTableViewCell: UITableViewCell {
    let ref = FIRDatabase.database().reference()
    var delegateProp:inboxRecordDelegate?
    var message:Message? {
        didSet {
            let sender = message?.fromUser
            var senderNameVal = ""
            if message?.isRead == "1" {
                isReadField.hidden = true
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
                            self.senderImage?.image = UIImage(data: data!)
                        })
                    }).resume()
                }
                
                self.senderImage.layer.borderWidth = 1
                self.senderImage.layer.masksToBounds = false
                self.senderImage.layer.borderColor = UIColor.blackColor().CGColor
                self.senderImage.layer.cornerRadius = self.senderImage.frame.height/2
                self.senderImage.clipsToBounds = true
            }) { (error) in
                print(error.localizedDescription)
            }
            messageContent.text = message!.messageStr
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBOutlet weak var senderImage: UIImageView!
    
    @IBOutlet weak var isReadField: UIImageView!
    
    @IBOutlet weak var senderName: UILabel!
    
    @IBOutlet weak var messageContent: UILabel!
    
    @IBAction func deleteMessage(sender: UIButton) {
        self.delegateProp!.deleteInboxRecord((message?.key)!)
    }
    
}
