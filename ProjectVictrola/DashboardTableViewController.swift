//
//  DashboardTableViewController.swift
//  Glyf
//
//  Created by Philip Chacko on 11/2/15.
//  Copyright © 2015 Phil Chacko. All rights reserved.
//

import UIKit
import Parse
import Mixpanel

protocol GlyfSelectDelegate {
    func goToSelection(selected: PFObject?)
    func requestAlwaysAuthorization()
}

class DashboardTableViewController: UIViewController, UITableViewDelegate {
    
    let POSTEDSECTIONNUM = 0
    let STARREDSECTIONNUM = 1
    
    var delegate: GlyfSelectDelegate?
    var postedGlyfs: [PFObject]?
    var starredGlyfs: [PFObject]?
    var waitingForPostedQuery = false
    var waitingForStarredQuery = false
    
    var refresher: UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = true

        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        //refresher.attributedTitle = NSAttributedString(string: "pull to refresh")
        refresher.addTarget(self, action: "refreshTable", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        
        refreshTable()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshTable() {
                
        if PFUser.currentUser() == nil {
            return
        }
        
        let postedQuery = PFQuery(className: "locObject")
        //parseQuery.limit = PINLIMIT
        postedQuery.whereKey("userObjID", equalTo: PFUser.currentUser()!.objectId!)
        self.waitingForPostedQuery = true
        postedQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            self.postedGlyfs?.removeAll(keepCapacity: false)
            if error == nil {
                self.postedGlyfs = [PFObject]()
                if let objects = objects {
                    for object in objects {
                        self.postedGlyfs?.append(object)
                    }
                }
                self.waitingForPostedQuery = false
                self.tableView.reloadData()
                self.refresher.endRefreshing()
            }
            else {
                print(error)
                self.waitingForPostedQuery = false
                if self.waitingForStarredQuery == false {
                    self.tableView.reloadData()
                    self.refresher.endRefreshing()
                }
            }
        }
        
        let starredQuery = PFQuery(className: "locObject")
        //parseQuery.limit = PINLIMIT
        starredQuery.whereKey("heartedBy", equalTo: PFUser.currentUser()!.username!)
        self.waitingForStarredQuery = true
        starredQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            self.starredGlyfs?.removeAll(keepCapacity: false)
            if error == nil {
                self.starredGlyfs = [PFObject]()
                if objects?.count > 0 {
                    self.delegate?.requestAlwaysAuthorization()
                }
                if let objects = objects {
                    for object in objects {
                        self.starredGlyfs?.append(object)
                    }
                }
                self.waitingForStarredQuery = false
                if self.waitingForPostedQuery == false {
                    self.tableView.reloadData()
                    self.refresher.endRefreshing()
                }
            }
            else {
                print(error)
                self.waitingForStarredQuery = false
                if self.waitingForPostedQuery == false {
                    self.tableView.reloadData()
                    self.refresher.endRefreshing()
                }
            }
        }
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == POSTEDSECTIONNUM {
            return "Places you've added"
        } else if section == STARREDSECTIONNUM {
            return "Places you've starred"
        }
        
        return ""
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == POSTEDSECTIONNUM {
            if postedGlyfs != nil {
                if postedGlyfs!.count == 0 {
                    return 1
                } else {
                    return (postedGlyfs?.count)!
                }
            } else {
                return 1
            }
        } else if section == STARREDSECTIONNUM {
            if starredGlyfs != nil {
                if starredGlyfs!.count == 0 {
                    return 1
                } else {
                    return (starredGlyfs?.count)!
                }
            } else {
                return 1
            }
        } else {
            return 0
        }
    }

    @IBAction func doneTapped(sender: AnyObject) {
        //print(delegate)
        delegate?.goToSelection(nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: DashboardViewCell = tableView.dequeueReusableCellWithIdentifier("ActivityCell") as! DashboardViewCell

        var object:PFObject!
        
        if indexPath.section == POSTEDSECTIONNUM {
            if (postedGlyfs == nil) || (postedGlyfs?.count == 0) {
                let image = UIImage(named: "PostedPlaceholder.png")
                cell.lblPostTitle.text = ""
                cell.lblPlaceName.text = ""
                cell.lblPostedBy.text = ""
                cell.imgPlaceIcon.image = nil
                cell.imgBackground.image = image
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.userInteractionEnabled = false
                return cell
            } else {
                object = self.postedGlyfs![indexPath.row]
            }
        } else if indexPath.section == STARREDSECTIONNUM {
            if (starredGlyfs == nil) || (starredGlyfs?.count == 0) {
                let image = UIImage(named: "StarredPlaceholder.png")
                cell.lblPostTitle.text = ""
                cell.lblPlaceName.text = ""
                cell.lblPostedBy.text = ""
                cell.imgPlaceIcon.image = nil
                cell.imgBackground.image = image
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.userInteractionEnabled = false
                return cell
            } else {
                object = self.starredGlyfs![indexPath.row]
            }
        } else {
            return cell
        }
        
        cell.lblPostTitle.text = object["postTitle"] as? String
        cell.lblPlaceName.text = object["placeName"] as? String
        cell.lblPostedBy.text = object["userString"] as? String
        cell.imgBackground.image = UIImage(named: "CellBackgr.png")

        var pinimage = ""
        
        if let viewedBy = object["viewedBy"] as? [String] {
            if viewedBy.contains((PFUser.currentUser()!.username!)) {
                //println("Already viewed.")
                pinimage = "gray-"
            }
        }
        if let heartedBy = object["heartedBy"] as? [String] {
            if heartedBy.contains((PFUser.currentUser()!.username!)) {
                pinimage = "starred-"
            }
        }
        if let typeString = object["placeType"] as? String {
            switch typeString {
            case "Entertainment":
                pinimage = pinimage + "icon-entertainment.png"
            case "Food":
                pinimage = pinimage + "icon-food.png"
            case "History":
                pinimage = pinimage + "icon-history.png"
            case "Nature":
                pinimage = pinimage + "icon-nature.png"
            case "_Chat":
                pinimage = pinimage + "icon-chat.png"
            default:
                pinimage = pinimage + "icon-misc.png"
            }
        }
        else {
            pinimage = pinimage + "icon-misc.png"
        }
        
        cell.imageName = pinimage
        let thumb = UIImage(named: pinimage)
        cell.imgPlaceIcon.image = thumb
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == POSTEDSECTIONNUM {
            Mixpanel.sharedInstance().track("SelectedPostedFromActivity")
            self.delegate?.goToSelection(postedGlyfs?[indexPath.row])
        } else if indexPath.section == STARREDSECTIONNUM {
            Mixpanel.sharedInstance().track("SelectedStarredFromActivity")
            self.delegate?.goToSelection(starredGlyfs?[indexPath.row])
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
