//
//  CommentsTableViewCell.swift
//  HW03
//
//  Created by student on 8/5/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class CommentsTableViewCell: UITableViewCell {
    var curUser = FIRAuth.auth()?.currentUser
    var delegateProp:commentHandlerDelegate?
    var commentObj:Comment?{
        didSet {
            ref.child("Users").child(commentObj!.owner).observeEventType(.Value, withBlock: { (snapshot) -> Void in
                let senderNameVal = ((snapshot.value!["firstName"] as? String)!) + " " + ((snapshot.value!["lastName"] as? String)!)
                self.commentOwnerName.text = senderNameVal
                self.commentDescription.text = self.commentObj?.message
                let profileURL = (snapshot.value!["profileImageURL"] as? String)!
                if profileURL != "" {
                    let url = NSURL(string: profileURL)
                    NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                        if error != nil {
                            print(error)
                            return
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            self.commentOwnerImg?.image = UIImage(data: data!)
                        })
                    }).resume()
                }
                self.commentOwnerImg.layer.borderWidth = 1
                self.commentOwnerImg.layer.masksToBounds = false
                self.commentOwnerImg.layer.borderColor = UIColor.blackColor().CGColor
                self.commentOwnerImg.layer.cornerRadius = self.commentOwnerImg.frame.height/2
                self.commentOwnerImg.clipsToBounds = true
                if self.commentObj?.owner == self.curUser?.uid {
                    self.deleteIcon.hidden = false
                }
            }) { (error) in
                print(error.localizedDescription)
            }
            
            let profileURL1 = commentObj?.imageURL
            if profileURL1 != "" {
                let url = NSURL(string: profileURL1!)
                NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.commentImage?.image = UIImage(data: data!)
                    })
                }).resume()
            }
            self.commentImage.layer.borderWidth = 1
            self.commentImage.layer.masksToBounds = false
            self.commentImage.layer.borderColor = UIColor.blackColor().CGColor
            self.commentImage.layer.cornerRadius = self.commentImage.frame.height/2
            self.commentImage.clipsToBounds = true
            
            if self.curUser!.email == commentObj?.owner {
                self.deleteIcon.hidden = false
            }
        }
    }
    var forum:Forum?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBOutlet weak var commentOwnerImg: UIImageView!
    @IBOutlet weak var commentOwnerName: UILabel!
    @IBOutlet weak var commentDescription: UILabel!
    @IBOutlet weak var commentImage: UIImageView!
    @IBOutlet weak var deleteIcon: UIButton!
    @IBAction func deleteComment(sender: UIButton) {
        delegateProp!.deleteComment((commentObj?.key)!)
    }
}
