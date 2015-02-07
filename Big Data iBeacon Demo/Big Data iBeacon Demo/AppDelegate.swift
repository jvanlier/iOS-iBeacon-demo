//
//  AppDelegate.swift
//  Big Data iBeacon Demo
//
//  Created by Jori van Lier on 07-02-15.
//  Copyright (c) 2015 dna. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?
    var lastProximity: CLProximity?
    var shouldSendNotificationOnNextNearOrImmediate = true

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?)
            -> Bool {
        //let uuidString = "EBEFD083-70A2-47C8-9837-E7B5634DF524" // iBeaconModules.us
        let uuidString = "74278bda-b644-4520-8f0c-720eaf059935" // Glimworm
        let beaconIdentifier = "identifier" // What's this for exactly?
        let beaconUUID = NSUUID(UUIDString: uuidString)
        //let minor = CLBeaconMinorValue(10)
        let major = CLBeaconMajorValue(1337)
        //let beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, major: major, minor: minor,
        //    identifier: beaconIdentifier)
        let beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, major: major, identifier: beaconIdentifier)

        // Init location manager and tell it to start listening for beacons:
        locationManager = CLLocationManager()
        if(locationManager!.respondsToSelector("requestAlwaysAuthorization")) {
            locationManager!.requestAlwaysAuthorization()
        }
        locationManager!.delegate = self
        locationManager!.pausesLocationUpdatesAutomatically = false
        
        locationManager!.startMonitoringForRegion(beaconRegion)
        locationManager!.startRangingBeaconsInRegion(beaconRegion)
        locationManager!.startUpdatingLocation()
        
        // Request permission to send notifications (new iOS 8 feature):
        if(application.respondsToSelector("registerUserNotificationSettings:")) {
            application.registerUserNotificationSettings(
                UIUserNotificationSettings(
                    forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Sound,
                    categories: nil
                )
            )
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of
        // temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the 
        // application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. 
        // Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application 
        // state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of 
        // applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the 
        // changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the 
        // application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also 
        // applicationDidEnterBackground:.
    }
}


extension AppDelegate: CLLocationManagerDelegate {
    func sendLocalNotificationWithMessage(message: String!) {
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = message
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!,
            inRegion region: CLBeaconRegion!) {
        NSLog("didRangeBeacons");
        var message = ""
        var sendableRange = false

        // Link to view:
        let viewController = window!.rootViewController as ViewController
        viewController.beacons = beacons as? [CLBeacon]
        viewController.tableView?.reloadData()

        if (beacons.count > 0) {
            let nearestBeacon:CLBeacon = beacons[0] as CLBeacon

            // Ensure that we only update if the beacon is nearby:
            if (nearestBeacon.proximity == lastProximity || nearestBeacon.proximity == CLProximity.Unknown) {
                    return;
            }
            switch nearestBeacon.proximity {
            case CLProximity.Far:
                message = "The Big Data lab is kind of far away..."
                shouldSendNotificationOnNextNearOrImmediate = true
            case CLProximity.Near:
                message = "You are nearby the Big Data lab"
                sendableRange = true
            case CLProximity.Immediate:
                message = "Welcome to the Big Data lab!"
                sendableRange = true
                if lastProximity == CLProximity.Near {
                    // Ensure that we also send a message if we just came very close while being only near before.
                    shouldSendNotificationOnNextNearOrImmediate = true
                }
            case CLProximity.Unknown:
                return
            }
            lastProximity = nearestBeacon.proximity;
        } else {
            message = "You aren't near the Big Data lab..."
            shouldSendNotificationOnNextNearOrImmediate = true
        }

        NSLog(message)

        if shouldSendNotificationOnNextNearOrImmediate && sendableRange {
            shouldSendNotificationOnNextNearOrImmediate = false
            sendLocalNotificationWithMessage(message)
        }

        // Update the top label in the view:
        self.updateViewLabel(message)
    }

    // This function is called when first entering the region.
    // It doesn't really add value for the demo.
    // It also hardly seems reliable... sometimes continually toggling
    // between in/out the region when its only 15m away.
    func locationManager(manager: CLLocationManager!,
            didEnterRegion region: CLRegion!) {
        var message = "You entered the Big Data lab region."
        manager.startRangingBeaconsInRegion(region as CLBeaconRegion)
        manager.startUpdatingLocation()

        NSLog(message)
        //sendLocalNotificationWithMessage(message)
    }

    // This function is called when you've left the region.
    func locationManager(manager: CLLocationManager!,
            didExitRegion region: CLRegion!) {
        var message = "You exited the Big Data lab region."
        manager.stopRangingBeaconsInRegion(region as CLBeaconRegion)
        manager.stopUpdatingLocation()

        NSLog(message)
        //sendLocalNotificationWithMessage(message)
    }

    // Update the top label in the view:
    func updateViewLabel(message: String) {
        let viewController = window!.rootViewController as ViewController
        viewController.topLabel.text = message
    }
}

