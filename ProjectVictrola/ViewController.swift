//
//  ViewController.swift
//  ProjectVictrola
//
//  Created by Phil Chacko on 5/24/15.
//  Copyright (c) 2015 Phil Chacko. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse
import GoogleMaps
import Mixpanel

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, addrPickProtocol {

    @IBOutlet var homeView: UIView!
//    @IBOutlet var youtubeView: YTPlayerView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnPostNew: UIButton!
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var txtPostTitle: UITextField!
    @IBOutlet weak var txtRawPostString: UITextField!
    @IBOutlet weak var btnShuffle: UIButton!
    @IBOutlet weak var btnCenterUser: UIButton!
    @IBOutlet weak var labelHomeLoc: UILabel!
    @IBOutlet weak var btnAddrPicker: UIButton!
    @IBOutlet weak var viewGlyfContent: UIView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var navWebBar: UIToolbar!
    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var btnToProfile: UIButton!
    @IBOutlet var gestSwipeCollDown: UISwipeGestureRecognizer!
    @IBOutlet var gestSwipeCollUp: UISwipeGestureRecognizer!
    @IBOutlet var gestWebTouched: UITapGestureRecognizer!
    @IBOutlet weak var viewTopNav: UIView!
    @IBOutlet weak var addrPin: UIButton!
    @IBOutlet weak var imgMask: UIImageView!
    @IBOutlet weak var mapOverlay: MapOverlayView!
    @IBOutlet weak var btnFeedback: UIButton!
    @IBOutlet weak var btnWebBack: UIBarButtonItem!
    @IBOutlet weak var btnWebForward: UIBarButtonItem!
    
    //Constraint Outlets
    //@IBOutlet weak var mapHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var consVertMapPost: NSLayoutConstraint!
    @IBOutlet weak var consVertMapContent: NSLayoutConstraint!
    @IBOutlet weak var consMapHeight: NSLayoutConstraint!
    @IBOutlet weak var consTopnavView: NSLayoutConstraint!
    @IBOutlet weak var consWebBottom: NSLayoutConstraint!
    @IBOutlet weak var consNavWebBottom: NSLayoutConstraint!
    
    var consPlayerHeightMax = NSLayoutConstraint()
    var consMapViewHeightMin = NSLayoutConstraint()
    var consPlayerviewInfo = NSLayoutConstraint()
    
    let PINLIMIT = 20
    let REFRESH_DISTANCE = 0.02
    let NOTIFY_DISTANCE = 800.0
    //let DEFAULT_YTVID = "cdwal5Kw3Fc"
    let DEFAULT_WEBURL = "http://google.com"
    let GLYF_CTNT_CL_REUSEID = "GlyfContentCell"
    let SECTINSETS = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 15.0)
    let MAP_HEIGHT_SMALL = 130
    let COLL_DIST = CLLocationDistance(300)
    let dictGoogleTypes = [
        "amusement_park": "Entertainment",
        "aquarium" : "Entertainment",
        "art_gallery" : "Entertainment",
        "bakery" : "History",
        "bank" : "History",
        "bar" : "Food",
        "book_store" : "History",
        "bowling_alley" : "Entertainment",
        "bus_station" : "History",
        "cafe" : "Food",
        "campground" : "Nature",
        "casino" : "Entertainment",
        "cemetery" : "History",
        "church" : "History",
        "city_hall" : "History",
        "courthouse" : "History",
        "embassy" : "History",
        "fire_station" : "History",
        "food" : "Food",
        "grocery_or_supermarket" : "Food",
        "hindu_temple" : "History",
        "library" : "History",
        "meal_delivery" : "Food",
        "meal_takeaway" : "Food",
        "mosque" : "History",
        "movie_theater" : "Entertainment",
        "museum" : "History",
        "night_club" : "Entertainment",
        "park" : "Nature",
        "post_office" : "History",
        "restaurant" : "Food",
        "rv_park" : "Nature",
        "school" : "History",
        "stadium" : "Entertainment",
        "synagogue" : "History",
        "train_station" : "History",
        "university" : "History",
        "zoo" : "Nature"
    ]
    
    var locationManager = CLLocationManager()
    var myLocations: [CLLocation] = []
    var arrAnnotations = [GlyfPointAnnotation]()
    //var userLoc:AnyObject = AnyObject()
    var userLoc2D = CLLocationCoordinate2D()
    var lastPinLoadLoc = CLLocationCoordinate2D()
    var userLocCentered = false
    var orientation = "portrait"
    var placesClient: GMSPlacesClient?
    var postNewVC: PostNewViewController?
    var activityViewController: DashboardTableViewController?
    var profileVC: ProfileViewController?
    var mapCenterAddr: String?
    var streetAddr: String?
    var selectedGooglePlace: SelectedPlace?
    var nextSelection: String?
    var glyfCollection = [GlyfPointAnnotation]()
    var currUrl = ""
    var collectionselect = false
    var newCenterCG:CGFloat = 0
    var centerIndex = 0
    var profilePicName = ""
    var maxIndex: Int?
    var webLoadIndicator: UIActivityIndicatorView?
    var chatPlaceHolder: UIImageView?
    var deactivateAnimations = false
    
    var playerValues = [
        "controls" : 1,
        "playsinline" : 1,
        "autohide" : 1,
        "showinfo" : 0,
        "modestbranding" : 1
    ]
    
    var currentState = ""
    var seguingFromActivity = false
    var app = UIApplication.sharedApplication()
    
    //var allConstraints: [NSLayoutConstraint] = []

    func slideContentView() {
        
        if !(currentState == "contentview-visible") {
            
            deactivateAnimations = false
            
            //allConstraints = [playerViewConstraint, mapTopConstraint, mapBottomConstraint, labelBottomConstraint, mapInfoConstraint]
            //NSLayoutConstraint.deactivateConstraints(mapInfoView.constraints())
            NSLayoutConstraint.deactivateConstraints([consVertMapPost, consVertMapContent, consMapHeight, consTopnavView, consWebBottom, consNavWebBottom])
            
            //var playerHeight = youtubeView.frame.size.height
            //var infoHeight = mapInfoView.frame.size.height
            //var mapHeight = mapView.frame.size.height - infoHeight - playerHeight
            consVertMapPost = NSLayoutConstraint(item: postView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            consVertMapContent = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: viewGlyfContent, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            consMapHeight = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: CGFloat(MAP_HEIGHT_SMALL))
            consTopnavView = NSLayoutConstraint(item: viewTopNav, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            consWebBottom = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -44)
            consNavWebBottom = NSLayoutConstraint(item: navWebBar, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: webView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            
            NSLayoutConstraint.activateConstraints([consVertMapPost, consVertMapContent, consMapHeight, consTopnavView, consWebBottom, consNavWebBottom])
            //app.setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
            btnPostNew.hidden = true
            addrPin.hidden = true
            btnCenterUser.hidden = true
            btnShuffle.hidden = true
            btnFeedback.hidden = true
            self.app.setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
            
            /*if let webUrl = NSURL(string: DEFAULT_WEBURL) {
                println("Attempting to load URL...")
                let requestObj = NSURLRequest(URL: webUrl)
                webView.loadRequest(requestObj)
                println("Should show...")
            }*/
            
            currentState = "contentview-visible"
        }
        
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func setHomeView() {
        
        if !(currentState == "home") {
            //allConstraints = [playerViewConstraint, mapTopConstraint, mapBottomConstraint, labelBottomConstraint, mapInfoConstraint]
            
            deactivateAnimations = false
            webLoadIndicator?.stopAnimating()
            webView.stopLoading()
            txtPostTitle.resignFirstResponder()
            txtRawPostString.resignFirstResponder()
            
            NSLayoutConstraint.deactivateConstraints([consVertMapPost, consVertMapContent, consMapHeight, consTopnavView, consWebBottom, consNavWebBottom])
            
            //var infoHeight = mapInfoView.frame.size.height
            //var mapHeight = mapView.frame.size.height + infoHeight
        
            consVertMapPost = NSLayoutConstraint(item: postView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            consVertMapContent = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: viewGlyfContent, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            consMapHeight = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            consTopnavView = NSLayoutConstraint(item: viewTopNav, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            consWebBottom = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            consNavWebBottom = NSLayoutConstraint(item: navWebBar, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            
            //consVertMapPlayer.constant = 0
            NSLayoutConstraint.activateConstraints([consVertMapPost, consVertMapContent, consMapHeight, consTopnavView, consWebBottom, consNavWebBottom])
            app.setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
            //youtubeView.cueVideoById(DEFAULT_YTVID, startSeconds: 0, suggestedQuality: YTPlaybackQuality.Auto)
            //youtubeView.loadWithVideoId(DEFAULT_YTVID, playerVars: playerValues)
            
            glyfCollection.removeAll(keepCapacity: true)
            newCenterCG = 0
            centerIndex = 0
            
            btnPostNew.hidden = false
            addrPin.hidden = true
            btnCenterUser.hidden = false
            btnShuffle.hidden = false
            btnFeedback.hidden = false
            
            currentState = "home"
        }
        
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
        
        //println(currentState)
    }
    
    func setPostView() {
        if !(currentState == "postview-visible") {
            
            deactivateAnimations = false
            txtPostTitle.becomeFirstResponder()
            //let prevSpan = mapView.region.span
            
            NSLayoutConstraint.deactivateConstraints([consVertMapPost, consVertMapContent, consMapHeight, consTopnavView, consWebBottom, consNavWebBottom])
            
            //var infoHeight = mapInfoView.frame.size.height
            //var mapHeight = mapView.frame.size.height + infoHeight
            
            consVertMapPost = NSLayoutConstraint(item: postView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            consVertMapContent = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: viewGlyfContent, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            consMapHeight = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: postView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            consTopnavView = NSLayoutConstraint(item: viewTopNav, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            consWebBottom = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            consNavWebBottom = NSLayoutConstraint(item: navWebBar, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            
            NSLayoutConstraint.activateConstraints([consVertMapPost, consVertMapContent, consMapHeight, consTopnavView, consWebBottom, consNavWebBottom])
            app.setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
            btnPostNew.hidden = true
            addrPin.hidden = false
            btnFeedback.hidden = true
            btnCenterUser.hidden = true
            btnShuffle.hidden = true
            
            currentState = "postview-visible"
        }
        
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
            //print(self.mapView.region.span)
        }
        
        //println(currentState)
    }
    
    func setContentMaximize() {
        
        if !(currentState == "contentview-max") {
            
            deactivateAnimations = false
            
            NSLayoutConstraint.deactivateConstraints([consVertMapPost, consVertMapContent, consMapHeight, consTopnavView, consWebBottom, consNavWebBottom])
            
            consVertMapPost = NSLayoutConstraint(item: postView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            consVertMapContent = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: viewGlyfContent, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            consMapHeight = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 0)
            consTopnavView = NSLayoutConstraint(item: viewTopNav, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            consWebBottom = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -44)
            consNavWebBottom = NSLayoutConstraint(item: navWebBar, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: webView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            
            NSLayoutConstraint.activateConstraints([consVertMapPost, consVertMapContent, consMapHeight, consTopnavView, consWebBottom, consNavWebBottom])

            btnPostNew.hidden = true
            addrPin.hidden = true
            btnCenterUser.hidden = true
            btnShuffle.hidden = true
            btnFeedback.hidden = true
            self.app.setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
            
            currentState = "contentview-max"
        }
        
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func loadViewablePins(nearPoint: CLLocationCoordinate2D) {
        
        /*println("Existing map annotations =")
        for j in mapView.annotations {
            println("\(j): " + j.title!!)
        }
        println(mapView.annotations.count)*/
        
        //mapView.removeAnnotations(mapView.annotations)
        //println("Annotations removed.")
        //var arrAnnotations = [MKPointAnnotation]()
        //for i in 0..<PINLIMIT {
        //    arrAnnotations.append(MKPointAnnotation())
        //}
        
        // Read from Parse
        
        if PFUser.currentUser() == nil {
            return
        }
        
        let parseQuery = PFQuery(className: "locObject")
        let centerGeoPt = PFGeoPoint(latitude:nearPoint.latitude, longitude:nearPoint.longitude)
        parseQuery.limit = PINLIMIT
        parseQuery.whereKey("locGeoPt", nearGeoPoint:centerGeoPt)
        parseQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                self.mapView.removeAnnotations(self.mapView.annotations)
                var objCount = 0
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        if object.objectId != nil {
                            var pinimage = ""
                            
                            self.arrAnnotations[objCount].reset()
                            self.arrAnnotations[objCount].objectId = object.objectId!
                            self.arrAnnotations[objCount].coordinate = CLLocationCoordinate2D(latitude: object["locGeoPt"]!.latitude, longitude: object["locGeoPt"]!.longitude)
                            if let hearts = object["heartCount"] as? Int {
                                self.arrAnnotations[objCount].heartCount = hearts
                            }
                            if let viewedBy = object["viewedBy"] as? [String] {
                                if viewedBy.contains((PFUser.currentUser()!.username!)) {
                                    //println("Already viewed.")
                                    self.arrAnnotations[objCount].viewedByUser = true
                                    pinimage = "gray-"
                                }
                            }
                            if let heartedBy = object["heartedBy"] as? [String] {
                                self.arrAnnotations[objCount].heartedBy = heartedBy
                                if heartedBy.contains((PFUser.currentUser()!.username!)) {
                                    self.arrAnnotations[objCount].heartedByUser = true
                                    pinimage = "starred-"
                                }
                            }
                            if object["placeName"] != nil {
                                self.arrAnnotations[objCount].title = object["placeName"] as? String
                            }
                            else {
                                if object["postTitle"] != nil {
                                    self.arrAnnotations[objCount].title = object["postTitle"] as? String
                                }
                                else {
                                    self.arrAnnotations[objCount].title = ""
                                }
                            }
                            if object["postTitle"] != nil {
                                self.arrAnnotations[objCount].postText = object["postTitle"] as! String
                            } else {
                                self.arrAnnotations[objCount].postText = ""
                            }
                            if let screenname = object["userString"] as? String {
                                self.arrAnnotations[objCount].screenname = screenname
                            }
                            else {
                                self.arrAnnotations[objCount].screenname = ""
                            }
                            if let screenimage = object["profilePicName"] as? String {
                                self.arrAnnotations[objCount].screenimage = screenimage
                            }
                            else {
                                self.arrAnnotations[objCount].screenname = ""
                            }
                            if let linkUrl = object["rawPostString"] as? String {
                                self.arrAnnotations[objCount].linkUrl = linkUrl
                            } else {
                                self.arrAnnotations[objCount].linkUrl = ""
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
                            
                            self.arrAnnotations[objCount].imageName = pinimage
                            
                            objCount++
                        }
                        //println(object.objectId)
                    }
                }
                
                
                //println("Object count = \(objCount)")
                for i in 0..<objCount {
                    self.mapView.addAnnotation(self.arrAnnotations[i])
                    //println(i)
                }
                
                self.lastPinLoadLoc = nearPoint
                
            } else {
                // Log details of the failure
                //print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        //arrAnnotations.removeAll(keepCapacity: true)
        mapView.delegate = self
        for _ in 0..<PINLIMIT {
            arrAnnotations.append(GlyfPointAnnotation())
        }
        
        // Add constraints for landscape video.
        
        consPlayerHeightMax = NSLayoutConstraint(item: viewGlyfContent, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        consMapViewHeightMin = NSLayoutConstraint(item: mapView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: mapView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activateConstraints([consPlayerHeightMax, consMapViewHeightMin])
        
        //gestWebTouched.addTarget(self, action: "webTouched")
        gestWebTouched.delegate = self
        mapOverlay.delegate = self
        //webView.scrollView.delegate = self
        
        collView.addGestureRecognizer(gestSwipeCollDown)
        collView.addGestureRecognizer(gestSwipeCollUp)
        webView.addGestureRecognizer(gestWebTouched)
        
        mapView.showsPointsOfInterest = false
        if currentState == "" {
            setHomeView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deactivateAnimations = false
        
        self.txtPostTitle.delegate = self
        self.txtRawPostString.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleRotation:"), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //CHANGETHIS
        locationManager.requestWhenInUseAuthorization()
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        }
        locationManager.startUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        
        // Set up Map View
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        /*let startLocation = CLLocationCoordinate2D(
            latitude: 40.3503271,
            longitude: -74.6526857
        )*/
        
        //println(userLoc2D)

        // Set up Google
        
        placesClient = GMSPlacesClient.sharedClient()
        //youtubeView.loadWithVideoId(DEFAULT_YTVID, playerVars: playerValues)
        webView.delegate = self
        webView.stopLoading()
        webLoadIndicator?.stopAnimating()
        
        //let span = MKCoordinateSpanMake(0.02, 0.02)
        //let region = MKCoordinateRegion(center: startLocation, span: span)
        //mapView.setRegion(region, animated: true)
        /*
        NSLayoutConstraint.deactivateConstraints([mapInfoConstraint])
        mapInfoConstraint = NSLayoutConstraint(item: mapInfoView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activateConstraints([mapInfoConstraint])
        self.view.layoutIfNeeded()
        */
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let PICNUM = 8
        
        /* For testing
        let fireTime = NSDate(timeIntervalSinceNow: 3)
        let localNotification = UILocalNotification()
        localNotification.alertBody = "Opened Glyf."
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.fireDate = fireTime
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
*/
        
        super.viewDidAppear(false)
        //print("View did appear.")
        
        let currentUser = PFUser.currentUser()
        if (currentUser == nil) {
            //print("Segue to login...")
            self.performSegueWithIdentifier("pushLoginView", sender: self)
            //self.dismissViewControllerAnimated(false, completion: nil)
        } else {
            
            let query = PFQuery(className: "UserProfiles")
            query.whereKey("userObjId", equalTo: currentUser!.objectId!)
            query.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                if error != nil {
                    //println(error)
                    let error101 = error!.code
                    if error101 == 101 {
                        let randomnum = Int(arc4random_uniform(UInt32(PICNUM)) + 1)
                        let imagename = "anml\(randomnum).png"
                        self.profilePicName = imagename
                        let object = PFObject(className: "UserProfiles")
                        object["userObjId"] = currentUser!.objectId!
                        object["userString"] = currentUser!.username!
                        object["profilePicName"] = imagename
                        object.saveInBackground()
                    }
                } else {
                    if let object = object {
                        if (object["profilePicName"] != nil) {
                            let picname = object["profilePicName"] as! String
                            if picname == "" {
                                let randomnum = Int(arc4random_uniform(UInt32(PICNUM)) + 1)
                                let imagename = "anml\(randomnum).png"
                                object["profilePicName"] = imagename
                                object.saveInBackground()
                            }
                            self.profilePicName = picname
                            /*let thumbname = "thumb-" + picname
                            let thumbimg = UIImage(named: thumbname)
                            self.btnToProfile.setImage(thumbimg, forState: UIControlState.Normal)
                            if thumbimg != nil {
                                self.imgMask.hidden = true
                            }*/
                        } else {
                            // Add profile pic default
                            let randomnum = Int(arc4random_uniform(UInt32(PICNUM)) + 1)
                            let imagename = "anml\(randomnum).png"
                            object["profilePicName"] = imagename
                            object.saveInBackground()
                            self.profilePicName = imagename
                            /*let thumbname = "thumb-" + imagename
                            let thumbimg = UIImage(named: thumbname)
                            self.btnToProfile.setImage(thumbimg, forState: UIControlState.Normal)
                            if thumbimg != nil {
                                self.imgMask.hidden = true
                            }*/
                        }
                    } else {
                        // Fill in empty profile data
                        let randomnum = Int(arc4random_uniform(UInt32(PICNUM)) + 1)
                        let imagename = "anml\(randomnum).png"
                        self.profilePicName = imagename
                        let object = PFObject(className: "UserProfiles")
                        object["userObjId"] = currentUser!.objectId!
                        object["userString"] = currentUser!.username!
                        object["profilePicName"] = imagename
                        object.saveInBackground()
                        /*let thumbname = "thumb-" + imagename
                        let thumbimg = UIImage(named: thumbname)
                        self.btnToProfile.setImage(thumbimg, forState: UIControlState.Normal)
                        if thumbimg != nil {
                            self.imgMask.hidden = true
                        }*/
                    }
                    
                }
            })
            
            // Set up Mixpanel for user. Get time first
            let lastLoginDate = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let dateString = formatter.stringFromDate(lastLoginDate)
            
            Mixpanel.sharedInstance().identify(PFUser.currentUser()!.objectId!)
            Mixpanel.sharedInstance().people.set([
                "$username" : PFUser.currentUser()!.username!,
                "$first_name" : PFUser.currentUser()!.username!,
                "$last_login" : dateString
                ])
        }
        
        let query = PFQuery(className: "locObject")
        query.orderByDescending("index")
        query.getFirstObjectInBackgroundWithBlock { (maxObj, error) -> Void in
            if error != nil {
                print(error)
                
            } else {
                if let maxObj = maxObj {
                    self.maxIndex = maxObj["index"] as? Int
                }
            }
        
        }
        
        if seguingFromActivity {
            for j in 0..<arrAnnotations.count {
                if self.arrAnnotations[j].objectId == self.nextSelection {
                    //print("Next selection found, attempt to select annotation.")
                    self.mapView.selectAnnotation(self.arrAnnotations[j], animated: true)
                    self.nextSelection = nil
                    break
                }
                //self.nextSelection = nil
            }
        } else {
            userLocCentered = false
            loadViewablePins(userLoc2D)
            seguingFromActivity = false
        }
        
        //navWebBar.hidden = true //CHANGETHIS
        /*
        if nextSelection == nil {
            userLocCentered = false
            loadViewablePins(userLoc2D)
        } else {
            for j in 0..<arrAnnotations.count {
                if self.arrAnnotations[j].objectId == self.nextSelection {
                    //print("Next selection found, attempt to select annotation.")
                    self.mapView.selectAnnotation(self.arrAnnotations[j], animated: true)
                    self.nextSelection = nil
                    break
                }
                //self.nextSelection = nil
            }
        }*/
        //self.slideMapLabel()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        deactivateAnimations = true
    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        //println(locations)
        
        if (selectedGooglePlace != nil) || (nextSelection != nil) {
            userLocCentered = true
        }
        
        if userLocCentered == false {
            
            //print("Going to user location.")
            let userLoc = locations[0] 
            userLoc2D = CLLocationCoordinate2DMake(userLoc.coordinate.latitude, userLoc.coordinate.longitude)
            let span = MKCoordinateSpanMake(0.02, 0.02)
            let region = MKCoordinateRegion(center: userLoc2D, span: span)
            mapView.setRegion(region, animated: true)
            
            userLocCentered = true

        }
        //mapLabel.text = "\(locations[0])"
        //myLocations.append(locations[0] as! CLLocation)
        
        //let spanX = 0.007
        //let spanY = 0.007
        //var newRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        //mapView.setRegion(newRegion, animated: true)
        
        if UIApplication.sharedApplication().applicationState == .Background {

            locationManager.startMonitoringSignificantLocationChanges()
            //let currentime = NSDate.timeIntervalSinceReferenceDate()
            //print("Loc update in background. Time: \(currentime)")
            let lastLoadLoc = CLLocation(latitude: lastPinLoadLoc.latitude, longitude: lastPinLoadLoc.longitude)
            let currentLoc = locations[0]
            if currentLoc.distanceFromLocation(lastLoadLoc) > NOTIFY_DISTANCE {
                //print("Check for starred places...")
                lastPinLoadLoc = currentLoc.coordinate
                /*let dist = currentLoc.distanceFromLocation(lastLoadLoc)
                print("Distance crossed: \(dist)")*/
                let notifyQuery = PFQuery(className: "locObject")
                let centerGeoPt = PFGeoPoint(location: currentLoc)
                let filterDistanceKm = NOTIFY_DISTANCE * 0.001 * 0.7
                //notifyQuery.whereKey("locGeoPt", nearGeoPoint:centerGeoPt)
                notifyQuery.whereKey("locGeoPt", nearGeoPoint: centerGeoPt, withinKilometers: filterDistanceKm)
                notifyQuery.whereKey("heartedBy", equalTo: PFUser.currentUser()!.username!)
                notifyQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    //print("Query returned")
                    if error != nil {
                        //print("Error returned.")
                        print(error)
                    } else {
                        //print("Objects found.")
                        if let objects = objects {
                            /*var starredObjects = objects
                            var count = starredObjects.count
                            for var i = 0; i < count; i++ {
                                let checkObj = objects[i]
                                if let heartedBy = checkObj["heartedBy"] as? [String] {
                                    if !(heartedBy.contains((PFUser.currentUser()!.username!))) {
                                        starredObjects.removeAtIndex(i)
                                        count--
                                    }
                                }
                            }
                            
                            count = starredObjects.count*/
                            let count = objects.count
                            
                            if count > 1 {
                                //print("Multiple objects.")
                                let fireTime = NSDate(timeIntervalSinceNow: 5)
                                let localNotification = UILocalNotification()
                                localNotification.alertBody = "You've got \(count) starred places nearby."
                                localNotification.soundName = UILocalNotificationDefaultSoundName
                                localNotification.fireDate = fireTime
                                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                            } else if count == 1 {
                                //print("Single object?")
                                //print(objects)
                                //let notifyObj = starredObjects[0]
                                
                                UIApplication.sharedApplication().cancelAllLocalNotifications()
                                
                                let notifyObj = objects[0]
                                let title = notifyObj["postTitle"]
                                let fireTime = NSDate(timeIntervalSinceNow: 5)
                                let localNotification = UILocalNotification()
                                localNotification.alertBody = "Your starred place is nearby: \(title)"
                                localNotification.soundName = UILocalNotificationDefaultSoundName
                                localNotification.fireDate = fireTime
                                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                            }
                        } else {
                            //print(starr)
                        }
                    }
                    self.lastPinLoadLoc = currentLoc.coordinate
                })
            } else {
                //print("too close to last load loc.")
            }
            //print("SigChange LocMgr: \(locations[0])")
            //print("Last Load: \(lastPinLoadLoc)")
        } else if UIApplication.sharedApplication().applicationState == .Active {
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //print("Active LocMgr: \(locations[0])")
        }
    }
    /*
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
        
        let errorMessage = error.description
        let fireTime = NSDate(timeIntervalSinceNow: 3)
        let localNotification = UILocalNotification()
        localNotification.alertBody = errorMessage
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.fireDate = fireTime
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }*/
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        //youtubeView.cueVideoById(view.annotation.subtitle, startSeconds: 0, suggestedQuality: YTPlaybackQuality.Auto)
        //youtubeView.loadWithVideoId(glyfAnnotation.linkUrl, playerVars: playerValues)
        //mapLabel.text = view.annotation.title
        
        if view.annotation is MKUserLocation {
            return
        }
        
        let glyfAnnotation = view.annotation as! GlyfPointAnnotation
        let objId = glyfAnnotation.objectId
        let viewedByUser = glyfAnnotation.viewedByUser
        
        let query = PFQuery(className: "locObject")
        query.getObjectInBackgroundWithId(objId, block: { (object: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            }
            else if let object = object {
                object.incrementKey("viewCount")
                if viewedByUser == false {
                    object.incrementKey("viewCountUnique")
                }
                object.addUniqueObject(PFUser.currentUser()!.username!, forKey: "viewedBy")
                object.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if error != nil {
                        print(error)
                    }
                    else {
                        if glyfAnnotation.objectId == objId {
                            glyfAnnotation.viewedByUser = true
                        }
                    }
                })
                if glyfAnnotation.objectId == objId {
                    glyfAnnotation.viewedByUser = true
                }

            }
        })
        
        if collectionselect == true {
            return
        }
        
        centerIndex = 0
        newCenterCG = 0
        webView.stopLoading()
        var loadUrl = glyfAnnotation.linkUrl
        
        if loadUrl.hasPrefix("http://") {
            loadUrl = loadUrl.insert("s", ind: 4)
            //print(loadUrl)
        } else if loadUrl.isEmpty {
            loadUrl = "http://i.imgur.com/ieuh05n.png"
        }
        if let webUrl = NSURL(string: loadUrl) {
            //println("Attempting to load URL...")
            let requestObj = NSURLRequest(URL: webUrl)
            webView.loadRequest(requestObj)
            currUrl = glyfAnnotation.linkUrl
            //println("Should show...")
        }
        
        glyfCollection.append(glyfAnnotation)
        for glyf in arrAnnotations {
            if glyf !== glyfAnnotation {
                let glyf_CLL = CLLocation(latitude: glyf.coordinate.latitude, longitude: glyf.coordinate.longitude)
                let glyfSel_CLL = CLLocation(latitude: glyfAnnotation.coordinate.latitude, longitude: glyfAnnotation.coordinate.longitude)
                if glyf_CLL.distanceFromLocation(glyfSel_CLL) < COLL_DIST {
                    //print("Added to coll: \(glyf.title)")
                    glyfCollection.append(glyf)
                }
            }
        }

        collView.setContentOffset(CGPointMake(0, collView.contentOffset.y), animated: false)
        collView.reloadData()

        slideContentView()
        
        /*
        if loadUrl.isEmpty {
            let image = UIImage(named: "gray-icon-chat@2x.png")
            chatPlaceHolder = UIImageView(image: image)
            chatPlaceHolder?.center = webView.center
            if chatPlaceHolder != nil {
                view.addSubview(chatPlaceHolder!)
            }
        } else {
            chatPlaceHolder?.removeFromSuperview()
        }*/
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        
        if collectionselect == true {
            return
        }
        
        setHomeView()
    }
    
    func updatePostAddress(selected: SelectedPlace?) {
        
        selectedGooglePlace = selected

        if selected != nil {
            mapOverlay.setUserInteraction(true)
            
            let span = MKCoordinateSpanMake(0.02, 0.02)
            if let selection_coord = self.selectedGooglePlace?.coordinates {
                //print("Centering map to selection.coord...")
                let region = MKCoordinateRegion(center: selection_coord, span: span)
                self.mapView.setRegion(region, animated: false)
                
                //FOR STACKOVERFLOW: SEG FAULT 11
                //println("Update labels to \(selected?.fullAddress) and \(sel: selected?.placename)")
                print("Update labels to \(selected?.fullAddress) and \(selected?.placename)")
                updateMapCenterAddr(selected?.fullAddress, streetAddr: selected?.placename)
            }
            
        }
        postNewVC?.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.setPostView()
            self.app.setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCenterLocTapped(sender: AnyObject) {
        userLocCentered = false
        loadViewablePins(userLoc2D)
        setHomeView()
    }
    
    @IBAction func btnShuffleTapped(sender: AnyObject) {
        Mixpanel.sharedInstance().track("ShuffleButtonTapped")
        
        self.nextSelection = nil
        if maxIndex == nil {
            
            let query = PFQuery(className: "locObject")
            query.orderByDescending("index")
            query.getFirstObjectInBackgroundWithBlock { (maxObj, error) -> Void in
                if error != nil {
                    print(error)
                
                    let PRINCETON = CLLocationCoordinate2D(
                        latitude: 40.3503271,
                        longitude: -74.6526857
                    )
                    let UWS_NY = CLLocationCoordinate2D(
                        latitude: 40.7760052,
                        longitude: -73.9821222
                    )
                    let MISSION = CLLocationCoordinate2D(
                        latitude: 37.7668861,
                        longitude: -122.4186494
                    )
                    let LES_NY = CLLocationCoordinate2D(
                        latitude: 40.7160085,
                        longitude: -73.9830292
                    )
                    let RICHMOND = CLLocationCoordinate2D(
                        latitude: 37.7801608,
                        longitude: -122.4791776
                    )
                    let SHUFFLELOCATIONS = [PRINCETON, UWS_NY, MISSION, LES_NY, RICHMOND]
                    let RANDOM = Int(arc4random_uniform(UInt32(SHUFFLELOCATIONS.count)))
                    
                    let span = MKCoordinateSpanMake(0.02, 0.02)
                    let region = MKCoordinateRegion(center: SHUFFLELOCATIONS[RANDOM], span: span)
                    self.loadViewablePins(SHUFFLELOCATIONS[RANDOM])
                    self.mapView.setRegion(region, animated: true)
                    
                    self.setHomeView()
                
                } else {
                    if let maxObj = maxObj {
                        self.maxIndex = maxObj["index"] as? Int
                    
                        if self.maxIndex != nil {
                            let randomIndex = arc4random_uniform(UInt32(self.maxIndex!))
                        
                            let query2 = PFQuery(className: "locObject")
                            query2.whereKey("index", equalTo: Int(randomIndex))
                            query2.getFirstObjectInBackgroundWithBlock({ (randObj, error) -> Void in
                                if error != nil {
                                    print(error)
                                } else {
                                    if let objResult = randObj {
                                        if let randomGeo = objResult["locGeoPt"] as? PFGeoPoint {
                                            let randomCLL2D = CLLocationCoordinate2D(latitude: randomGeo.latitude, longitude: randomGeo.longitude)
                                        
                                            let span = MKCoordinateSpanMake(0.02, 0.02)
                                            let region = MKCoordinateRegion(center: randomCLL2D, span: span)
                                            self.loadViewablePins(randomCLL2D    )
                                            self.mapView.setRegion(region, animated: true)
                                            self.setHomeView()
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
        }
            
        } else {
            //let maxIdx = self.maxIndex!
            let randomIndex = arc4random_uniform(UInt32(self.maxIndex!))
                    
            let query2 = PFQuery(className: "locObject")
            query2.whereKey("index", equalTo: Int(randomIndex))
            query2.getFirstObjectInBackgroundWithBlock({ (randObj, error) -> Void in
                if error != nil {
                    print(error)
                } else {
                    if let objResult = randObj {
                        if let randomGeo = objResult["locGeoPt"] as? PFGeoPoint {
                            let randomCLL2D = CLLocationCoordinate2D(latitude: randomGeo.latitude, longitude: randomGeo.longitude)
                                    
                            let span = MKCoordinateSpanMake(0.02, 0.02)
                            let region = MKCoordinateRegion(center: randomCLL2D, span: span)
                            self.loadViewablePins(randomCLL2D    )
                            self.mapView.setRegion(region, animated: true)
                            self.setHomeView()
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func btnPostPinTapped(sender: AnyObject) {
        Mixpanel.sharedInstance().track("AddGlyfTapped")
        setPostView()
    }
    
    @IBAction func btnPostLocobjTapped(sender: AnyObject) {
        Mixpanel.sharedInstance().track("PostGlyfTapped")
        
        if (txtPostTitle.text == nil || txtPostTitle.text == "") && (txtRawPostString.text == nil || txtRawPostString.text == "") {
            return
        }
        
        let title = txtPostTitle.text
        var rawString = ""
        if txtRawPostString.text != nil {
            rawString = txtRawPostString.text!
        }
        //var firstParse = rawString.componentsSeparatedByString(".")
        //var videoId = ""
        var linkvalid = false
        
        /*** For parsing YOUTUBE links ****
        if firstParse[0] == "https://www" {
            var secondParse = rawString.componentsSeparatedByString("?v=")
            
            if secondParse.count > 1 {
                videoId = secondParse[1]
                linkvalid = true
            }
            else {
                println("link not valid.")
            }
        }
        else if firstParse[0] == "http://www" {
            var secondParse = rawString.componentsSeparatedByString("?v=")
            
            if secondParse.count > 1 {
                videoId = secondParse[1]
                linkvalid = true
            }
            else {
                println("link not valid.")
            }
        }
        else if firstParse[0] == "https://youtu" {
            var secondParse = rawString.componentsSeparatedByString("be/")
            
            if secondParse.count > 1 {
                videoId = secondParse[1]
                linkvalid = true
            }
            else {
                println("link not valid.")
            }
        }
        else if firstParse[0] == "http://youtu" {
            var secondParse = rawString.componentsSeparatedByString("be/")
            
            if secondParse.count > 1 {
                videoId = secondParse[1]
                linkvalid = true
            }
            else {
                println("link not valid.")
            }
        }
        else {
            println("link not valid.")
        }
        
        println("Link: " + rawString)
        println("Video ID Output: " + videoId)
        println("TestPost")
    */

        if !(rawString.hasPrefix("http://")) {
            if !(rawString.hasPrefix("https://")) {
                if rawString.isEmpty {
                    linkvalid = true
                }
                else {
                    rawString = "http://\(rawString)"
                    linkvalid = true
                }
            }
            else {
                linkvalid = true
            }
        }
        else {
            linkvalid = true
        }
        
        if linkvalid {
            let parsePost = PFObject(className: "locObject")
            var postLoc = mapView.centerCoordinate
            
            if selectedGooglePlace != nil {
                parsePost["googPlaceID"] = selectedGooglePlace!.googlePlaceID
                parsePost["placeName"] = selectedGooglePlace!.placename
                if selectedGooglePlace?.coordinates != nil {
                    postLoc = selectedGooglePlace!.coordinates!
                }
                if selectedGooglePlace?.types != nil {
                    let googTypes = selectedGooglePlace?.types as! [String]
                    parsePost["googTypes"] = googTypes
                    
                    for type in googTypes {
                        if let typeFromDict = dictGoogleTypes[type] {
                            parsePost["placeType"] = typeFromDict
                        }
                    }
                    if parsePost["placeType"] == nil {
                        parsePost["placeType"] = "_Misc"
                    }
                }
            }
            else {
                parsePost["placeName"] = btnAddrPicker.titleLabel?.text
                postLoc = mapView.centerCoordinate
            }
            
            parsePost["rawPostString"] = rawString
            parsePost["postTitle"] = title
            parsePost["locGeoPt"] = PFGeoPoint(latitude: postLoc.latitude, longitude: postLoc.longitude)
            if rawString.isEmpty {
                parsePost["mediaType"] = "_Blank"
                parsePost["placeType"] = "_Chat"
            }
            else {
                parsePost["mediaType"] = "StandardURL"
            }
            //parsePost["source"] = "YouTube"
            //parsePost["sourceId"] = videoId
            parsePost["userObjID"] = PFUser.currentUser()?.objectId
            parsePost["userString"] = PFUser.currentUser()?.username
            parsePost["profilePicName"] = profilePicName
            parsePost["comment"] = "_BETA_0p6"
            if let maxIndx = self.maxIndex {
                parsePost["index"] = maxIndx + 1
                self.maxIndex!++
            }
            parsePost.saveInBackgroundWithBlock( {
                (success, error) in
                if success {
                    self.loadViewablePins(postLoc)
                }
                else {
                    print(error)
                }
            })
            self.view.endEditing(true)
            //loadViewablePins(postLoc)
        }
        
        txtPostTitle.text = ""
        txtRawPostString.text = ""
        
        self.view.frame.size.height = UIScreen.mainScreen().bounds.height
        setHomeView()
    }
    
    @IBAction func mapTapped(sender: AnyObject) {
        setHomeView()
    }
    
    @IBAction func addressPickerTapped(sender: AnyObject) {
        
        //txtPostTitle.resignFirstResponder()
        //txtRawPostString.resignFirstResponder()
        deactivateAnimations = true
        
        performSegueWithIdentifier("segueToAddrPicker", sender: self)
    }
    
    @IBAction func webTouched(sender: AnyObject) {
        
        // Actually recognizes a touch, not tap.
        if currentState != "contentview-max" {
            setContentMaximize()
        }
    }
    
    @IBAction func collSwiped(sender: AnyObject) {
        print(currentState, terminator: "")
        if currentState == "contentview-visible" {
            setHomeView()
        } else if currentState == "contentview-max" {
            slideContentView()
        }
    }
    
    @IBAction func collSwipedUp(sender: AnyObject) {
        if currentState == "contentview-visible" {
            setContentMaximize()
        }
    }
    
    
    func updateMapCenterAddr (address: String?, streetAddr: String?) {
        if let addr = address {
            self.mapCenterAddr = addr
        } else {
            self.mapCenterAddr = nil
        }
        
        if let stAddr = streetAddr {
            self.streetAddr = stAddr
        } else {
            self.mapCenterAddr = nil
        }
        btnAddrPicker.setTitle(streetAddr, forState: UIControlState.Normal)
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        //btnPostNew.alpha = 0.2
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if ["contentview-visible", "contentview-max"].contains(currentState) {
            return
        }
        
        //btnPostNew.alpha = 0.7
        if abs(mapView.centerCoordinate.latitude - lastPinLoadLoc.latitude) >= REFRESH_DISTANCE || abs(mapView.centerCoordinate.longitude - lastPinLoadLoc.longitude) >= REFRESH_DISTANCE {
            loadViewablePins(mapView.centerCoordinate)
        }
        
        if selectedGooglePlace != nil {
            //updatePostAddress(selectedGooglePlace)
            
            return
        }
        
        let mapCenter = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        mapOverlay.setUserInteraction(false)
        
        CLGeocoder().reverseGeocodeLocation(mapCenter, completionHandler: { (placemarks, error) -> Void in
            if (error != nil) {
                //print(error)
            }
            else {
                if let p = placemarks?[0] {
                    var addrQuery = ""
                    var streetAddr = ""
                    
                    //println("---------Placemark[0]--------")
                    //println(p)
                    self.labelHomeLoc.text = p.subLocality
                    if p.subThoroughfare != nil {
                        addrQuery = p.subThoroughfare!
                    }
                    if p.thoroughfare != nil {
                        addrQuery = addrQuery + " " + p.thoroughfare!
                    }
                    streetAddr = addrQuery
                    //println(p.thoroughfare)
                    if p.locality != nil {
                        addrQuery = addrQuery + " " + p.locality!
                    }
                    //println(p.locality)
                    
                    if p.administrativeArea != nil {
                        addrQuery = addrQuery + " " + p.administrativeArea!
                    }
                    //println(p.subAdministrativeArea)
                    
                    if p.postalCode != nil {
                        addrQuery = addrQuery + " " + p.postalCode!
                    }
                    
                    //println(p.postalCode)
                    //println(p.country)
                    
                    self.updateMapCenterAddr(addrQuery, streetAddr: streetAddr)
                    self.updatePostAddress(nil)
                    //println(self.mapCenterAddr)
                    
                    /******  MK Local Search via Apple *******
                    ******************************************
                    
                    var request = MKLocalSearchRequest()
                    
                    if (p.thoroughfare != nil) {
                        //request.naturalLanguageQuery = p.pl
                        request.region = mapView.region
                    
                        var search = MKLocalSearch(request: request)
                        search.startWithCompletionHandler( { (response, error) -> Void in
                            if (error != nil) {
                                println(error)
                            }
                            else {
                                //var responseItems = response.mapItems
                                println("------------SearchResponse---------------")
                                println(response.mapItems)
                            }
                        })
                    }*/
                    
                    /*
                    let topLat = mapView.centerCoordinate.latitude + 0.05
                    let btmLat = mapView.centerCoordinate.latitude - 0.05
                    let ltLong = mapView.centerCoordinate.longitude - 0.05
                    let rtLong = mapView.centerCoordinate.longitude + 0.05
                    */
                    
                    //let northwest = CLLocationCoordinate2D(latitude: topLat, longitude: ltLong)
                    //let southeast = CLLocationCoordinate2D(latitude: btmLat, longitude: rtLong)
                    //var googleBounds = GMSCoordinateBounds(coordinate: northwest, coordinate: southeast)
                    /*self.placesClient?.autocompleteQuery("bar", bounds: googleBounds, filter: nil, callback: {
                        (results, error: NSError?) -> Void in
                        if let error = error {
                            println("Autocomplete error \(error)")
                        }
                        else {
                            println(results)
                        }
                    })*/
                }
            }
            
        })
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is GlyfPointAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView?.canShowCallout = true
            //anView.image.size = CGSize(width: 64, height: 78)
        }
        else {
            anView?.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        //anView.frame.size = CGSizeMake(64, 78)
        let cpa = annotation as! GlyfPointAnnotation
        anView?.image = UIImage(named:cpa.imageName)
        /*
        var rect = CGRect()
        rect.size.height = (anView?.image?.size.height)! // 1.5
        rect.size.width = (anView?.image?.size.width)! // 1.5
        rect.origin = CGPoint(x: 0, y: 0)
        
        if rect.size.height == 0 {
            return nil
        } else if rect.size.width == 0 {
            return nil
        }*/

        //UIGraphicsBeginImageContext(rect.size)
                
        //UIGraphicsBeginImageContextWithOptions(rect.size, false, 1)
        //anView?.image?.drawInRect(rect)
        /*if cpa.viewedByUser == true {
            println("Attempt to set alpha on \(anView.annotation.title)")
            let ctx = UIGraphicsGetCurrentContext()
            CGContextSetAlpha(ctx, 0.5)
        } else {
            println("Alpha not set on \(anView.annotation.title)")
        }*/
        //let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        //UIGraphicsEndImageContext()
        
        
        /*if cpa.viewedByUser == true {
            var imageCG = resizedImage.CGImage
            let width = CGImageGetWidth(imageCG)
            let height = CGImageGetHeight(imageCG)
            
            let bytesPerPixel = 4
            let bytesPerRow = bytesPerPixel * width
            let bitsPerComponent = 8
            
            let pixels = UnsafeMutablePointer<UInt32>.alloc(width * height)
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bmpInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
            
            let ctx = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpace, bmpInfo)
            CGContextSetAlpha(ctx, 0.2)
            resizedImage = UIImage(CGImage: imageCG)
        }*/

        //anView?.image = resizedImage
        /*if cpa.viewedByUser == true {
            anView.alpha = 0.3
        }*/
        //anView.transform = CGAffineTransformMakeScale(2, 2)
        
        return anView
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if currentState != "postview-visible" {
            self.view.endEditing(true)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func handleRotation(notification: NSNotification) {
        switch UIDevice.currentDevice().orientation {
            case .Portrait, .PortraitUpsideDown :
                orientation = "portrait"
                //slideMapLabel()
                //btnShuffle.hidden = false
                //btnCenterUser.hidden = false
                //println("Portrait")
            case .LandscapeLeft :
                orientation = "landscape"
                //slideMapLabel()
                //btnShuffle.hidden = true
                //btnCenterUser.hidden = true
                //println("LandscapeLeft")
            case .LandscapeRight :
                orientation = "landscape"
                //slideMapLabel()
                //btnShuffle.hidden = true
                //btnCenterUser.hidden = true
                //println("LandscapeRight")
            default :
                break
                //print("Other orientation.")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        
        if segue!.identifier == "segueToAddrPicker" {
            Mixpanel.sharedInstance().track("EnterAddrPicker")
            postNewVC = segue!.destinationViewController as? PostNewViewController
            postNewVC!.delegate = self
            postNewVC!.addrString = self.mapCenterAddr
        } else if segue!.identifier == "segueToProfile" {
            profileVC = segue!.destinationViewController as? ProfileViewController
            profileVC?.delegate = self
            profileVC?.screenimage = self.profilePicName
        } else if segue!.identifier == "segueToActivityView" {
            Mixpanel.sharedInstance().track("CheckActivityView")
            activityViewController = segue!.destinationViewController as? DashboardTableViewController
            activityViewController!.delegate = self
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame:CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        //var viewFrame:CGRect = self.view.frame
        
        UIView.animateWithDuration(0.2, animations: {
            () -> Void in
            //self.view.frame = viewFrame
            self.view.frame.size.height = UIScreen.mainScreen().bounds.height - keyboardFrame.size.height
            //self.view.frame.origin.y = -keyboardFrame.size.height
            //self.consVertMapPlayer.constant += keyboardFrame.size.height
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //var info = notification.userInfo!
        //var keyboardFrame:CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        //print("keyboard hiding")
        
        if deactivateAnimations {
            //print("deactivated animations")
            return
        }
        
        UIView.animateWithDuration(0.2, animations: {
            () -> Void in
            //self.view.frame.size.height += keyboardFrame.size.height
            self.view.frame.size.height = UIScreen.mainScreen().bounds.height
            //self.view.frame.origin.y = 0
            //self.consVertMapPlayer.constant = 0
        })
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GlyfContentViewCellDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return glyfCollection.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GLYF_CTNT_CL_REUSEID, forIndexPath: indexPath) as! GlyfContentViewCell
        var thumbImage = ""
        cell.delegate = self
        cell.locationManager = locationManager
        
        //cell.backgroundColor = UIColor.lightGrayColor()
        cell.lblTitle.text = glyfCollection[indexPath.row].postText
        if glyfCollection[indexPath.row].screenname != "" {
            cell.lblScreenname.text = glyfCollection[indexPath.row].screenname
        } else {
            cell.lblScreenname.text = "a magical unicorn"
        }
        if glyfCollection[indexPath.row].screenimage != "" {
            thumbImage = "thumb-" + glyfCollection[indexPath.row].screenimage
        } else {
            thumbImage = "thumb-circle.png"
        }
        cell.profileThumb.image = UIImage(named: thumbImage)
        cell.tag = indexPath.row
        cell.btnHeart.setTitle("\(glyfCollection[indexPath.row].heartCount)", forState: UIControlState.Normal)
        if glyfCollection[indexPath.row].heartedByUser == true {
            cell.btnHeart.selected = true
        } else {
            cell.btnHeart.selected = false
        }
        cell.annotation = glyfCollection[indexPath.row]
        
        //cell.imageView.image = flickrPhoto.thumbnail
        
        return cell
    }
    
    func reloadSingleAnnotation(annotation: GlyfPointAnnotation!) {
        
        let anView = self.mapView.viewForAnnotation(annotation)
        
        if anView?.image?.size != nil {
            anView?.image = renderPinImage(annotation, height: (anView?.image?.size.height)!, width: (anView?.image?.size.width)!)
        }
    }
    
    func renderPinImage(annotation: GlyfPointAnnotation, height: CGFloat, width: CGFloat) -> UIImage? {
        var pinimageName = annotation.imageName
        
        if let grayRange = pinimageName.rangeOfString("gray-") {
            pinimageName.removeRange(grayRange)
        }
        if let starRange = pinimageName.rangeOfString("starred-") {
            pinimageName.removeRange(starRange)
        }

        if pinimageName == "" {
            pinimageName = "icon-misc.png"
        }
        
        if (annotation.viewedByUser == true) && (annotation.heartedByUser == false) {
            pinimageName = "gray-" + pinimageName
        } else if annotation.heartedByUser == true {
            if annotation.viewedByUser == true {
                //scale = 1.2
            }
            pinimageName = "starred-" + pinimageName
        }
        
        
        let pinimage = UIImage(named: pinimageName)
        /*
        var rect = CGRect()
        if let refreshsize = pinimage?.size {
            rect.size.height = refreshsize.height // 1.5
            rect.size.width = refreshsize.width // 1.5
        } else {
            rect.size.height = height
            rect.size.width = width
        }
        rect.origin = CGPoint(x: 0, y: 0)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1)

        
        
        
        if pinimage != nil {
            pinimage!.drawInRect(rect)
            pinimage = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        */
        return pinimage
        
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let STICKINESS:CGFloat = 0.1
        
        let scrollCenter:CGFloat = collView.contentOffset.x + (collView.frame.width / 2)
        var nearbyCellXs = [CGFloat](count: glyfCollection.count, repeatedValue: 0)
        var indexPath = NSIndexPath()
        centerIndex = 0
        var minScrollCtr:CGFloat = 100000
        let scrollSense:CGFloat = 30
        
        for i in 0..<glyfCollection.count {
            indexPath = NSIndexPath(forRow: i, inSection: 0)
            if let currCell = collView.cellForItemAtIndexPath(indexPath) {
                nearbyCellXs[i] = currCell.frame.origin.x + (currCell.frame.width / 2)
            }
            else {
                nearbyCellXs[i] = 0
            }
        }
        
        for i in 0..<nearbyCellXs.count {
            if abs(nearbyCellXs[i] - scrollCenter) < minScrollCtr {
                centerIndex = i
                minScrollCtr = abs(nearbyCellXs[i] - scrollCenter)
            }
        }
        
        //println("Velocity: ")
        //println(velocity)
        
        if nearbyCellXs[centerIndex] - scrollCenter < -scrollSense {
            if (centerIndex + 1 < glyfCollection.count) && (velocity.x >= -STICKINESS) {
                centerIndex++
            }
        } else if nearbyCellXs[centerIndex] - scrollCenter > scrollSense {
            if (centerIndex - 1 >= 0) && (velocity.x <= STICKINESS) {
                centerIndex--
            }
        } else {
            if velocity.x > STICKINESS {
                if centerIndex + 1 < glyfCollection.count {
                    centerIndex++
                }
            }
            else if velocity.x < -STICKINESS {
                if centerIndex - 1 >= 0 {
                    centerIndex--
                }
            }
        }
        
        newCenterCG = nearbyCellXs[centerIndex] - (scrollView.frame.width / 2)
        
        /*
        if glyfCollection[centerIndex].linkUrl != currUrl {
            webView.stopLoading()
            println("Attempting to slide to: \(glyfCollection[centerIndex].linkUrl)")
            if let webUrl = NSURL(string: glyfCollection[centerIndex].linkUrl) {
                println("Attempting to load URL...")
                let requestObj = NSURLRequest(URL: webUrl)
                webView.loadRequest(requestObj)
                currUrl = glyfCollection[centerIndex].linkUrl
                println("Should show...")
            }
        }*/
        
        /*
        scrollView.setContentOffset(CGPointMake(nearbyCellXs[centerIndex] - (scrollView.frame.width / 2), scrollView.contentOffset.y), animated: true)*/
        
        /*
        collectionselect = true
        mapView.selectAnnotation(glyfCollection[centerIndex], animated: true)
        collectionselect = false*/
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        /*var scrollCenter:CGFloat = collView.contentOffset.x + (collView.frame.width / 2)
        var nearbyCellXs = [CGFloat](count: glyfCollection.count, repeatedValue: 0)
        var indexPath = NSIndexPath()
        var centerIndex = 0
        var minScrollCtr:CGFloat = 100000
        
        for i in 0..<glyfCollection.count {
            indexPath = NSIndexPath(forRow: i, inSection: 0)
            if let currCell = collView.cellForItemAtIndexPath(indexPath) {
                nearbyCellXs[i] = currCell.frame.origin.x + (currCell.frame.width / 2)
            }
            else {
                nearbyCellXs[i] = 0
            }
        }
        
        for i in 0..<nearbyCellXs.count {
            if abs(nearbyCellXs[i] - scrollCenter) < minScrollCtr {
                centerIndex = i
                minScrollCtr = abs(nearbyCellXs[i] - scrollCenter)
            }
        }
        
        scrollView.setContentOffset(CGPointMake(nearbyCellXs[centerIndex] - (scrollView.frame.width / 2), scrollView.contentOffset.y), animated: true)
        */
        
        if glyfCollection[centerIndex].linkUrl != currUrl {
            webView.stopLoading()
            
            var newUrl = glyfCollection[centerIndex].linkUrl
            if newUrl.hasPrefix("http://") {
                newUrl = newUrl.insert("s", ind: 4)
                print(newUrl)
            }
            //println("Attempting to slide to: \(glyfCollection[centerIndex].linkUrl)")
            if let webUrl = NSURL(string: newUrl) {
                let requestObj = NSURLRequest(URL: webUrl)
                webView.loadRequest(requestObj)
                currUrl = newUrl
            }
        }

        collectionselect = true
        mapView.selectAnnotation(glyfCollection[centerIndex], animated: true)
        collectionselect = false
        
        scrollView.setContentOffset(CGPointMake(newCenterCG, scrollView.contentOffset.y), animated: true)
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPointMake(newCenterCG, scrollView.contentOffset.y), animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return SECTINSETS
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collView.frame.width - 30, height: 91)
    }
}

extension ViewController: GlyfSelectDelegate {
    func goToSelection(selected: PFObject?) {
        userLocCentered = true
        seguingFromActivity = true
        if let object = selected {
            //print(object)
            nextSelection = object.objectId
            //print(nextSelection)
            if let newGeo = object["locGeoPt"] as? PFGeoPoint {
                let newCoordinate = CLLocationCoordinate2D(latitude: newGeo.latitude, longitude: newGeo.longitude)
                print(newCoordinate)
                let span = MKCoordinateSpanMake(0.02, 0.02)
                let region = MKCoordinateRegion(center: newCoordinate, span: span)
                mapView.setRegion(region, animated: false)
                //loadViewablePins(newCoordinate)
            }
        }
        //print(selected)
        
        activityViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            //self.setHomeView()
            self.app.setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        })
        
        //txtPostTitle.becomeFirstResponder()
    }
    
    func requestAlwaysAuthorization() {
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        }
        locationManager.requestAlwaysAuthorization()
    }
}

extension ViewController: ProfileViewControllerDelegate {
    func dismissProfileView() {
        profileVC?.dismissViewControllerAnimated(true, completion: { () -> Void in
            //self.setHomeView()
            self.app.setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        })
    }
}

extension ViewController: UIWebViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        //println("WEBVIEW ERROR")
        //println(error)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        if webView.canGoBack {
            btnWebBack.enabled = true
        } else {
            btnWebBack.enabled = false
        }
        if webView.canGoForward {
            btnWebForward.enabled = true
        } else {
            btnWebForward.enabled = false
        }
        webLoadIndicator?.stopAnimating()
        webLoadIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        webLoadIndicator!.center = navWebBar.center
        view.addSubview(webLoadIndicator!)
        webLoadIndicator?.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if webView.canGoBack {
            btnWebBack.enabled = true
        } else {
            btnWebBack.enabled = false
        }
        if webView.canGoForward {
            btnWebForward.enabled = true
        } else {
            btnWebForward.enabled = false
        }
        webLoadIndicator?.stopAnimating()
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func forwardButtonPressed(sender: AnyObject) {
        webView.goForward()
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        //print("Attempt share currUrl: \(currUrl)")
        if let url = NSURL(string: currUrl) {
            print("NSURL created.")
            let systemActivityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self.presentViewController(systemActivityViewController, animated: true, completion: { () -> Void in
                Mixpanel.sharedInstance().track("PossibleShare")
            })
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /*
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            if currentState == "contentview-max" {
                slideContentView()
            } else if currentState == "contentview-visible" {
                setHomeView()
            }
        }
    }*/
}

extension String {
    func insert(string:String,ind:Int) -> String {
        return  String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count-ind))
    }
}
