//
//  InboxListTableViewController.swift
//  HW03
//
//  Created by student on 8/3/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import MBProgressHUD

protocol inboxRecordDelegate {
    func deleteInboxRecord(msgId: String)
}

class InboxListTableViewController: UITableViewController, inboxRecordDelegate {
    var messages = [Message]()
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
        ref.child("Messages").observeEventType(.Value, withBlock: { (snapshot) -> Void in
            self.messages.removeAll()
            let enumerator = snapshot.children
            while let msg = enumerator.nextObject() as? FIRDataSnapshot {
                if (msg.value!["receiver"] as? String) == self.curUser?.uid {
                    let senderVal = msg.value!["sender"] as? String
                    let receiverVal = msg.value!["receiver"] as? String
                    let messageVal = msg.value!["message"] as? String
                    let dateVal = msg.value!["date"] as? String
                    let isReadVal = msg.value!["isRead"] as? String
                    let msgObj = Message(toUser:receiverVal!,fromUser:senderVal!, messageStr: messageVal!, dateStr: dateVal!, isRead:isReadVal!, key: msg.key)
                    self.messages.append(msgObj)
                }
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
        return messages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageIdentifier", forIndexPath: indexPath)
        let myMsg = messages[indexPath.row]
        if let myCell = cell as? InboxListTableViewCell {
            myCell.message = myMsg
            myCell.delegateProp = self
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "messageIdentifier" {
            let indexPath = self.tableView.indexPathForSelectedRow!
            let selectedMessage = messages[indexPath.row]
            if let messageVC = segue.destinationViewController as? MessageDetailViewController {
                messageVC.message = selectedMessage
            }
        }
    }
    
    func deleteInboxRecord(msgId: String){
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Inbox Delete", message: "Do you want to delete this message?", preferredStyle: .Alert)
         
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: {[weak self] (paramAction:UIAlertAction!) in
            self!.ref.child("Messages").child(msgId).removeValue()
        })
         
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {[weak self] (paramAction:UIAlertAction!) in })
         
        alertController?.addAction(okAction)
        alertController?.addAction(cancelAction)
        presentViewController(alertController!, animated: true, completion: nil)
        tableView.reloadData()
    }
}

struct Message {
    var toUser: String
    var fromUser: String
    var messageStr: String
    var dateStr: String
    var isRead: String
    var key: String
}
