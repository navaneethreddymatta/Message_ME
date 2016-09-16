//
//  InviteViewViewController.swift
//  HW03
//
//  Created by student on 8/5/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import SwiftMailgun

class InviteViewViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        inviteMessageText.text = "<b>Hi, \n Join my app<b>"
    }

    @IBAction func cancelInvitation(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitInvitation(sender: UIButton) {
        let userEmail = inviteeEmailID.text
        let msgText = inviteMessageText.text
        if userEmail == "" || msgText == "" {
            let alert = UIAlertController(title: "Alert", message: "Enter valid details", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let mailgun = MailgunAPI(apiKey: "key-42a04196a5ab6c6c564abec2aca5b591", clientDomain: "sandboxd7b116a67f374e9d9e3f0158cd996fe2.mailgun.org")
            mailgun.sendEmail(to: userEmail!, from: "Navaneeth Reddy Matta <nmatta1@uncc.edu>", subject: "Invitation to My App", bodyHTML: msgText) { mailgunResult in
                if mailgunResult.success{
                    print("Email was sent")
                }
            }
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBOutlet weak var inviteeEmailID: UITextField!
    
    @IBOutlet weak var inviteMessageText: UITextView!
    
}
