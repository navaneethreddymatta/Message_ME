//
//  ForumViewController.swift
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

protocol commentHandlerDelegate {
    func deleteComment(cID: String)
}

let ref = FIRDatabase.database().reference()
var comments = [Comment]()

class ForumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, commentHandlerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var forum:Forum?
    var curUser = FIRAuth.auth()?.currentUser
    override func viewDidLoad() {
        super.viewDidLoad()
        postButton.enabled = false
        fetchData()
    }
    
    func fetchData() {
        loadForumDetails()
        loadCurrentUserDetails()
        loadComments()
    }
    
    func loadForumDetails() {
        forumDescription.text = forum?.description
        ref.child("Users").child((forum?.owner)!).observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
            let senderNameVal = ((snapshot.value!["firstName"] as? String)!) + " " + ((snapshot.value!["lastName"] as? String)!)
            self.forumOwnerName.text = senderNameVal
            let profileURL = (snapshot.value!["profileImageURL"] as? String)!
            if profileURL != "" {
                let url = NSURL(string: profileURL)
                NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.forumOwnerImage?.image = UIImage(data: data!)
                    })
                }).resume()
            }
            self.forumOwnerImage.layer.borderWidth = 1
            self.forumOwnerImage.layer.masksToBounds = false
            self.forumOwnerImage.layer.borderColor = UIColor.blackColor().CGColor
            self.forumOwnerImage.layer.cornerRadius = self.forumOwnerImage.frame.height/2
            self.forumOwnerImage.clipsToBounds = true
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    func loadCurrentUserDetails() {
        ref.child("Users").child((curUser?.uid)!).observeEventType(.Value, withBlock: { (snapshot) -> Void in
            let profileURL1 = (snapshot.value!["profileImageURL"] as? String)!
            if profileURL1 != "" {
                let url1 = NSURL(string: profileURL1)
                NSURLSession.sharedSession().dataTaskWithURL(url1!, completionHandler: { (data, response, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.currentUserImage?.image = UIImage(data: data!)
                    })
                }).resume()
            }
            self.currentUserImage.layer.borderWidth = 1
            self.currentUserImage.layer.masksToBounds = false
            self.currentUserImage.layer.borderColor = UIColor.blackColor().CGColor
            self.currentUserImage.layer.cornerRadius = self.currentUserImage.frame.height/2
            self.currentUserImage.clipsToBounds = true
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    func loadComments() {
        print("fetch data")
        ref.child("Forums").child(forum!.key).child("Comments").observeEventType(.Value, withBlock: { (snapshot) -> Void in
            comments.removeAll()
            let enumerator = snapshot.children
            while let cmt = enumerator.nextObject() as? FIRDataSnapshot {
                let commentOwner = cmt.value!["owner"] as? String
                let commentImageURL = (cmt.value!["url"] as? String) ?? ""
                let dateVal = cmt.value!["date"] as? String
                let commentMessage = (cmt.value!["message"] as? String) ?? ""
                let commentKey = cmt.key
                let commentObj = Comment(owner: commentOwner!, message: commentMessage, imageURL: commentImageURL, key: commentKey, date: dateVal!)
                comments.append(commentObj)
            }
            print("data Loaded")
            self.commentsTableView.reloadData()
            self.commentsTableView.estimatedRowHeight = 100
            self.commentsTableView.rowHeight = UITableViewAutomaticDimension
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let commentObj = comments[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCellIdentifier", forIndexPath: indexPath) as? CommentsTableViewCell
        cell!.forum = self.forum
        cell!.commentObj = commentObj
        cell!.delegateProp = self
        if commentObj.imageURL == "" {
            cell!.commentImage.hidden = true
        }
        return cell!
    }
    
    
    func deleteComment(cID: String) {
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Comment Delete", message: "Do you want to delete this comment?", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: {[weak self] (paramAction:UIAlertAction!) in
            self!.ref.child("Forums").child(self!.forum!.key).child("Comments").child(cID).removeValue()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {[weak self] (paramAction:UIAlertAction!) in })
        
        alertController?.addAction(okAction)
        alertController?.addAction(cancelAction)
        presentViewController(alertController!, animated: true, completion: nil)
        loadComments()
    }
    
    @IBOutlet weak var forumOwnerImage: UIImageView!
    
    @IBOutlet weak var forumOwnerName: UILabel!
    
    @IBOutlet weak var forumDescription: UILabel!
    
    @IBOutlet weak var currentUserImage: UIImageView!
    
    @IBOutlet weak var commentText: UITextField!
    
    @IBOutlet weak var postButton: UIButton!
    
    @IBAction func postComment(sender: UIButton) {
        let commentTextVal = commentText.text
        let cDate = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .MediumStyle
        let dateString = formatter.stringFromDate(cDate)
        let userID = curUser?.uid
        ref.child("Forums").child(forum!.key).child("Comments").childByAutoId().setValue(["owner":userID!,"message":commentTextVal!,"url":imageInCommentURL,"date":dateString])
        loadComments()
        commentText.text = ""
        imageInComment.image = UIImage(named: "frame")
        postButton.enabled = false
    }
    
    @IBAction func changeTextField(sender: UITextField) {
        let cText = commentText.text
        if cText == "" && imageInCommentURL == "" {
            postButton.enabled = false
        } else {
            postButton.enabled = true
        }
    }
    
    let imagePicker = UIImagePickerController()
    let ref = FIRDatabase.database().reference()
    @IBAction func addPhotoInComment(sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBOutlet weak var imageInComment: UIImageView!
    @IBOutlet weak var commentsTableView: UITableView!
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    var imageInCommentURL = ""
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] {
            selectedImageFromPicker = editedImage as? UIImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] {
            selectedImageFromPicker = originalImage as? UIImage
        }
        if let selectedImage = selectedImageFromPicker {
            imageInComment.image = selectedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
        let imageName = NSUUID().UUIDString
        let storageRef = FIRStorage.storage().reference().child("\(imageName).png")
        postButton.enabled = true
        if let uploadData = UIImagePNGRepresentation(imageInComment.image!) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error)
                    return
                } else {
                    let profileImageURLVal2 = metadata?.downloadURL()?.absoluteString
                    self.imageInCommentURL = profileImageURLVal2!
                }
            })
        }
    }
}

struct Comment {
    var owner: String
    var message: String
    var imageURL: String
    var key: String
    var date: String
}
