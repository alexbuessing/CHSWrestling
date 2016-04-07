//
//  AwardsVC.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/20/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit
import Firebase

class AwardsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let sectionArray = ["Division I Champions", "All-State Champions", "New England Place Winners", "Hall of Famers"]
    
    var divisionArray = [Award]()
    var stateArray = [Award]()
    var newEnglandArray = [Award]()
    var hallOfFameArray = [Award]()
    
    var items = [[Award]()]
    var network = Func()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = [[], [], [], []]
        
        tableView.dataSource = self
        tableView.delegate = self

    }
    
    override func viewDidAppear(animated: Bool) {
        
        if !network.connectedToNetwork() {
            showErrorAlert("No Network Connection", msg: "Information may not be up to date. Please check your network connection.")
        }
        
            queryFirebase()

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return items[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let name = items[indexPath.section][indexPath.row].name
        let text = items[indexPath.section][indexPath.row].text
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("awardCell") as? AwardCell {
            
            cell.configureCell(name, information: text)
            return cell
            
        }
        
        return AwardCell()
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let headerCell = tableView.dequeueReusableCellWithIdentifier("headerCell") as? HeaderCell {
            
            headerCell.sectionTitle.text = sectionArray[section]
            
            return headerCell
        } else {
            return UIView()
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }

    func queryFirebase() {
        
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
            
            DataService.ds.REF_STATE.queryOrderedByChild("order").observeSingleEventOfType(.Value, withBlock: {snapshot in

                self.stateArray = []
                
                if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                    
                    for snap in snapshots.reverse() {
                        
                        if let awardDic = snap.value as? Dictionary<String, AnyObject> {
                            let value = Award(dictionary: awardDic)
                            self.stateArray.append(value)
                        }
                    }
                    
                }
                self.items[1] = self.stateArray
                
                DataService.ds.REF_NEWENGLAND.queryOrderedByChild("order").observeSingleEventOfType(.Value, withBlock: { snapshot in

                    self.newEnglandArray = []
                    
                    if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                        
                        for snap in snapshots.reverse() {
                            
                            if let awardDic = snap.value as? Dictionary<String, AnyObject> {
                                let value = Award(dictionary: awardDic)
                                self.newEnglandArray.append(value)
                            }
                        }
                    }
                    self.items[2] = self.newEnglandArray
                    
                    DataService.ds.REF_HOF.queryOrderedByChild("order").observeSingleEventOfType(.Value, withBlock: {snapshot in

                        self.hallOfFameArray = []
                        
                        if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                            
                            for snap in snapshots.reverse() {
                                
                                if let awardDic = snap.value as? Dictionary<String, AnyObject> {
                                    let value = Award(dictionary: awardDic)
                                    self.hallOfFameArray.append(value)
                                }
                            }
                        }
                        
                        self.items[3] = self.hallOfFameArray
                        self.tableView.reloadData()
                        
                    })
                    
                })
                
            })
            
        })
        
    }
    
    func showErrorAlert(title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
}
