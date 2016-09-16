//
//  ForumsTableViewCell.swift
//  HW03
//
//  Created by student on 8/5/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class ForumsTableViewCell: UITableViewCell {
    let ref = FIRDatabase.database().reference()
    var delegateProp:forumRecordDelegate?
    var curUser = FIRAuth.auth()?.currentUser
    var forum:Forum? {
        didSet {
            forumDesc.text = forum?.description
            ref.child("Users").child((forum?.owner)!).observeEventType(.Value, withBlock: { (snapshot) -> Void in
                let senderNameVal = ((snapshot.value!["firstName"] as? String)!) + " " + ((snapshot.value!["lastName"] as? String)!)
                self.ownerName.text = senderNameVal
                let profileURL = (snapshot.value!["profileImageURL"] as? String)!
                if self.curUser!.email == (snapshot.value!["email"] as? String)! {
                    self.deleteIcon.hidden = false
                }
                if profileURL != "" {
                    let url = NSURL(string: profileURL)
                    NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                        if error != nil {
                            print(error)
                            return
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            self.ownerImage?.image = UIImage(data: data!)
                        })
                    }).resume()
                }
                self.ownerImage.layer.borderWidth = 1
                self.ownerImage.layer.masksToBounds = false
                self.ownerImage.layer.borderColor = UIColor.blackColor().CGColor
                self.ownerImage.layer.cornerRadius = self.ownerImage.frame.height/2
                self.ownerImage.clipsToBounds = true
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBOutlet weak var ownerImage: UIImageView!
    
    @IBOutlet weak var ownerName: UILabel!
    
    @IBOutlet weak var forumDesc: UILabel!
    
    @IBAction func deleteForum(sender: UIButton) {
        delegateProp!.deleteForum((forum?.key)!)
    }
    
    @IBOutlet weak var deleteIcon: UIButton!
}
