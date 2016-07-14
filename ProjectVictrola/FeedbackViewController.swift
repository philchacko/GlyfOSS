//
//  FeedbackViewController.swift
//  Glyf
//
//  Created by Philip Chacko on 9/18/15.
//  Copyright (c) 2015 Phil Chacko. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

class FeedbackViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var lblThanks: UILabel!
    @IBOutlet weak var txtFeedback: UITextView!
    
    var locationManager = CLLocationManager()
    var userLoc:CLLocation?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        lblThanks.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtFeedback.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSendFeedback(sender: AnyObject) {
        
        print(txtFeedback.text)
        
        let feedbackObj = PFObject(className: "Feedback")
        feedbackObj["username"] = PFUser.currentUser()!.username!
        feedbackObj["FeedbackString"] = txtFeedback.text
        feedbackObj["FeedbackLocation"] = PFGeoPoint(location: userLoc)
        feedbackObj.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                UIView.animateWithDuration(0.2, animations: {
                    () -> Void in
                    self.txtFeedback.text = ""
                    self.txtFeedback.backgroundColor = UIColor.whiteColor()
                    self.lblThanks.hidden = false
                    
                    let delayInSec:UInt64 = 1
                    let delayInN:Int64 = Int64(delayInSec * NSEC_PER_SEC)
                    let popTime = dispatch_time(DISPATCH_TIME_NOW, delayInN)
                    dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("FeedbackToHome", sender: self)
                    })
                    
                    //self.consVertMapPlayer.constant += keyboardFrame.size.height
                })
            } else {
                print(error)
            }
        }
        
        
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLoc = locations[0]
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return true
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
