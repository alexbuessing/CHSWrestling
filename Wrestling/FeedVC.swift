//
//  FeedVC.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/11/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import MBProgressHUD

class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet var postView: MaterialView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var postField: MaterialTextField!
    @IBOutlet var imageSelectImg: UIImageView!
    @IBOutlet var userName: UILabel!
    
    var posts = [Post]()
    var imageSelected = false
    static var imageCache = NSCache()
    var loading = false
    
    var imagePicker: UIImagePickerController!
    
    var divisionArray = [Award]()
    var items = [[Award]()]
    
    override func viewDidLoad() {
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        postField.delegate = self
        
        tableView.estimatedRowHeight = 448
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        addTapGesture()
        
        //This gets the data from Firebase and downloads it instantaneously
        DataService.ds.REF_POSTS.queryOrderedByChild("sortNumber").observeEventType(.Value, withBlock: {snapshot in
        
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots.reverse() {
                    //print("SNAP: \(snap)")
                    
                    if let postDic = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDic)
                        self.posts.append(post)
                    }
                    
                }
                
            }
            
            self.tableView.reloadData()
        })
        
        DataService.ds.REF_DIVISION.queryOrderedByChild("order").observeSingleEventOfType(.Value, withBlock: {snapshot in
            
            self.divisionArray = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots.reverse() {
                    
                    if let awardDic = snap.value as? Dictionary<String, AnyObject> {
                        let value = Award(dictionary: awardDic)
                        self.divisionArray.append(value)
                    }
                }
            }
            self.items[0] = self.divisionArray
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            cell.request?.cancel()
            
            var img: UIImage?
            
            if let url = post.imageURL {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, img:  img)
            
            return cell
        } else {
            return PostCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let post = posts[indexPath.row]
        
        if post.imageURL == nil {
            return 148
        } else {
            return tableView.estimatedRowHeight
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectImg.image = image
        imageSelected = true
        
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showHUDAddedTo(tableView, animated: true)
        hud.opacity = 0.6
        //hud.labelText = "Loading..."
        loading = true
    }
    
    private func hideLoadingHUD() {
        MBProgressHUD.hideAllHUDsForView(tableView, animated: true)
        loading = false
    }
    
    @IBAction func makePost(sender: AnyObject) {
        
        if let txt = postField.text where txt != "" {
         
            if let img = imageSelectImg.image where imageSelected == true {
                let urlString = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlString)!
                let imageData = UIImageJPEGRepresentation(img, 0.3)!
                let keyData = "59DERUWY4e7ad4a26bedc73667d1847f36c7c5fd".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                self.showLoadingHUD()
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                        multipartFormData.appendBodyPart(data: imageData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                        multipartFormData.appendBodyPart(data: keyData, name: "key")
                        multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    
                    }) { encodingResult in
                        //This is what happens when the encoding is done
                        
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.responseJSON(completionHandler: { response in
                                if let info = response.result.value as? Dictionary<String, AnyObject> {
                                    if let links = info["links"] as? Dictionary<String, AnyObject> {
                                        if let imageLink = links["image_link"] as? String {
                                            print("LINK: \(imageLink)")
                                            self.postToFirePost(imageLink)
                                        }
                                    }
                                }
                            })
                        case .Failure(let error):
                            print(error)
                           self.hideLoadingHUD()
                        }
                        
                }
            } else {
                self.postToFirePost(nil)
            }
        }
    }
    
    
    func postToFirePost(imgURL: String?) {
        
        let timestamp = FirebaseServerValue.timestamp()
        
        var post: Dictionary<String, AnyObject> = ["description": postField.text!, "likes": 0, "sortNumber": timestamp]
        
        if imgURL != nil {
            post["imageurl"] = imgURL!
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        postField.text = ""
        imageSelectImg.image = UIImage(named: "CameraIcon")
        imageSelected = false
        
        tableView.reloadData()
        self.hideLoadingHUD()
        
    }
    
    @IBAction func settingsPressed(sender: AnyObject!) {
        self.performSegueWithIdentifier("backToSettings", sender: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        postField.resignFirstResponder()
        return true
    }
    
    func addTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FeedVC.hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
        
    }
    
    func hideKeyboard() {
        postField.resignFirstResponder()
    }
    
}
