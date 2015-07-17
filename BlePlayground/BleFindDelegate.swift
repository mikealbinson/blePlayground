//
//  BleFindDelegate.swift
//  BlePlayground
//
//  Created by michael on 6/19/15.
//  Copyright (c) 2015 Ticketfly. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit


// MARK: BleFindDelegates
class BlePeripheralFinder: NSObject, CBPeripheralDelegate {
    var RssiGlobal = [Int](count: 4, repeatedValue: 0)
    var RssiCounter = 0
    var sendFlag = true
    
    let bleShield: CBPeripheral
    
    var sendDelayTimer: NSTimer?
    var rssiTimer: NSTimer?
    
    var bleWriter: BleWriter?
    let arrayReference: peripheralArray
    let labelManager: LabelCheckManager
    var discoveryFlag = false
    
    init (peripheral: CBPeripheral, arrayReferenceIn: peripheralArray, labelManagerIn: LabelCheckManager){
        self.bleShield = peripheral
        self.arrayReference = arrayReferenceIn
        self.labelManager = labelManagerIn
    
        super.init()
        sendDelayTimer = NSTimer.scheduledTimerWithTimeInterval (15, target: self, selector: "unflagSender", userInfo: nil, repeats: true)
        rssiTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "rssiCheckAndSend", userInfo: nil, repeats: true)
        peripheral.delegate = self

    }
    
    // First find the service UUID
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if peripheral.state == .Connected{
        labelManager.statusLabelStatusChange("Looking at peripheral services")
            for service in peripheral.services {
                let thisService = service as! CBService
                if service.UUID == EDISON_SERVICE_UUID { //MARK: can change back to RBL services HERE
                    println("Found one")
                    peripheral.discoverCharacteristics(nil, forService: thisService)
                }
            }
        }
        else {
            labelManager.messageLabelStatusChange("Still Off")
        }
    
    }
    
   // peripheral.readValueForCharacteristic(
    
    // Then "discover" the write characteristic
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if peripheral.state == .Connected {
            labelManager.statusLabelStatusChange("Finding Characteristics")
            var count = 0
            let foundCharacteristic: CBCharacteristic
        
            // check the uuid of each characteristic to find config and data characteristics
            for charateristic in service.characteristics {
                let thisCharacteristic = charateristic as! CBCharacteristic
                // check for write characteristic
                if thisCharacteristic.UUID == EDISON_WRITE_NO_RESPONSE_UUID {
                    // Enable Sensor
                    self.bleWriter = BleWriter(characteristic: thisCharacteristic, arrayReferenceIn: arrayReference)
                    discoveryFlag = true
                    count += 1
                    labelManager.statusLabelStatusChange("Enabling services (\(count) done)")
                    if count == 1 {
                        labelManager.statusLabelStatusChange("Connected")
                    }
                }
            }
        }
    }
    /*
    func peripheralDidUpdateRSSI(peripheral: CBPeripheral!, error: NSError!) {
        if bleShield.RSSI != nil {
            RssiGlobal[RssiCounter] = bleShield.RSSI.integerValue
        }
        //println (RssiCounter)
        if RssiCounter == 2 {
            RssiGlobal[3] = (RssiGlobal[0] + RssiGlobal[1] + RssiGlobal[2])/3
            //println (bleShield.RSSI)
            labelManager.rssiLabelStatusChange("RSSI: \(RssiGlobal[3])")
            RssiCounter = -1
        }
        RssiCounter += 1
        
    }
    */
    func rssiCheckAndSend (){ //Write a sender timer and a rssi checker timer
        if  bleShield.state == .Connected && sendFlag == true {
            println("timer write")
            bleWriter?.writeToClosestPeripheral(TICKETSAMPLEDATA)
            discoveryFlag = false
            sendFlag = false
        }
    }
    
    func unflagSender (){
        sendFlag = true
    }
    
    
    // Get a message from the BLE
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if peripheral.state == .Connected {
            if characteristic.UUID == RBL_NOTIFY_UUID {
                // Convert NSData to array of signed 16 bit values
                let dataBytes = characteristic.value
                let message = NSString (data: dataBytes, encoding: NSUTF8StringEncoding)
                if let carrier = message as? String {
                    labelManager.messageLabelStatusChange(carrier);
                }
                else {
                    labelManager.messageLabelStatusChange("error reading")
                }
            }
        }
    }
}
