//
//  MainTableTableViewController.swift
//  HW03
//
//  Created by student on 8/1/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class MainTableTableViewController: UITableViewController {

    var curUser = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    @IBAction func logoutUser(sender: UIBarButtonItem) {
        try! FIRAuth.auth()?.signOut()
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : UIViewController = storyboard.instantiateViewControllerWithIdentifier("LoginStoryBoard") as UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    @IBOutlet weak var profileRow: UITableViewCell!
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        if indexPath!.row == 0 {
            redirectToProfile()
        }
    }
    
    func redirectToProfile() {
        let currentUserKey = curUser?.uid
        let ref = FIRDatabase.database().reference()
        ref.child("Users").child(currentUserKey!).observeEventType(.Value, withBlock: { (snapshot) -> Void in
            let fName = snapshot.value!["firstName"] as? String
            let lName = snapshot.value!["lastName"] as? String
            let email = snapshot.value!["email"] as? String
            let profileImgURL = snapshot.value!["profileImageURL"] as? String
            let key = snapshot.key
            let currentuserObj = User(firstName:fName!,lastName:lName!, email: email!, key: key, profileImageURL: profileImgURL!)
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : UIViewController = storyboard.instantiateViewControllerWithIdentifier("ProfileStoryBoard") as UIViewController
            if let profileVC = vc as? UserProfileViewController {
                profileVC.user = currentuserObj
                profileVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Main", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MainTableTableViewController.goBack))
                let navController = UINavigationController(rootViewController: profileVC) // Creating a navigation controller with VC1 at the root of the navigation stack.
                self.presentViewController(navController, animated:true, completion: nil)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    func goBack(){
        dismissViewControllerAnimated(true, completion: nil)
    }
}
