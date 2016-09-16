//
//  LoginViewController.swift
//  HW03
//
//  Created by student on 8/1/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import MBProgressHUD

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        let cUser = FIRAuth.auth()?.currentUser
        if cUser != nil {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : UIViewController = storyboard.instantiateViewControllerWithIdentifier("HomeStoryBoard") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
   
    @IBOutlet weak var emailField: UITextField!

    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginUser(sender: UIButton) {
        let email = emailField.text
        let password = passwordField.text
        if email == nil || email == "" || password == nil || password == "" {
            let alert = UIAlertController(title: "Alert", message: "Enter Your Credentials", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            
            let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            loadingNotification.label.text = "Loading"
            
            FIRAuth.auth()?.signInWithEmail(email!, password: password!, completion: { (newUser, error) in
                if error != nil {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    let alert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc : UIViewController = storyboard.instantiateViewControllerWithIdentifier("HomeStoryBoard") as UIViewController
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            })
        }
    }
}
