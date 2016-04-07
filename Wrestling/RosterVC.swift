//
//  RosterVC.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/16/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit
import Firebase

class RosterVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collection: UICollectionView!
    
    var player = [Player]()
    let network = Func()
    static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collection.dataSource = self
        collection.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if !network.connectedToNetwork() {
            showErrorAlert("No Network Connection", msg: "Information may not be up to date. Please check your network connection.")
        }
        
            DataService.ds.REF_PLAYER.queryOrderedByChild("order").observeEventType(.Value, withBlock: {snapshot in
            
                self.player = []
            
                if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                    for snap in snapshots {

                        if let postDic = snap.value as? Dictionary<String, AnyObject> {
                        
                            let play = Player(dictionary: postDic)
                            self.player.append(play)
                        
                        }
                    }
                }
            
                self.collection.reloadData()
        })
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return player.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((collection.frame.width/2) - 4, (collection.frame.width/2) - 4)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let student = player[indexPath.row]
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("playerCell", forIndexPath: indexPath) as? PlayerCell {
            
            cell.request?.cancel()
            
            var img: UIImage?
            
            img = RosterVC.imageCache.objectForKey(student.imageURL) as? UIImage
            
            cell.configureCell(student.imageURL, name: student.name, weight: student.weight, year: student.year, record: student.record, image: img)
            
            return cell
        } else {
            return UICollectionViewCell()
        }
        
    }

    func showErrorAlert(title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
}
