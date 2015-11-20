//
//  Singleton.swift
//  thanksfrog
//
//  Created by Juan Garcia on 6/24/15.
//  Copyright (c) 2015 Tek3. All rights reserved.
//

import SwiftAddressBook
import CoreLocation
import Foundation
import FBSDKLoginKit
import AVFoundation

class Singleton: NSObject {
    
    static let sharedInstance: Singleton = Singleton()
    
    // MARK:- User context variables
    
    static var globalSession: Session?
    static var userLocation: Location?
	
	static var selectedItem: Int = 0
    
    // MARK:- Managers
    
    var locationManager: CLLocationManager = CLLocationManager()
    let facebookManager: FBSDKLoginManager = FBSDKLoginManager()
    
    // MARK:- Home container variables
    
    static var currentHomeContainerType: String?
    static var containerHomeViewController: ContainerHomeViewController?
    
    static let homeSegueID = "embedMap"
    static let cameraSegueID = "embedCamera"
    
    // MARK:- Contacts container variables
    
    static var currentContactContainerType: String?
    static var containerContactsViewController: ContainerContactsViewController?
    
    static let contactsSegueID = "embedContacts"
    static let registrationSegueID = "embedRegistration"
    
    // MARK:- Contacts sync variables
    
    static var contactsSyncNeeded: Bool = true
    
    // MARK:- Device size variables
    
    static let is_iPhone4 = (UIScreen.mainScreen().bounds.size.height == 480 ? true : false)
    static let is_iPhone5 = (UIScreen.mainScreen().bounds.size.height == 568 ? true : false)
    static let is_iPhone6 = (UIScreen.mainScreen().bounds.size.height == 667 ? true : false)
    static let is_iPhone6p = (UIScreen.mainScreen().bounds.size.height == 736 ? true : false)

    static var currentDeviceWidth: CGFloat {
        get { return UIScreen.mainScreen().bounds.size.width }
    }
    
    static var currentDeviceHeight: CGFloat {
        get { return UIScreen.mainScreen().bounds.size.height }
    }
    
    // MARK:- Service variables
    
    static var isCallingService: Bool = false
    
//	static let dateFormatServices: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
	static let dateFormatServices: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
	static let dateFormatServicesForCreateScene: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    
    // MARK:- Navigation variables
    
    static var isComingFromCoverPhotoSelection: Bool = false
    static var isComingFromAlbumPhotoTaken: Bool = false
	static var isComingFromLogin: Bool = false
	static var navigatingWithTabBar: Bool = false
    
    // MARK:- Caching variables
    
    static var imageCache: NSCache = NSCache()
    
    // MARK:- Paging variables
    
    static let iPhone4and5numPages: Int = 5
    static let iPhone6numPages: Int = 6
    static let iPhone6pnumPages: Int = 7
	
	static let iPhone4and5numPagesMyScenesAndShared: Int = 3
	static let iPhone6numPagesMyScenesAndShared: Int = 4
	static let iPhone6pnumPagesMyScenesAndShared: Int = 5
	
    static var lastPageLoadedInList: Int = 0
    static var numberOfPagesLoadedInList: Int = 0
    
    static var lastPageLoadedInAlbum: Int = 0
    static var numberOfPagesLoadedInAlbum: Int = 0
	
	static var lastPageLoadedInMyScenes: Int = 0
	static var numberOfPagesLoadedInMyScenes: Int = 0
	
	static var lastPageLoadedInSharedScenes: Int = 0
	static var numberOfPagesLoadedInSharedScenes: Int = 0
	
    static var showScenesListLoader: Bool = false
    static var showScenesAlbumLoader: Bool = false
    static var showMyScenesLoader: Bool = false
	static var showinboxLoader: Bool = false
    
    // MARK:- Location Methods
    
    func startLocation(delegate: CLLocationManagerDelegate) {
        self.locationManager.delegate = delegate
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    // MARK:- Access Token Persistance Methods
    
    class func saveAccessTokenToPList(session: Session) {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent("thanksfrogLogin.plist")
        let dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
        //saving values
        dict.setObject(session.accessToken, forKey: LoginKey.access_token)
        dict.setObject(session.ttl, forKey: LoginKey.ttl)
        dict.setObject(session.created, forKey: LoginKey.created)
        dict.setObject(session.user.userId, forKey: LoginKey.userId)

        //writing to thanksfrog.plist
        dict.writeToFile(path, atomically: false)
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        print("Saved thanksfrog.plist file is --> \(resultDictionary?.description)")
        
    }
    
    class func getAccessTokenFromPList() -> Session {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent("thanksfrogLogin.plist")
        let fileManager = NSFileManager.defaultManager()
        
        if(!fileManager.fileExistsAtPath(path)) {
            return Session()
        } else {
            let resultDictionary = NSMutableDictionary(contentsOfFile: path)
            print("Bundle thanksfrog.plist file is --> \(resultDictionary?.description)")
            
            let token = resultDictionary?.objectForKey(LoginKey.access_token) as! String
            let created = resultDictionary?.objectForKey(LoginKey.created) as! String
            let ttl = resultDictionary?.objectForKey(LoginKey.ttl) as! Int
            let user = resultDictionary?.objectForKey(LoginKey.userId) as! String
            
            return Session(cookieId: token, ttl: ttl, created: created, user: User(username: user))
        }
    }
    
    class func deleteAccessTokenFromPList() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent("thanksfrogLogin.plist")
        let fileManager = NSFileManager.defaultManager()
        
        if(fileManager.fileExistsAtPath(path)) {
            do {
                try fileManager.removeItemAtPath(path)
            } catch _ {
            }
        }
    }
    
