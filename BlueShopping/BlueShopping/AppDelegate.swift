//
//  AppDelegate.swift
//  BlueShopping
//
//  Created by Anantha Krishnan K G on 05/03/17.
//  Copyright © 2017 Ananth. All rights reserved.
//

import UIKit
import BMSCore
import BMSPush
import NotificationCenter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // Cloudant Credentials
    var cloudantName:String = ""
    var cloudantUserName:String = ""
    var cloudantPassword:String = ""
    var cloudantHostName:String = ""
    
    // OpenWhisk Credentials
    var whiskKey:String = ""
    var whiskPass:String = ""

    // Push Credentials
    var pushAppGUID:String = ""
    var pushAppClientSecret:String = ""
    var pushAppRegion:String = ""

    // Ananlytics Credentials
    var ananlyticsAppName = ""
    var ananlyticsApiKey = ""
    
    let notificationName = Notification.Name("sendFeedBack")
    var userName:String = UserDefaults.standard.value(forKey: "userName") != nil ?  UserDefaults.standard.value(forKey: "userName") as! String : "User"

    var isEnabled:Bool = false    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        if let path = Bundle.main.path(forResource: "bluemixCredentials", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            // use swift dictionary as normal
            
            cloudantName = dict["cloudantName"] as! String;
            cloudantUserName = dict["cloudantUserName"] as! String;
            cloudantPassword = dict["cloudantPassword"] as! String;
            cloudantHostName = dict["cloudantHostName"] as! String;
            whiskKey = dict["openWhiskKey"] as! String;
            whiskPass = dict["openWhiskPassword"] as! String;
            pushAppGUID = dict["pushAppGUID"] as! String;
            pushAppClientSecret = dict["pushAppClientSecret"] as! String;
            pushAppRegion = dict["pushAppRegion"] as! String;
            ananlyticsAppName = dict["ananlyticsAppName"] as! String;
            ananlyticsApiKey = dict["ananlyticsApiKey"] as! String;
        }
        
        
        //Initialize core
        let bmsclient = BMSClient.sharedInstance
        bmsclient.initialize(bluemixRegion: pushAppRegion)
  
        isEnabled = false
        _ = MyChallengeHandler();
        
        
        Analytics.initialize(appName: ananlyticsAppName, apiKey: ananlyticsApiKey, hasUserContext: true, collectLocation: true, deviceEvents: .lifecycle, .network)
        
        Analytics.isEnabled = true
        Logger.isLogStorageEnabled = true
        Logger.isInternalDebugLoggingEnabled = true
        Logger.logLevelFilter = LogLevel.debug
        
        let logger = Logger.logger(name: "My Logger")
        
        logger.info(message: "App Opened")
        
        // The metadata can be any JSON object
        Analytics.log(metadata: ["event": "App Opened"])
        
        Logger.send(completionHandler: { (response: Response?, error: Error?) in
            if let response = response {
                print("Status code: \(response.statusCode)")
                print("Response: \(response.responseText)")
            }
            if let error = error {
                logger.error(message: "Failed to send logs. Error: \(error)")
            }
        })
        Analytics.send(completionHandler: { (response: Response?, error: Error?) in
            if let response = response {
                print("Status code: \(response.statusCode)")
                print("Response: \(response.responseText)")
            }
            if let error = error {
                logger.error(message: "Failed to send analytics. Error: \(error)")
            }
        })
        return true
    }
    
    
    func registerForPush () {
       
        //Initialize core
        let bmsclient = BMSClient.sharedInstance
        bmsclient.initialize(bluemixRegion: pushAppRegion)
        
       BMSPushClient.sharedInstance.initializeWithAppGUID(appGUID: pushAppGUID, clientSecret:pushAppClientSecret)
        
    }
    
    func application (_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        
        let push =  BMSPushClient.sharedInstance
        
        push.registerWithDeviceToken(deviceToken: deviceToken) { (response, statusCode, error) -> Void in
            
            if error.isEmpty {
                
                print( "Response during device registration : \(response)")
                
                print( "status code during device registration : \(statusCode)")
                NotificationCenter.default.post(name: self.notificationName, object: nil)

                
            }
            else{
                print( "Error during device registration \(error) ")
            }
        }
    }
    //Called if unable to register for APNS.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        self.showAlert(title: "Registering for notifications", message: error.localizedDescription )
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
       
        
        let payLoad = ((((userInfo as NSDictionary).value(forKey: "aps") as! NSDictionary).value(forKey: "alert") as! NSDictionary).value(forKey: "body") as! String)
        
        self.showAlert(title: "Recieved Push notifications", message: payLoad)
        
    }
    
    
    func showAlert (title:String , message:String){
        
        // create the alert
        let alert = UIAlertController.init(title: title as String, message: message as String, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.window!.rootViewController!.present(alert, animated: true, completion: nil)
    }


}

