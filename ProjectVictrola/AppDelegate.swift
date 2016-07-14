//
//  AppDelegate.swift
//  ProjectVictrola
//
//  Created by Phil Chacko on 5/24/15.
//  Copyright (c) 2015 Phil Chacko. All rights reserved.
//

import UIKit
import Parse
import Bolts
import GoogleMaps
import FBSDKCoreKit
import FBSDKLoginKit
import ParseFacebookUtilsV4
import NZAlertView
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("[INSERT PARSE CREDENTIAL]",
            clientKey: "[INSERT PARSE CREDENTIAL]")
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        if !GMSServices.provideAPIKey("[INSERT GOOGLE MAPS CREDENTIAL]") {
            print("[INSERT GOOGLE MAPS CREDENTIAL")
        }
        
        let userNotificationTypes = UIUserNotificationType([.Alert, .Badge, .Sound])
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        Mixpanel.sharedInstanceWithToken("[INSERT MIXPANEL CREDENTIAL]")
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        //print(userInfo)
        //PFPush.handlePush(userInfo)
        
        let pushData = userInfo["aps"] as! NSDictionary
        let message = pushData["alert"] as? String
        
        if message != nil {
            //print(message!)
            let alert = NZAlertView(style: NZAlertStyle.Info, title: "Info", message: message!)
            alert.show()
        }
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if UIApplication.sharedApplication().applicationState == .Background {
            if let alertBody = notification.alertBody {
                Mixpanel.sharedInstance().track("LocalNotificationTappedInBackground", properties: [
                    "alertBody" : alertBody
                ])
            } else {
                Mixpanel.sharedInstance().track("LocalNotificationTappedInBackground")
            }
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

