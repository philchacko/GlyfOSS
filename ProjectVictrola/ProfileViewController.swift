//
//  ProfileViewController.swift
//  Glyf
//
//  Created by Philip Chacko on 8/12/15.
//  Copyright (c) 2015 Phil Chacko. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import FBSDKCoreKit
import FBSDKLoginKit

protocol ProfileViewControllerDelegate {
    func dismissProfileView()
}

class ProfileViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var delegate: ProfileViewControllerDelegate?
    var screenimage = ""
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var linkFBBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Due to FB Login issues.
        linkFBBtn.hidden = true

        // Do any additional setup after loading the view.
        userLabel.text = PFUser.currentUser()!.username
        if screenimage != "" {
            imgProfilePic.image = UIImage(named: screenimage)
        }
        
        if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
            linkFBBtn.enabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func logoutPressed(sender: AnyObject) {
        PFUser.logOut()
        PFFacebookUtils.facebookLoginManager().logOut()
        self.performSegueWithIdentifier("segueLoginView", sender: self)
        //self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func viewSwipedUp(sender: AnyObject) {
        delegate?.dismissProfileView()
        //self.performSegueWithIdentifier("SegueBackHome", sender: self)
        //self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func linkToFB(sender: AnyObject) {
        
        let facebookReadPermissions = ["public_profile", "email", "user_friends"]

        if FBSDKAccessToken.currentAccessToken() != nil {
            
            print("FB user logged in...")
            
            let graphReq = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,email,name"])
            graphReq.startWithCompletionHandler({ (connection, result, error) -> Void in
                if ((error) != nil)
                {
                    // Process error
                    print("Error: \(error)")
                }
                else
                {
                    print("fetched user: \(result)")
                    let userName = result.valueForKey("name") as! String
                    print("User Name is: \(userName)")
                    let userEmail = result.valueForKey("email") as! String
                    print("User Email is: \(userEmail)")
                    
                    // Query Parse for user email
                    
                    if PFUser.currentUser()?.email == userEmail {
                        print("FB and Parse emails match. Attempt link...")
                        PFFacebookUtils.linkUserInBackground(PFUser.currentUser()!, withReadPermissions: facebookReadPermissions, block: { (success, error) -> Void in
                            print("In fbutils callback...")
                            if error != nil {
                                print(error)
                            } else {
                                print("Success: \(success)")
                                self.linkFBBtn.enabled = false
                            }
                        })
                    } else {
                        print("Email mismatch...")
                    }
                    
                    // If exists, merge info into user (if necessary) and sign in user
                    // Iff FB id already associated with user
                    
                    // If doesn't exist, create Parse user and sign in
                }
            })
            

            return
        }
        
        print("FB access token nil")
        
        FBSDKLoginManager().logInWithReadPermissions(facebookReadPermissions, fromViewController: self) { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if error != nil {
                //According to Facebook:
                //Errors will rarely occur in the typical login flow because the login dialog
                //presented by Facebook via single sign on will guide the users to resolve any errors.
                
                // Process error
                PFUser.logOut()
                PFFacebookUtils.facebookLoginManager().logOut()
                self.performSegueWithIdentifier("segueLoginView", sender: self)
                
                // TODO: failureBlock(error)
                
            } else if result.isCancelled {
                //Handle cancellations
                FBSDKLoginManager().logOut()
                
                // TODO: failureBlock(nil)
                
            } else {
                // If you ask for multiple permissions at once, you
                // should check if specific permissions missing
                var allPermsGranted = true
                
                //result.grantedPermissions returns an array of _NSCFString pointers
                let grantedPermsCast = result.grantedPermissions as NSSet
                let grantedPermissions = grantedPermsCast.allObjects.map( {"\($0)"} )
                for permission in facebookReadPermissions {
                    if !grantedPermissions.contains(permission) {
                        allPermsGranted = false
                        break
                    }
                }
                if allPermsGranted {
                    // Do work
                    //let fbToken = result.token
                    //let fbUserID = result.token.userID
                    
                    let graphReq = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,email,name"])
                    graphReq.startWithCompletionHandler({ (connection, result, error) -> Void in
                        if ((error) != nil)
                        {
                            // Process error
                            print("Error: \(error)")
                        }
                        else
                        {
                            print("fetched user: \(result)")
                            let userName = result.valueForKey("name") as! String
                            print("User Name is: \(userName)")
                            let userEmail = result.valueForKey("email") as! String
                            print("User Email is: \(userEmail)")
                            
                            // Query Parse for user email
                            
                            if PFUser.currentUser()?.email == userEmail {
                                print("FB and Parse emails match. Attempt link...")
                                if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
                                    print("Already linked...")
                                }
                                let user = PFUser.currentUser()!
                                PFFacebookUtils.linkUserInBackground(user, withReadPermissions: facebookReadPermissions, block: { (success, error) -> Void in
                                    print("In fbutils callback...")
                                    if error != nil {
                                        print(error)
                                        return
                                    } else {
                                        print("Success: \(success)")
                                        self.linkFBBtn.enabled = false
                                        return
                                    }
                                })
                            } else {
                                print("Email mismatch...")
                            }
                            
                            print("End of fb login block")
                            // If exists, merge info into user (if necessary) and sign in user
                            // Iff FB id already associated with user
                            
                            // If doesn't exist, create Parse user and sign in
                        }
                    })
                    
                    //Send fbToken and fbUserID to your web API for processing, or just hang on to that locally if needed
                    //self.post("myserver/myendpoint", parameters: ["token": fbToken, "userID": fbUserId]) {(error: NSError?) ->() in
                    //	if error != nil {
                    //		failureBlock(error)
                    //	} else {
                    //		successBlock(maybeSomeInfoHere?)
                    //	}
                    //}
                    
                    // TODO: successBlock()
                } else {
                    //The user did not grant all permissions requested
                    //Discover which permissions are granted
                    //and if you can live without the declined ones
                    
                    //TODO: failureBlock((nil)
                }
            }
        }

        
        
    }
    
    @IBAction func legalButtonTapped(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.glyf.io/legal")!)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
