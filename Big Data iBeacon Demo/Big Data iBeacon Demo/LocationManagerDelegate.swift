//
//  LocationManagerDelegate.swift
//  Big Data iBeacon Demo
//
//  Created by Jori van Lier on 07-02-15.
//  Copyright (c) 2015 dna. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class LocationManagerDelegate: CLLocationManagerDelegate {
    var lastProximity: CLProximity?
    var notificationAlreadySent = true
    
    func sendLocalNotificationWithMessage(message: String!) {
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = message
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }


    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!,
        inRegion region: CLBeaconRegion!) {
            var message = ""
            var sendableRange = false
            NSLog("didRangeBeacons");

            self.updateTableView(beacons)

            if (beacons.count > 0) {
                let nearestBeacon:CLBeacon = beacons[0] as CLBeacon

                // Ensure that we only update the message if the proximity since the last known value has changed and
                // isn't unknown:
                if (nearestBeacon.proximity == lastProximity || nearestBeacon.proximity == CLProximity.Unknown) {
                    return;
                }

                switch nearestBeacon.proximity {
                case CLProximity.Far:
                    message = "The Big Data lab is kind of far away..."
                case CLProximity.Near:
                    message = "You are nearby the Big Data lab"
                case CLProximity.Immediate:
                    message = "Welcome to the Big Data lab!"
                    sendableRange = true
                case CLProximity.Unknown:
                    return
                }
                lastProximity = nearestBeacon.proximity;
            } else {
                message = "You aren't near the Big Data lab..."
            }

            NSLog(message)

            if !notificationAlreadySent && sendableRange {
                sendLocalNotificationWithMessage(message)
            }

            // Update the top label in the view:
            self.updateViewLabel(message)
    }

    // This function is called when first entering the region. It doesn't really add value for the demo.
    // It also hardly seems reliable... sometimes repeatedly toggling between in/out the region when its only 15m away.
    // Therefore, notifications are disabled right now.
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

    // Update table in view:
    func updateTableView(beacons: AnyObject) {
        let viewController = window!.rootViewController as ViewController
        viewController.beacons = beacons as? [CLBeacon]
        viewController.tableView?.reloadData()
    }
    
    // Update the top label in the view:
    func updateViewLabel(message: String) {
        let viewController = window!.rootViewController as ViewController
        viewController.topLabel.text = message
}
