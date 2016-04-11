//
//  CoachesVC.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/14/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class CoachesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    var coach = [Coach]()
    var network = Func()
    var loading = false
    static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.userInteractionEnabled = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if !network.connectedToNetwork() {
            showErrorAlert("No Network Connection", msg: "Information may not be up to date. Please check your network connection.")
        }
        
            DataService.ds.REF_COACH.queryOrderedByChild("order").observeEventType(.Value, withBlock: {snapshot in
            
                self.coach = []
            
                if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                    for snap in snapshots {
                    
                        if let postDic = snap.value as? Dictionary<String, AnyObject> {
                        
                            let key = snap.key
                            let coach = Coach(postKey: key, dictionary: postDic)
                            self.coach.append(coach)
                        
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
        return coach.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = coach[indexPath.row]
        
        var img: UIImage?
        
        img = CoachesVC.imageCache.objectForKey(post.profileImg) as? UIImage
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? CoachCell {
            
            cell.request?.cancel()
            
            cell.configureCell(post.profileImg, name: post.name, title: post.title, coachImg: img)
            return cell
        }

        return CoachCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCoach = coach[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("showProfile", sender: selectedCoach)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showProfile" {
            
            if let profileView = segue.destinationViewController as? ProfileVC {
                
                if let person = sender as? Coach {
                    profileView.coach = person
                }
                
            }
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.graceTime = 0.5
        hud.opacity = 0.6
        loading = true
    }
    
    private func hideLoadingHUD() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        loading = false
    }

}
