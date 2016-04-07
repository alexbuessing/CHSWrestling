//
//  ScheduleVC.swift
//  Wrestling
//
//  Created by Alexander Buessing on 4/6/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit
import Firebase

class ScheduleVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var events = [Event]()
    var network = Func()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    override func viewDidAppear(animated: Bool) {
        
        if !network.connectedToNetwork() {
            showErrorAlert("No Network Connection", msg: "Information may not be up to date. Please check your network connection.")
        }
        
        DataService.ds.REF_EVENTS.queryOrderedByChild("order").observeEventType(.Value, withBlock: { snapshot in
            
            self.events = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    
                    if let eventDic = snap.value as? Dictionary<String, AnyObject> {
                        
                        let event = Event(dictionary: eventDic)
                        self.events.append(event)
                        
                    }
                }
            }
            
            self.tableView.reloadData()
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let event = events[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("scheduleCell") as? ScheduleCell {

            cell.configureCell(event.eventDescription, location: event.location, time: event.time, date: event.date)
            return cell
            
        }
        return ScheduleCell()
    }
    
    func showErrorAlert(title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
}
