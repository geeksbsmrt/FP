//
//  AppDelegate.swift
//  testApp
//
//  Created by Adam Crawford on 8/16/15.
//  Copyright (c) 2015 Adam Crawford. All rights reserved.
//

import UIKit
import Parse
import Bolts
import FBSDKCoreKit
import Twitter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var reachable = Reachability.reachabilityForInternetConnection()
	
	var connected : Bool?
	
	func connectionStatus() -> Bool {
		let status : Int = reachable.currentReachabilityStatus().rawValue
		return (status != 0) ? true : false
	}

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.

		reachable.startNotifier()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector:"connectionChanged:", name: kReachabilityChangedNotification, object: nil)
		
		Parse.enableLocalDatastore()
		
		Hunt.registerSubclass()
		EndPoint.registerSubclass()
		Guess.registerSubclass()
		
		// Initialize Parse.
		Parse.setApplicationId("sGzGSZDyF5PTCmtrMeJG0lsETD8RV3dkmc1tuMUn",
			clientKey: "qGN3SlB933sYbdMylt5UFPf3ZoAy8C7dTxjWBwI6")
		PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
		
		PFTwitterUtils.initializeWithConsumerKey("ERWs0STcBk9QkektFxpVg", consumerSecret: "EjtkPutDJ1snDhissMVUESZ42mzxmhn5EwtDlkPeWY")
		
		// [Optional] Track statistics around application opens.
		//PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
		
		connected = connectionStatus()
		
		return true
	}
	
	func application(application: UIApplication,
		openURL url: NSURL,
		sourceApplication: String?,
		annotation: AnyObject) -> Bool {
			return FBSDKApplicationDelegate.sharedInstance().application(application,
				openURL: url,
				sourceApplication: sourceApplication,
				annotation: annotation)
	}
	
	func connectionChanged(notification: NSNotification) {
		connected = connectionStatus()
		if connected == true {
			self.syncParse()
		}
		
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
		reachable.stopNotifier()
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
		reachable.startNotifier()
		FBSDKAppEvents.activateApp()
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	func syncParse(){
		if self.connected == true {
			let query : PFQuery = PFQuery(className: "Hunt")
			query.fromPin()
			query.findObjectsInBackgroundWithBlock{
				(objects: [PFObject]?, error: NSError?) -> Void in
				if error == nil {
					PFObject.saveAllInBackground(objects, block: {
						(succeded: Bool, saveError: NSError?) -> Void in
						if succeded == true {
							PFObject.unpinAllInBackground(objects)
						}
					})
				}
				
			}
		}
	}


}

