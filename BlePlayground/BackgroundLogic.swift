//
//  BackgroundLogic.swift
//  BlePlayground
//
//  Created by michael on 7/17/15.
//  Copyright (c) 2015 Ticketfly. All rights reserved.
//


///THIS WILL NOT BUILD DON'T EVEN TRY--So many errors will happen it may make the whole sceen red

/*
* Here you go, the real problem here really is just getting the didRangeBeacons method to fire, and then getting the CBCentralManagerDelegate to pick
* up the beacon's BLE connection in the background. (I've gotten some ranging before from just leaving the foreground ranging running, but obviously
* that isn't ideal)
* I've pared it down to what happens in the background only, there's other UI stuff I wrote for myself but I cut most of it for readability. The other
* methods I call are also included below
*/

/*

//MARK: The logic begins at CLLocationDelegate's didEnterRegion callback (BeaconManager Class)

func locationManager(manager: CLLocationManager!, didEnterRegion: CLRegion!){
    if UIApplication.sharedApplication().applicationState == UIApplicationState.Background { //if we enter a region in the background
        myBackgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler ({ () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.myBackgroundTask) //Begin our background task
        })
        timoutTimer = NSTimer(timeInterval: 1, target: self, selector: "timeoutChecker", userInfo: nil, repeats: true) //Timer to check for imminent timout
        
        
        locationManager.startRangingBeaconsInRegion(region)//begin ranging beacons--this doesn't work here though--the biggest problem right now
        //this will then bounce to didRangeBeacons once it ranges the beacon--see below
    }
}

func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
    var message = ""
    if beacons.count > 0 { //if a beacon is ranged and exists in the beacons array
        println (beacons) // give us its information
        let knownBeacons = beacons.filter({$0.proximity != CLProximity.Unknown})
        if knownBeacons.count > 0 && UIApplication.sharedApplication().applicationState == UIApplicationState.Background{
            closestBeacon = knownBeacons[0] as? CLBeacon
            rssiChecker() //checks the rssi--see function
        }
    }
    else {
        //keep ranging
    }
}

//MARK: HERE we switch to the CBCentralManagerDelegate (the BleScanner class)
//readRssi SHOULD cause the centralManagerDelegate's didDiscoverPeripheral method to fire if it finds the beacons BLE UUID
func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
    if central.state == .PoweredOn && UIApplication.sharedApplication().applicationState == UIApplicationState.background{
        let deviceName = "Ticketfly_Edison"
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString //takes all devices found and makes a dictionary
        var index: Int
        let peripheralToUse: CBPeripheral?
        
        if nameOfDeviceFound == deviceName { //if a beacon matched our search paramaters--currently we're just looking for a name match--can be changed
            arrayReference.appendPeripheral(peripheral) //add peripheral to a array for later use
            central.stopScan() //stop the BLE scan
            central.connectPeripheral(peripheral, options: nil) //connect to the peripheral object
            arrayReference.connectFlag = true //important to ensure things are not done unless we are connected to the peripheral in the first place
            self.blePeripheralFinder = BlePeripheralFinder(peripheral: peripheral, arrayReferenceIn: arrayReference, labelManagerIn: labelManager)//begin discovering characteristics
        }
        else {
            sendUserErrorNotification() //cancel scan and just have user open their app to send
        }
    }
}

//MARK: Then we move to the CBPeripheralDelegate (BleFindDelegate class)
func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
    if peripheral.state == .Connected{//double check to make sure we don't get ahead of ourselves
        for service in peripheral.services { //scan through all available services
            let thisService = service as? CBService //must be explicitly converted to a CBService to be passed to the didDiscoverCharacteristics
            if service.UUID == EDISON_SERVICE_UUID {
                peripheral.discoverCharacteristics(nil, forService: thisService?)//pass to didDiscoverCharacteristicsForService
            }
        }
    }
    else {
        sendUserErrorNotification()
    }
    
}

// Then "discover" the write characteristic
func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
    let foundCharacteristic: CBCharacteristic
    if peripheral.state == .Connected { //check again in case of disconnect
        for charateristic in service.characteristics { //run through the discovered characteristics to make sure the write one exists
            let thisCharacteristic = charateristic as? CBCharacteristic // again, must be explicitly passed as a charateristic
            if thisCharacteristic.UUID == EDISON_WRITE_NO_RESPONSE_UUID {
                self.bleWriter = BleWriter(characteristic: thisCharacteristic, arrayReferenceIn: arrayReference) //send info to create a write object that can be referenced to write to the characterisitc
                bleWriter.writeToClosestPeripheral(TICKETFLYSAMPLEDATA) //whatever you want to write--automatically disconnects from the peripheral after the write
                endBackgroundTask(myBackgroundTask) //kill the process
            }
        }
    }
}



//Methods that work fine, just included them here for the sake of completeness
//Will be included in the BeaconManager class
func timoutChecker(){ //I just stubbed this out quickly to have a method to notify the user of a timeout and kill the process before the OS forces us off
    var message: String
    timeLeft = UIApplication.sharedApplication().backgroundTimeRemaining
    if timeLeft < 5.00 { //or whatever it should be
        sendUserErrorNotification() //see below
    }
}

//from BeaconManager class
func sendUserErrorNotification () {
    timeoutTimer.invalidate() //invalidate the self check
    stopBeaconScan() //stops ibeacon scan
    bleScanner?.centralManager.stopScan() //stops BLE scan
    message = "Hey! Our backgrounding timed out, but open your phone to our app and we'll get you scanned in!"
    self.sendLocalNotificationWithMessage(message)//sends the notification to user to open the app with the above message
    endBackgroundTask(myBackgroundTask) //Kill the process
}

//from BeaconManager class
func sendLocalNotificationWithMessage(message: String) {
    if UIApplication.sharedApplication().applicationState != .Active {
        let notification = UILocalNotification()
        notification.alertBody = message
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}

//from BeaconManager class
func rssiChecker(){
    if self.closestBeacon?.rssi >= -60 { //if close enough to the beacon
        self.stopBeaconScan() //stop the ibeacon scan
        bleScanner?.centralManager.scanForPeripheralsWithServices(nil , options: nil)
    }
    else {
        //continue to range
    }
}

//from the BleWriter class
func writeToClosestPeripheral (datatoWrite: NSData!) {
    if arrayReference.connectFlag == true && self.foundCharacteristic?.UUID == EDISON_WRITE_NO_RESPONSE_UUID { //check again for disconnect
        arrayReference.peripheralArray[0].writeValue(datatoWrite, forCharacteristic: foundCharacteristic, type: CBCharacteristicWriteType.WithoutResponse) //write the data
        arrayReference.centralManager?.cancelPeripheralConnection(arrayReference.peripheralArray[0]) //disconnect
    }
    else {
        println ("Tried to write, but couldn't")
    }
}
*/