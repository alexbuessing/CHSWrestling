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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collection.dataSource = self
        collection.delegate = self
        
        DataService.ds.REF_PLAYER.queryOrderedByChild("order").observeEventType(.Value, withBlock: {snapshot in
            
            self.player = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    
                    if let postDic = snap.value as? Dictionary<String, AnyObject> {
                        
                        let key = snap.key
                        let play = Player(postKey: key, dictionary: postDic)
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
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("playerCell", forIndexPath: indexPath) as? PlayerCell {
            
            let student = player[indexPath.row]
            
            cell.configureCell(student.imageURL, name: student.name, weight: student.weight, year: student.year, record: student.record)
            
            return cell
        } else {
            return UICollectionViewCell()
        }
        
    }

}
