//
//  UsersTableViewController.swift
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

class UsersTableViewController: UITableViewController {
    var curUser = FIRAuth.auth()?.currentUser
    var users = [User]()
    var ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.label.text = "Loading"
        
        fetchData()
    }
    
    func fetchData() {
        ref.child("Users").observeEventType(.Value, withBlock: { (snapshot) -> Void in
            self.users.removeAll()
            let enumerator = snapshot.children
            while let user = enumerator.nextObject() as? FIRDataSnapshot {
                let userFirstName = user.value!["firstName"] as? String
                let userLastName = user.value!["lastName"] as? String
                let userEmail = user.value!["email"] as? String
                let profileImgURL = user.value!["profileImageURL"] as? String
                let userObj = User(firstName:userFirstName!,lastName:userLastName!, email: userEmail!, key: user.key, profileImageURL: profileImgURL!)
                self.users.append(userObj)
            }
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userRowIdentifier", forIndexPath: indexPath)
        let myUser = users[indexPath.row]
        if let myCell = cell as? UsersTableViewCell {
            myCell.user = myUser
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UserDetailIdentifier" {
            let indexPath = self.tableView.indexPathForSelectedRow!
            let selectedUser = users[indexPath.row]
            if let profileVC = segue.destinationViewController as? UserProfileViewController {
                profileVC.user = selectedUser
            }
        }
    }
}
struct User {
    let firstName: String
    let lastName: String
    let email: String
    let key: String
    let profileImageURL: String
}