    // MARK:- Contacts Date Update Methods
    
	class func saveStringToPList(value: String, forKey: String) {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent("thanksfrog\(forKey).plist")
        let dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
        //saving values
        dict.setObject(value, forKey: forKey)
        
        //writing to thanksfrog.plist
        dict.writeToFile(path, atomically: false)
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        print("Saved thanksfrog\(forKey).plist file is --> \(resultDictionary?.description)")
    }
    
	class func getStringFromPList(forKey: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent("thanksfrog\(forKey).plist")
        let fileManager = NSFileManager.defaultManager()
        
        if(!fileManager.fileExistsAtPath(path)) {
            return ""
        } else {
            let resultDictionary = NSMutableDictionary(contentsOfFile: path)
            print("Bundle thanksfrog\(forKey).plist file is --> \(resultDictionary?.description)")
            
            if let result = resultDictionary?.objectForKey(forKey) as? String {
                return result
            } else {
                return ""
            }
        }
    }
	
	class func deleteStringFromPList(forKey: String) {
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
		let documentsDirectory = paths.objectAtIndex(0) as! NSString
		let path = documentsDirectory.stringByAppendingPathComponent("thanksfrog\(forKey).plist")
		let fileManager = NSFileManager.defaultManager()
		
		if(fileManager.fileExistsAtPath(path)) {
			do {
				try fileManager.removeItemAtPath(path)
			} catch _ {
			}
		}
	}

	// MARK:- Contacts List store Methods
	
	class func saveContactsListToPList(contactList: Dictionary<String,[ContactPerson]>, forKey: String) {
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
		let documentsDirectory = paths.objectAtIndex(0) as! NSString
		let path = documentsDirectory.stringByAppendingPathComponent("thanksfrog\(forKey).plist")
		
		let contactDict: NSMutableDictionary = NSMutableDictionary()
		for (keyString, value) in contactList {
			contactDict.setObject(value, forKey: keyString)
		}
		
		let dictData: NSData = NSKeyedArchiver.archivedDataWithRootObject(contactDict)
		
		//writing to thanksfrog.plist
		let dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
		
		dict.setObject(dictData, forKey: forKey)
		
		dict.writeToFile(path, atomically: false)
		
//		let resultDictionary = NSMutableDictionary(contentsOfFile: path)
//		print("Saved thanksfrog.plist file is --> \(resultDictionary?.description)")
		
	}
	
	class func getContactsListFromPList(forKey: String) -> Dictionary<String,[ContactPerson]>? {
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
		let documentsDirectory = paths.objectAtIndex(0) as! NSString
		let path = documentsDirectory.stringByAppendingPathComponent("thanksfrog\(forKey).plist")
		let fileManager = NSFileManager.defaultManager()
		
		if(!fileManager.fileExistsAtPath(path)) {
			return nil
		} else {
			let resultDictionary = NSMutableDictionary(contentsOfFile: path)
//			print("Bundle thanksfrog.plist file is --> \(resultDictionary?.description)")
			
			if let result = resultDictionary?.objectForKey(forKey) as? NSData {
				
				let contactsDict: NSDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(result)! as! NSDictionary
				
				return contactsDict as? Dictionary
			} else {
				return nil
			}
		}
	}
	
	class func deleteContactsListFromPList(forKey: String) {
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
		let documentsDirectory = paths.objectAtIndex(0) as! NSString
		let path = documentsDirectory.stringByAppendingPathComponent("thanksfrog\(forKey).plist")
		let fileManager = NSFileManager.defaultManager()
		
		if(fileManager.fileExistsAtPath(path)) {
			do {
				try fileManager.removeItemAtPath(path)
			} catch _ {
			}
		}
	}
	
    // MARK:- Contacts Container Methods
	
    class func changeContactsContainerView() {
        self.containerContactsViewController?.swapViewControllers()
    }
	
    class func changeHomeContainerView() {
        self.containerHomeViewController?.swapViewControllers()
    }
    
    // MARK:- Sound playing
    
    class func playCrocSound(audioname: String, format: String) {
        var audioPlayer = AVAudioPlayer()
        
        let alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(audioname, ofType: format)!)
        print(alertSound)
        
        do {
            // Removed deprecated use of AVAudioSessionDelegate protocol
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
		
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: alertSound)
        } catch {
        }
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
}
