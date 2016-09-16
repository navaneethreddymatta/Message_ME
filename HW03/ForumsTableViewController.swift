//
//  ForumsTableViewController.swift
//  HW03
//
//  Created by student on 8/5/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import MBProgressHUD

protocol forumRecordDelegate {
    func deleteForum(forumID: String)
}
class ForumsTableViewController: UITableViewController, forumRecordDelegate {
    var forums = [Forum]()
    var curUser = FIRAuth.auth()?.currentUser
    let ref = FIRDatabase.database().reference()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.label.text = "Loading"
        
        loadData()
    }
    
    func loadData() {
        ref.child("Forums").observeEventType(.Value, withBlock: { (snapshot) -> Void in
            self.forums.removeAll()
            let enumerator = snapshot.children
            while let forum = enumerator.nextObject() as? FIRDataSnapshot {
                let description = forum.value!["description"] as? String
                let owner = forum.value!["owner"] as? String
                let dateVal = forum.value!["date"] as? String
                let keyVal = forum.key
                let forumObj = Forum(description: description!, owner: owner!, date: dateVal!, key: keyVal)
                self.forums.append(forumObj)
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
        return forums.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("forumCellIdentifier", forIndexPath: indexPath)
        let myForum = forums[indexPath.row]
        if let myCell = cell as? ForumsTableViewCell {
            myCell.forum = myForum
            myCell.delegateProp = self
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "forumIdentifier" {
            let indexPath = self.tableView.indexPathForSelectedRow!
            print("selected row: \(indexPath.row)")
            let selectedForum = forums[indexPath.row]
            print("forum id: \(selectedForum.key)")
            if let forumVC = segue.destinationViewController as? ForumViewController {
                forumVC.forum = selectedForum
            }
        }
    }
    
    func deleteForum(forumID: String) {
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Delete", message: "Are you sure you want to delete this forum?", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: {[weak self] (paramAction:UIAlertAction!) in
            self!.ref.child("Forums").child(forumID).removeValue()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {[weak self] (paramAction:UIAlertAction!) in })
        
        alertController?.addAction(okAction)
        alertController?.addAction(cancelAction)
        presentViewController(alertController!, animated: true, completion: nil)
        tableView.reloadData()
    }
}
struct Forum {
    var description: String
    var owner: String
    var date: String
    var key: String
}