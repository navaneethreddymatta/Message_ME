//
//  SignUpViewController.swift
//  HW03
//
//  Created by student on 8/1/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import MBProgressHUD

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBOutlet weak var firstName: UITextField!
    
    @IBOutlet weak var lastName: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBAction func cancelUserCreation(sender: UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func submitUser(sender: UIButton) {
        let fName = firstName.text
        let lName = lastName.text
        let emailID = email.text
        let uPassword = password.text
        let uConfirmPassword = confirmPassword.text
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        
        if fName == nil || fName == "" || lName == nil || lName == "" || emailID == nil || emailID == "" || uPassword == nil || uPassword == "" || uConfirmPassword == nil || uConfirmPassword == "" {
            let alert = UIAlertController(title: "Alert", message: "Enter Your Details", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        } else if uPassword != uConfirmPassword {
            let alert = UIAlertController(title: "Alert", message: "Passwords do not match", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            loadingNotification.label.text = "Loading"
            FIRAuth.auth()?.createUserWithEmail(emailID!, password: uPassword!, completion: { (newUser, error) in
                if error != nil {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    let alert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let ref = FIRDatabase.database().reference()
                    ref.child("Users").child((newUser?.uid)!).setValue(["firstName": fName!,"lastName": lName!,"email": emailID!,"password": uPassword!,"profileImageURL": ""])
                    // --------- login from here --------------
                    FIRAuth.auth()?.signInWithEmail(emailID!, password: uPassword!, completion: { (newUser, error) in
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
            })
        }
    }
}
