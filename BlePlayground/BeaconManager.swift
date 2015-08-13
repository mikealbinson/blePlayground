//
//  BeaconManager.swift
//  BlePlayground
//
//  Created by michael on 7/6/15.
//  Copyright (c) 2015 Ticketfly. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class BeaconManager: NSObject, CLLocationManagerDelegate {
    let labelManager: LabelCheckManager
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"), identifier: "Ticketfly_Edison")
    let scanner: BleScanner
    
    var beaconToken = 1
    var closestBeacon: CLBeacon?
    var backgroundFlag = false
    var myBackgroundTask = UIBackgroundTaskIdentifier()
    
    init (labelManagerIn: LabelCheckManager, scannerIn: BleScanner){
        labelManager = labelManagerIn
        scanner = scannerIn
        super.init()
        locationManager.delegate = self
        region.notifyEntryStateOnDisplay = true
        region.notifyOnEntry = true
        //region.notifyOnExit = true
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        checkemOut()
    }
    
    func checkemOut(){
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways {
            if (locationManager.respondsToSelector("requestAlwaysAuthorization")) {
                locationManager.requestAlwaysAuthorization()
            }
            else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways {
                println("already authorized")
            }
            else {
                println("something is wrong")
            }
        }
        locationManager.startMonitoringForRegion(region) //in future a conditional check would be useful here
        locationManager.startRangingBeaconsInRegion(region)
        locationManager.startUpdatingLocation()
        
    }
    
    func sendLocalNotificationWithMessage(message: String) {
        if UIApplication.sharedApplication().applicationState != .Active {
            let notification = UILocalNotification()
            notification.alertBody = message
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedAlways:
            println ("Always authorized for ranging")
        case .AuthorizedWhenInUse:
            println("Authorized when app is on")
        case .Denied:
            println("access denied")
        case .Restricted:
            println ("access restricted")
        case .NotDetermined:
            println("access not determined")
        default:
            println ("unknown state")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        var message = ""
        if beacons.count > 0 && UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
            println (beacons)
            labelManager.statusLabel?.text = "iBeacon found!"
            let knownBeacons = beacons.filter({$0.proximity != CLProximity.Unknown})
            if knownBeacons.count > 0 {
                closestBeacon = knownBeacons[0] as? CLBeacon
                labelManager.rssiLabel?.text = "RSSI: \(closestBeacon?.rssi)"
                switch closestBeacon!.proximity {
                case CLProximity.Far:
                    message = ""
                case CLProximity.Near:
                    message = "You are near the beacon"
                case CLProximity.Immediate:
                    message = "Welcome to the show!"
                case CLProximity.Unknown:
                    message = "You are in an unknown proximity of the beacon"
                default:
                    message = "You broke science"
                }
                
                if beaconToken == 0 {
                    beaconToken = 1
                }
                if message != "" {
                    self.sendLocalNotificationWithMessage(message)
                }
                
            }
            else if beacons.count > 0 && UIApplication.sharedApplication().applicationState == UIApplicationState.Background {
                println ("here")
                println (beacons)
                labelManager.statusLabel?.text = "iBeacon found!"
                let knownBeacons = beacons.filter({$0.proximity != CLProximity.Unknown})
                if knownBeacons.count > 0 {
                    closestBeacon = knownBeacons[0] as? CLBeacon
                    labelManager.rssiLabel?.text = "RSSI: \(closestBeacon?.rssi)"
                    switch closestBeacon!.proximity {
                    case CLProximity.Far:
                        message = ""
                    case CLProximity.Near:
                        message = "You are near the beacon"
                    case CLProximity.Immediate:
                        message = "Welcome to the show!"
                    case CLProximity.Unknown:
                        message = "You are in an unknown proximity of the beacon"
                    default:
                        message = "You broke science"
                    }
                    
                    if beaconToken == 0 {
                        beaconToken = 1
                    }
                    if message != "" {
                        self.sendLocalNotificationWithMessage(message)
                    }
                    rssiChecker()
                    
                }
            }
            else {
                if beaconToken == 1{
                    println("no beacons")
                    stopBeaconScan()
                    beaconToken = 0
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        println("started monitoring")
    }
    
    func locationManager(manager: CLLocationManager!, rangingBeaconsDidFailForRegion region: CLBeaconRegion!, withError error: NSError!) {
        if let locationError = CLError(rawValue: error.code) {
            switch locationError {
            case .Denied:
                println("Location permissions denied")
            case .RangingUnavailable:
                println("ranging unavailable") //with ios 7 this requires a phone restart to fix
            default:
                println("Unhandled error with location: \(error)")
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion: CLRegion!){
        println("region entered")
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Background
        {
            println("do cool stuff here")
            
            myBackgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler ({ () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.myBackgroundTask)
            })
            println("hey!")
            //bleScanner?.connectionTimer?.invalidate()
//            let scanTimer = NSTimer(timeInterval: 1, target: self, selector:"startBeaconScan", userInfo: nil, repeats: true)
//            let rssiCheckTimer = NSTimer(timeInterval: 1, target: self, selector: "rssiChecker", userInfo: nil, repeats: true)
            locationManager.startRangingBeaconsInRegion(region) //not working here...
            println("heyyou")

        }
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("region exited")
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        if state == CLRegionState.Inside && UIApplication.sharedApplication().applicationState == UIApplicationState.Background{
            println("state determined")
        }
    }
    
    func startBeaconScan(){
        println("scan started")
        locationManager.startMonitoringForRegion(region)
        locationManager.startRangingBeaconsInRegion(region)
    }
    
    func stopBeaconScan(){
        locationManager.stopMonitoringForRegion(region)
        locationManager.stopRangingBeaconsInRegion(region)
        println("scan ended")
    }
    
    func rssiChecker(){
        if self.closestBeacon?.rssi >= -60 { //if close enough to the beacon
            self.stopBeaconScan() //stop the ibeacon scan
            bleScanner?.centralManager.scanForPeripheralsWithServices(nil , options: nil)
        }
    }
}