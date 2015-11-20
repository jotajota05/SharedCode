//
//  AppDelegate.swift
//  thanksfrog
//
//  Created by Juan Garcia on 6/20/15.
//  Copyright (c) 2015 Tek3. All rights reserved.
//

import FBSDKLoginKit
import FBSDKCoreKit
import Foundation
import Alamofire
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	var homePushed: Bool = false
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		// Register for PUSH Notifications
		if launchOptions != nil {
			print("Launch options")
			print(launchOptions)
			
			pushInbox()
			
			return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
		}
		
		if Connection.TESTING_APP {
			Singleton.currentHomeContainerType = Singleton.homeSegueID
			Singleton.navigatingWithTabBar = true
		} else {
			Singleton.currentHomeContainerType = Singleton.cameraSegueID // Default
			Singleton.navigatingWithTabBar = false
		}
		if FBSDKAccessToken.currentAccessToken() != nil {
			print("Facebook Token exists!!")
			let tokenString = FBSDKAccessToken.currentAccessToken().tokenString
			print("Facebook Token = \(tokenString)")
			callFacebookService(tokenString)
		} else {
			let session = Singleton.getAccessTokenFromPList()
			if session.accessToken != "" {
				Singleton.globalSession = session
				self.checkContactsUpdateStatus()
			}
		}
		
		return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
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
	
	func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
		return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
	}
	
	// MARK:- UIApplicationDelegate Methods
	
	func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
		print("Did SUCCEED register for PUSH Notification")
		
		var pushRequest: PushRegisterRequest = PushRegisterRequest()
		
		let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
		var tokenString = ""
		
		for var i = 0; i < deviceToken.length; i++ {
			tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
		}
		
		print("tokenString: \(tokenString)")

		var serviceUrl: String = Connection.SERVICES_ENDPOINT + Connection.PUSH_REGISTRATION + "?"
		serviceUrl += LoginKey.access_token + "=" + (Singleton.globalSession?.accessToken)!
		
		pushRequest.appId = "thx-frog-app"
		pushRequest.userId = Singleton.globalSession?.user.userId
		pushRequest.deviceType = "ios"
		pushRequest.deviceToken = tokenString
		
		Alamofire.request(.POST, serviceUrl, parameters: pushRequest.getDictionary()).responseJSON {JSONResponse in
			print("PUSH Registration Response")
			print(JSONResponse.result.value)
		}
	}
	
	func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
		print("Did FAIL register for PUSH Notifications")
		print(error.debugDescription)
	}

	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
		print("Receiving PUSH Notification")
		print(userInfo)
		print("Final PUSH Notification")
		
		pushInbox()
	}
	
	// MARK: - Global Navigation methods
	
	func resetApp() {
		let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
		let initial: UIViewController = storyboard.instantiateInitialViewController()!
		self.window?.rootViewController = initial
		Singleton.deleteAccessTokenFromPList()
		Singleton.deleteStringFromPList(ContactKey.contactStatusUpdate)
		Singleton.deleteContactsListFromPList(ContactKey.contactsList)
		Singleton.deleteContactsListFromPList(ContactKey.frogsContactsList)
		Singleton.deleteStringFromPList(ContactKey.validated)
		UIApplication.sharedApplication().unregisterForRemoteNotifications()
	}
	
	private func callFacebookService(token: String) {
		let request = [
			LoginKey.access_token : token
		]
		Alamofire.request(.GET, Connection.SERVICES_ENDPOINT + Connection.LOGIN_FB_URI, parameters: request).responseJSON { JSONResponse in
			
			if JSONResponse.response != nil {
				
				print("Facebook Login Response:")
				print(JSONResponse.result.value)
				
				var loginInfo: LoginResponse = LoginResponse()
				loginInfo <-- JSONResponse.result.value
				
				if loginInfo.error == nil {
					Singleton.globalSession = Session(cookieId: loginInfo.id!, ttl: loginInfo.ttl!, created: loginInfo.created!, user: User(username: loginInfo.userId!))
					Singleton.saveAccessTokenToPList(Singleton.globalSession!)
					
					self.checkContactsUpdateStatus()
				} else {
					// HANDLE ERROR
				}
				
			} else {
				// HANDLE ERROR
			}
			
		}
	}
	
	func pushHomeView() {
		
		self.homePushed = true
		
		Singleton.isComingFromLogin = false
		
		self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		
		let initialViewController = storyboard.instantiateViewControllerWithIdentifier("homeView") as! UITabBarController
		initialViewController.selectedIndex = Singleton.selectedItem
		
		self.window?.rootViewController = initialViewController
		self.window?.makeKeyAndVisible()
	}
	
	func pushInbox() {
		Singleton.currentHomeContainerType = Singleton.homeSegueID
		Singleton.navigatingWithTabBar = true
		
		let session = Singleton.getAccessTokenFromPList()
		if session.accessToken != "" {
			Singleton.globalSession = session
			self.checkContactsUpdateStatus()
			
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			
			let initialViewController = storyboard.instantiateViewControllerWithIdentifier("homeView") as! UITabBarController
			initialViewController.selectedIndex = 3
			
			Singleton.selectedItem = 3
			
			self.window?.rootViewController = initialViewController
			self.window?.makeKeyAndVisible()
		}
	}
	
	func checkContactsUpdateStatus() {
		let currentContactsDate: String = Singleton.getStringFromPList(ContactKey.contactStatusUpdate)
		
		if (currentContactsDate != "") {
			
			Singleton.currentContactContainerType = Singleton.contactsSegueID
			
			let accessToken: String = (Singleton.globalSession?.accessToken)!
			let request = [
				LoginKey.access_token : accessToken
			]
			
			let serviceUrl: String = Connection.SERVICES_ENDPOINT + Connection.REGISTER_URI + "/" + Connection.CONTACTS_GET_UPDATE
			
			Alamofire.request(.GET, serviceUrl, parameters: request).responseJSON { JSONResponse in
				
				if JSONResponse.response != nil {
					
					var response: ContactUpdateResponse = ContactUpdateResponse()
					response <-- JSONResponse.result.value
					
					if response.error == nil {
						if response.currentContactsDate != nil {
							if currentContactsDate != response.currentContactsDate {
								Singleton.saveStringToPList(response.currentContactsDate!, forKey: ContactKey.contactStatusUpdate)
								Singleton.contactsSyncNeeded = true
							} else {
								Singleton.contactsSyncNeeded = false
							}
						}
					}
				}
			}
			
			self.pushHomeView()
			
		} else {
			let userIsValidate: String = Singleton.getStringFromPList(ContactKey.validated)
			if userIsValidate == "Y" {
				Singleton.currentContactContainerType = Singleton.contactsSegueID
			} else {
				Singleton.currentContactContainerType = Singleton.registrationSegueID // Default
			}
			
			self.pushHomeView()
		}
	}
	
	func logoutApp() {
		self.resetApp()
		Singleton.sharedInstance.facebookManager.logOut()
	}
	
	
	
}

