//
//  UsersTableViewCell.swift
//  HW03
//
//  Created by student on 8/3/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit

class UsersTableViewCell: UITableViewCell {
    var user:User? {
        didSet {
            usernameField.text = "\((user?.firstName)!) \((user?.lastName)!)"
            userImageField.contentMode = .ScaleAspectFill
            let profileURL = user!.profileImageURL
            if profileURL != "" {
                let url = NSURL(string: profileURL)
                NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.userImageField?.image = UIImage(data: data!)
                    })
                }).resume()
            }
            
            userImageField.layer.borderWidth = 1
            userImageField.layer.masksToBounds = false
            userImageField.layer.borderColor = UIColor.blackColor().CGColor
            userImageField.layer.cornerRadius = userImageField.frame.height/2
            userImageField.clipsToBounds = true
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

    @IBOutlet weak var userImageField: UIImageView!
    
    @IBOutlet weak var usernameField: UILabel!
}
