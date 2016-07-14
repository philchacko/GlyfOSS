//
//  GlyfContentViewCell.swift
//  Glyf
//
//  Created by Philip Chacko on 9/3/15.
//  Copyright (c) 2015 Phil Chacko. All rights reserved.
//

import UIKit
import Parse

protocol GlyfContentViewCellDelegate {
    func reloadSingleAnnotation(annotation: GlyfPointAnnotation!)
}

class GlyfContentViewCell: UICollectionViewCell {
    
    var annotation = GlyfPointAnnotation()
    var delegate: GlyfContentViewCellDelegate?
    var locationManager: CLLocationManager?
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblScreenname: UILabel!
    @IBOutlet weak var btnHeart: UIButton!
    @IBOutlet weak var profileThumb: UIImageView!
    
    
    @IBAction func btnHeart(sender: AnyObject) {
        
        let query = PFQuery(className: "locObject")
        query.getObjectInBackgroundWithId(annotation.objectId, block: { (object: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            }
            else if let object = object {
                var newHeartCount = self.annotation.heartCount
                if self.annotation.heartedByUser == true {
                    newHeartCount--
                    object.removeObject(PFUser.currentUser()!.username!, forKey: "heartedBy")
                    //self.annotation.heartedByUser = false
                }
                else {
                    newHeartCount++
                    //let activeImage = UIImage(contentsOfFile: "StarSelected.png")
                    //self.btnHeart.setBackgroundImage(activeImage, forState: UIControlState.Normal)
                    object.addUniqueObject(PFUser.currentUser()!.username!, forKey: "heartedBy")
                    //self.annotation.heartedByUser = true
                }
                object["heartCount"] = newHeartCount
                object.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if error != nil {
                        print(error)
                    }
                    else {
                        self.annotation.heartCount = newHeartCount
                        self.annotation.heartedByUser = !self.annotation.heartedByUser
                        if self.annotation.heartedByUser == true {
                            self.btnHeart.selected = true
                            
                        } else {
                            self.btnHeart.selected = false
                        }
                        self.btnHeart.setTitle("\(newHeartCount)", forState: UIControlState.Normal)
                        self.delegate?.reloadSingleAnnotation(self.annotation)
                    }
                })
            }
        })
        
        if #available(iOS 9.0, *) {
            locationManager?.allowsBackgroundLocationUpdates = true
        }
        locationManager?.requestAlwaysAuthorization()
    }
    
}
