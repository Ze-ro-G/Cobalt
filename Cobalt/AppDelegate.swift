//
//  AppDelegate.swift
//  Cobalt
//
//  Created by ingouackaz on 01/03/2018.
//  Copyright © 2018 ingouackaz. All rights reserved.
//

import UIKit
import Parse
import Bolts
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Parse.enableLocalDatastore()

        // Initialize Parse.
        let configuration = ParseClientConfiguration {
            $0.applicationId = "a4qiQMUooIJC8JBP457yl5OT4JfEZzrMpSSCRQwY"
            $0.clientKey = "cfVchu5nJdLu83SZSToAkV9TunJM2OhmlpXt4Yi3"
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: configuration)
        PFBook.registerSubclass()
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions);

        checkStoryboardMode()
        
        return true
    }

    
    
    func checkStoryboardMode(){
        
        if (PFUser.current() == nil) {
            enterLoginMode()
        }
        else {
            exitLoginMode()
        }
    }
    
    
    func enterLoginMode(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNC = storyboard.instantiateViewController(withIdentifier: "loginNC") as! UINavigationController
        
        
        appD.window!.rootViewController = loginNC
    }
    
    func exitLoginMode(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let appD = UIApplication.shared.delegate as! AppDelegate
        
        appD.window!.rootViewController = storyboard.instantiateInitialViewController()
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

