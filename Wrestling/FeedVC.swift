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
import SystemConfiguration

class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, Alert {

    @IBOutlet var postView: MaterialView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var postField: MaterialTextField!
    @IBOutlet var imageSelectImg: UIImageView!
    
    var posts = [Post]()
    var appManagers = [String]()
    var imageSelected = false
    static var imageCache = NSCache()
    static var profileImageCache = NSCache()
    var loading = false
    var network = Func()
    var defaults = NSUserDefaults.standardUserDefaults()
    
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
        
    }

    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
        
        if !network.connectedToNetwork() {
            showErrorAlert("No Network Connection", msg: "Information may not be up to date. Please check your network connection.")
        }
        
            DataService.ds.REF_APP_MANAGERS.observeEventType(.Value, withBlock: { snapshot in
                
                self.appManagers = []
                
                if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                    
                    for snap in snapshots {

                        if let manager = snap.value as? Dictionary<String, AnyObject> {

                            for IDs in manager.values {
                                
                                let ID = String(IDs)
                                self.appManagers.append(ID)
                                
                            }
                        }
                    }
                    
                }

                self.defaults.setObject(self.appManagers, forKey: "managersArray")
                self.tableView.reloadData()
            })
            
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

            cell.delegate = self
            cell.request?.cancel()
            cell.myPost = post
            
            var img: UIImage?
            var profileImg: UIImage?
            
            if let profileURL = post.profileURL {
                if profileURL != " " {
                    profileImg = FeedVC.profileImageCache.objectForKey(profileURL) as? UIImage
                }
            }
            
            if let url = post.imageURL {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }

            cell.configureCell(post, img:  img, profImg: profileImg)

            return cell
        } else {
            return PostCell()
        }
        
    }
    
    func showAlert(post: Post) {
        
        let alert = UIAlertController(title: "Delete Post?", message: "Do you want to delete this post?", preferredStyle: .Alert)
        let no = UIAlertAction(title: "No", style: .Default, handler: nil)
        let yes = UIAlertAction(title: "Yes", style: .Default) { alert in
            
            let postRef: Firebase = DataService.ds.REF_POSTS.childByAppendingPath(post.postKey)
            let likeRef: Firebase = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
            
            postRef.removeValue()
            likeRef.removeValue()
  
        }
        
        alert.addAction(no)
        alert.addAction(yes)
        
        presentViewController(alert, animated: true, completion: nil)
        
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
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.opacity = 0.6
        //hud.labelText = "Loading..."
        loading = true
    }
    
    private func hideLoadingHUD() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        loading = false
    }
    
    @IBAction func makePost(sender: AnyObject) {
        
        if connectedToNetwork() {
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
        } else {
            showErrorAlert("No Network Connection", msg: "Please check your network or internet connection.")
        }
        
        postField.resignFirstResponder()
    }
    
    
    func postToFirePost(imgURL: String?) {
        
        let username = String(defaults.valueForKey("username")!)
        print(username)
        let timestamp = FirebaseServerValue.timestamp()
        let user = String(defaults.valueForKey(KEY_UID)!)
        
        var post: Dictionary<String, AnyObject> = [
            "description": postField.text!,
            "likes": 0,
            "sortNumber": timestamp,
            "username": username,
            "userID": user,
            "profileurl": " "
        ]
        
        if imgURL != nil {
            post["imageurl"] = imgURL!
        }
        
        if let profileURL = defaults.objectForKey("profileURL") {
            post["profileurl"] = String(profileURL)
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
    
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func showErrorAlert(title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
}
