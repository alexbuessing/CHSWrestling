//
//  CoachesVC.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/14/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit
import Firebase

class CoachesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    var coach = [Coach]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        
        
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
    
    override func viewDidAppear(animated: Bool) {
        tableView.userInteractionEnabled = true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coach.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = coach[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? CoachCell {
            cell.configureCell(post.profileImg, name: post.name, title: post.title)
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

}
