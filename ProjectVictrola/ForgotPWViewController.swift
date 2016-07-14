//
//  ForgotPWViewController.swift
//  Glyf
//
//  Created by Philip Chacko on 9/20/15.
//  Copyright (c) 2015 Phil Chacko. All rights reserved.
//

import UIKit
import Parse

class ForgotPWViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var lblErrorMess: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var lblInstructionsSent: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSendPWReset(sender: AnyObject) {
        var email = ""
        if txtEmail.text != nil {
            email = txtEmail.text!
        }
        PFUser.requestPasswordResetForEmailInBackground(email, block: { (success, error) -> Void in
            if success {
                self.lblInstructionsSent.hidden = false
                
                let delayInSec:UInt64 = 2
                let delayInN:Int64 = Int64(delayInSec * NSEC_PER_SEC)
                let popTime = dispatch_time(DISPATCH_TIME_NOW, delayInN)
                dispatch_after(popTime, dispatch_get_main_queue(), { () -> Void in
                    self.performSegueWithIdentifier("BackToLogin", sender: self)
                })
            } else {
                self.lblErrorMess.text = error?.localizedDescription
            }
        })
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
