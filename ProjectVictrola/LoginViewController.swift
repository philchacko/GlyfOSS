//
//  LoginViewController.swift
//  ProjectVictrola
//
//  Created by Philip Chacko on 7/8/15.
//  Copyright (c) 2015 Phil Chacko. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import FBSDKCoreKit
import FBSDKLoginKit
import NZAlertView

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var signinBackgroundView: UIView!
    @IBOutlet weak var signupBackgroundView: UIView!
    @IBOutlet weak var userLoginIDTextField: UITextField!
    @IBOutlet weak var userLoginPWTextField: UITextField!
    @IBOutlet weak var userSignupIDTextField: UITextField!
    @IBOutlet weak var userSignupEmailTextField: UITextField!
    @IBOutlet weak var userSignupPWTextField: UITextField!
    @IBOutlet weak var userRepeatPWTextField: UITextField!
    
    @IBOutlet weak var fbLoginBtn: UIButton!
    @IBOutlet weak var loginErrorLabel: UILabel!
    
    @IBOutlet weak var consLoginviewView: NSLayoutConstraint!
    @IBOutlet weak var consSingupviewView: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Due to problems with FB login.
        self.fbLoginBtn.hidden = true

        // Do any additional setup after loading the view.
        self.userLoginIDTextField.delegate = self
        self.userLoginPWTextField.delegate = self
        self.userSignupIDTextField.delegate = self
        self.userSignupEmailTextField.delegate = self
        self.userSignupPWTextField.delegate = self
        self.userRepeatPWTextField.delegate = self
    }
    
    override func viewDidDisappear(animated: Bool) {
        print(PFUser.currentUser())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displaySignupView() {
        
        if self.userLoginIDTextField.isFirstResponder() {
            self.userLoginIDTextField.resignFirstResponder()
        }
        
        if self.userLoginPWTextField.isFirstResponder() {
            self.userLoginPWTextField.resignFirstResponder()
        }
        
        NSLayoutConstraint.deactivateConstraints([consLoginviewView, consSingupviewView])
        
        consLoginviewView = NSLayoutConstraint(item: signinBackgroundView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: -80)
        consSingupviewView = NSLayoutConstraint(item: signupBackgroundView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activateConstraints([consLoginviewView, consSingupviewView])
        
        
        // Reorient views.
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func displayLoginView() {
        
        if self.userSignupIDTextField.isFirstResponder() {
            self.userSignupIDTextField.resignFirstResponder()
        }
        
        if self.userSignupEmailTextField.isFirstResponder() {
            self.userSignupEmailTextField.resignFirstResponder()
        }
        
        if self.userSignupPWTextField.isFirstResponder() {
            self.userSignupPWTextField.resignFirstResponder()
        }
        
        if self.userRepeatPWTextField.isFirstResponder() {
            self.userRepeatPWTextField.resignFirstResponder()
        }
        
        NSLayoutConstraint.deactivateConstraints([consLoginviewView, consSingupviewView])
        
        consLoginviewView = NSLayoutConstraint(item: signinBackgroundView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        consSingupviewView = NSLayoutConstraint(item: signupBackgroundView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 80)
        
        NSLayoutConstraint.activateConstraints([consLoginviewView, consSingupviewView])

        
        // Reorient views.
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
        
    }

    func processLoginFieldEntries() {
        var userId:String = ""
        var passwordEntry:String = ""
        if userLoginIDTextField.text != nil {
            userId = userLoginIDTextField.text!
        }
        if userLoginPWTextField.text != nil {
            passwordEntry = userLoginPWTextField.text!
        }
        var textError = false
        let noUsernameText = "username"
        let noPasswordText = "password"
        var errorText = "No "
        let errorTextJoin = " or "
        let errorTextEnding = " entered"
        
        if (userId.characters.count == 0 || passwordEntry.characters.count == 0) {
            textError = true
            
            // Set up the keyboard for the first field missing input:
            if (passwordEntry.characters.count == 0) {
                userLoginPWTextField.becomeFirstResponder()
            }
            if (userId.characters.count == 0) {
                userLoginIDTextField.becomeFirstResponder()
            }
        }
        
        if (userId.characters.count == 0) {
            textError = true
            errorText = errorText + noUsernameText
        }
        
        if (passwordEntry.characters.count == 0) {
            textError = true
            if (userId.characters.count == 0) {
                errorText = errorText + errorTextJoin
            }
            errorText = errorText + noPasswordText
        }
        
        if (textError) {
            // Uh oh, show the user what's wrong
            loginErrorLabel.text = errorText + errorTextEnding
            return;
        }
        
        PFUser.logInWithUsernameInBackground(userId, password: passwordEntry) {
            (user: PFUser?, error: NSError?) -> Void in
            if (user != nil) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("loginToHome", sender: self)
                    //self.dismissViewControllerAnimated(false, completion: nil)
                }
            }
            else {
                // Handle error path.                
                if let message = error?.userInfo["error"] {
                    self.loginErrorLabel.text = "\(message)"
                }
            }
        }
    }
    
    func processSignupFieldEntries() {
        var userId = ""
        var email = ""
        var password = ""
        var repeatPW = ""
        if userSignupIDTextField.text != nil {
            userId = userSignupIDTextField.text!
        }
        if userSignupEmailTextField.text != nil {
            email = userSignupEmailTextField.text!
        }
        if userSignupPWTextField.text != nil {
            password = userSignupPWTextField.text!
        }
        if userRepeatPWTextField.text != nil {
            repeatPW = userRepeatPWTextField.text!
        }
        var textError = false
        let noUsernameText = "username"
        let noPasswordText = "password"
        var errorText = "No "
        let errorTextJoin = " or "
        let errorTextEnding = " entered"
        
        if (userId.characters.count == 0 || password.characters.count == 0) {
            textError = true
            
            // Set up the keyboard for the first field missing input:
            if (password.characters.count == 0) {
                userSignupPWTextField.becomeFirstResponder()
            }
            if (userId.characters.count == 0) {
                userSignupIDTextField.becomeFirstResponder()
            }
        }
        
        if (userId.characters.count == 0) {
            textError = true
            errorText = errorText + noUsernameText
        }
        
        if (password.characters.count == 0) {
            textError = true
            if (userId.characters.count == 0) {
                errorText = errorText + errorTextJoin
            }
            errorText = errorText + noPasswordText
        }
        
        if ((textError == false) && (password != repeatPW)) {
            textError = true
            errorText = "Mismatched passwords"
        }
        
        if (textError) {
            // Uh oh, show the user what's wrong
            loginErrorLabel.text = errorText + errorTextEnding
            return;
        }
        
        let user = PFUser()
        user.username = userId
        user.password = password
        user.email = email
        user.signUpInBackgroundWithBlock{
            (succeeded: Bool, error: NSError?) -> Void in
            if (error != nil) {
                // Display an alert view to show the error message
                self.loginErrorLabel.text = "Error - User possibly exists"
                if let message: AnyObject = error!.userInfo["error"] {
                    print("\(message)")
                }
                // Bring the keyboard back up, because they probably need to change something.
                self.userSignupIDTextField.becomeFirstResponder()
                return
            }
            else {
                // Handle the success path
                if FBSDKAccessToken.currentAccessToken() != nil {
                    PFFacebookUtils.linkUserInBackground(PFUser.currentUser()!, withAccessToken: FBSDKAccessToken.currentAccessToken())
                    PFFacebookUtils.linkUserInBackground(PFUser.currentUser()!, withAccessToken: FBSDKAccessToken.currentAccessToken(), block: { (success, error) -> Void in
                        
                        if error != nil {
                            print("FB link failed, but signed up new user.")
                        }
                        
                        self.performSegueWithIdentifier("loginToHome", sender: self)
                        //self.dismissViewControllerAnimated(false, completion: nil)
                    })
                } else {
                    self.performSegueWithIdentifier("loginToHome", sender: self)
                    //self.dismissViewControllerAnimated(false, completion: nil)
                }
            }
        }
    }

    @IBAction func fbLoginTapped(sender: AnyObject) {
        
        let facebookReadPermissions = ["public_profile", "email", "user_friends"]
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            //For debugging, when we want to ensure that facebook login always happens
            
            /* MAY NOT WANT THIS, because email match not checked
            PFFacebookUtils.logInInBackgroundWithAccessToken(FBSDKAccessToken.currentAccessToken(), block: { (user, error) -> Void in
                if error != nil {
                    print(error)
                } else {
                    print("User logged in via FB.")
                }
            })*/
            
            FBSDKLoginManager().logOut()
            //Otherwise do:
            return
        }
        
        /*
        PFFacebookUtils.logInInBackgroundWithReadPermissions(facebookReadPermissions) { (user, error) -> Void in
            if let user = user {
                if user.isNew {
                    print("User signed up via FB")
                    // Go to screenname creation flow
                    
                    DO THIS THING HERE
                    let randomPW = PasswordGenerator().generate()
        
                    self.userSignupEmailTextField.text = userEmail
                    self.userSignupPWTextField.text = randomPW
                    self.userRepeatPWTextField.text = randomPW
                    self.displaySignupView()
                    
                } else {
                    print("User login via FB")
                    // Log in user, go to home
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("loginToHome", sender: self)
                    }
                }
            } else {
                print("Error: Cancelled fb login...")
            }
        }
        */
        
        
        FBSDKLoginManager().logInWithReadPermissions(facebookReadPermissions, fromViewController: self) { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if error != nil {
                //According to Facebook:
                //Errors will rarely occur in the typical login flow because the login dialog
                //presented by Facebook via single sign on will guide the users to resolve any errors.
            
                // Process error
                FBSDKLoginManager().logOut()
                
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
                    let fbToken = result.token
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
                            let userNameOpt = result.valueForKey("name") as? String
                            let userEmailOpt = result.valueForKey("email") as? String
                            
                            if userNameOpt == nil {
                                let alert = NZAlertView(style: NZAlertStyle.Error, title: "Login Failed", message: "Facebook login error. =( Try signing up with Email and Password.")
                                alert.showWithCompletion({ () -> Void in
                                    FBSDKLoginManager().logOut()
                                    PFUser.logOut()
                                    return
                                })
                            } else if userNameOpt!.isEmpty {
                                let alert = NZAlertView(style: NZAlertStyle.Error, title: "Login Failed", message: "Facebook login error. =( Try signing up with Email and Password.")
                                alert.showWithCompletion({ () -> Void in
                                    FBSDKLoginManager().logOut()
                                    PFUser.logOut()
                                    return
                                })
                            }
                            
                            if userEmailOpt == nil {
                                let alert = NZAlertView(style: NZAlertStyle.Error, title: "Login Failed", message: "Facebook login error. =( Try signing up with Email and Password.")
                                alert.showWithCompletion({ () -> Void in
                                    FBSDKLoginManager().logOut()
                                    PFUser.logOut()
                                    return
                                })
                            } else if userEmailOpt!.isEmpty {
                                let alert = NZAlertView(style: NZAlertStyle.Error, title: "Login Failed", message: "Facebook login error. =( Try signing up with Email and Password.")
                                alert.showWithCompletion({ () -> Void in
                                    FBSDKLoginManager().logOut()
                                    PFUser.logOut()
                                    return
                                })
                            }
                            
                            //let userName = userNameOpt!
                            let userEmail = userEmailOpt!
                            
                            //print("fetched user: \(result)")
                            //print("User Name is: \(userName)")
                            //print("User Email is: \(userEmail)")
                            
                            // Check here to fix bug where FB user logs in w/o email
                            
                            
                            // Query Parse for user email
                            
                            let userQuery = PFUser.query()
                            userQuery?.whereKey("email", equalTo: userEmail)
                            userQuery?.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                                if error == nil {
                                    print("Found PFUser: \(object)")
                                    //let matchingUser = object as! PFUser
                                    PFFacebookUtils.logInInBackgroundWithAccessToken(fbToken, block: { (userpf, error) -> Void in
                                        if error != nil {
                                            let alert = NZAlertView(style: NZAlertStyle.Error, title: "Login Failed", message: "That email is already signed up! Login via email and link to Facebook in your profile.")
                                            alert.showWithCompletion({ () -> Void in
                                                FBSDKLoginManager().logOut()
                                                PFUser.logOut()
                                            })
                                        } else {
                                            if PFUser.currentUser() != nil {
                                                //print("PFFacebookUtils login succeeded. Go to home.")
                                                dispatch_async(dispatch_get_main_queue()) {
                                                    self.performSegueWithIdentifier("loginToHome", sender: self)
                                                    //self.dismissViewControllerAnimated(false, completion: nil)
                                                }
                                            } else {
                                                let alert = NZAlertView(style: NZAlertStyle.Error, title: "Login Failed", message: "Log in failed. =( Try signing in via email.")
                                                alert.showWithCompletion({ () -> Void in
                                                    FBSDKLoginManager().logOut()
                                                    PFUser.logOut()
                                                })
                                            }
                                            
                                        }
                                    })
                                } else if error!.code == 101 {
                                    // Create new user and link.
                                    
                                    let randomPW = PasswordGenerator().generate()
                                    self.userSignupEmailTextField.text = userEmail
                                    self.userSignupPWTextField.text = randomPW
                                    self.userRepeatPWTextField.text = randomPW
                                    
                                    let alert = NZAlertView(style: NZAlertStyle.Success, title: "Linked to Facebook!", message: "Please choose an awesome public display name.")
                                    alert.showWithCompletion({ () -> Void in
                                        self.displaySignupView()
                                    })
                                }
                            })
                            
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
                    
                    FBSDKLoginManager().logOut()
                    PFUser.logOut()
                    
                    //TODO: failureBlock((nil)
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func loginBtnTapped(sender: AnyObject) {
        self.processLoginFieldEntries()
    }
    
    @IBAction func signupBtnTapped(sender: AnyObject) {
        // Code to hide the keyboards for text fields
        self.displaySignupView()
    }
    
    @IBAction func createUserBtnTapped(sender: AnyObject) {
        self.processSignupFieldEntries()
    }
    
    @IBAction func cancelBtnTapped(sender: AnyObject) {
        // Code to hide keyboards
        self.displayLoginView()
    }
    
    @IBAction func legalButtonTapped(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.glyf.io/legal")!)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension Array {
    func randomItem() -> Element? {
        let idx = Int(arc4random()) % count
        return self[idx]
    }
    
    // Could contain duplicates
    func randomItems(total: Int) -> [Element] {
        var result: [Element] = []
        for _ in (0..<total) {
            if let item = randomItem() {
                result += [item]
            }
        }
        return result
    }
    
    func shuffleItems() -> [Element] {
        var newArray = self
        for i in (0..<newArray.count) {
            let j = Int(arc4random()) % newArray.count
            newArray.insert(newArray.removeAtIndex(j), atIndex: i)
        }
        return newArray
    }
}

extension String {
    func split(bySeparator: String) -> Array<String> {
        if bySeparator.characters.count < 1 {
            var items: [String] = []
            for c in self.characters {
                items.append(String(c))
            }
            return items
        }
        return self.componentsSeparatedByString(bySeparator)
    }
}

class PasswordGenerator {
    let lowercaseSet = "abcdefghijklmnopqrstuvwxyz".split("")
    let uppercaseSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("")
    let symbolSet    = "!@#$%^&*?".split("")
    let numberSet    = "0123456789".split("")
    
    var numbers   = 5
    var lowercase = 5
    var uppercase = 5
    var symbols   = 5
    
    func generate() -> String {
        var password: [String] = []
        password += lowercaseSet.randomItems(lowercase)
        password += uppercaseSet.randomItems(uppercase)
        password += numberSet.randomItems(numbers)
        password += symbolSet.randomItems(symbols)
        return password.shuffleItems().reduce("") { (a, b) -> String in a+b }
    }
}
