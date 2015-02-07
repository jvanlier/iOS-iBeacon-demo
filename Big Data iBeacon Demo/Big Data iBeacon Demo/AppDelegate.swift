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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?)
            -> Bool {
        //let uuidString = "EBEFD083-70A2-47C8-9837-E7B5634DF524" // iBeaconModules.us
        let uuidString = "74278bda-b644-4520-8f0c-720eaf059935" // Glimworm
        let beaconIdentifier = "JORIBEACON"
        let beaconUUID = NSUUID(UUIDString: uuidString)
        let beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, identifier: beaconIdentifier)
        
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

        if (beacons.count > 0) {
            let nearestBeacon:CLBeacon = beacons[0] as CLBeacon

            // Ensure that we only send a message if the beacon is nearby:
            if (nearestBeacon.proximity == lastProximity || nearestBeacon.proximity == CLProximity.Unknown) {
                    return;
            }
            lastProximity = nearestBeacon.proximity;
            switch nearestBeacon.proximity {
            case CLProximity.Far:
                message = "The Big Data lab is kind of far away..."
            case CLProximity.Near:
                message = "You are nearby the Big Data lab"
            case CLProximity.Immediate:
                message = "You are in the immediate proximity of the Big Data lab"
            case CLProximity.Unknown:
                return
            }
        } else {
            message = "You aren't near the Big Data lab..."
        }
        
        NSLog("%@", message)
        sendLocalNotificationWithMessage(message)
    }
}