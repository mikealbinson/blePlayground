//
//  BleScanner.swift
//  BlePlayground
//
//  Created by michael on 6/19/15.
//  Copyright (c) 2015 Ticketfly. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit


//MARK: bleScanningObject
class BleScanner: NSObject, CBCentralManagerDelegate {
    
    var counter = 0
    
    let arrayReference: peripheralArray
    var blePeripheralFinder: BlePeripheralFinder!
    var connectionTimer: NSTimer!
    
    let labelManager: LabelCheckManager
    
    init(arrayReferenceIn: peripheralArray, labelManagerIn: LabelCheckManager){
        self.arrayReference = arrayReferenceIn
        self.labelManager = labelManagerIn
        
        
        super.init()
        //connectionTimer = NSTimer.scheduledTimerWithTimeInterval (15, target: self, selector: "makeSureConnectedToClosestBle", userInfo: nil, repeats: true)
        //can't recognize the selector
    }
    
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        var powerState = central.state
        if powerState == CBCentralManagerState.PoweredOn
        {
            println ("Powered on")
            //Scan and retrieve
            central.scanForPeripheralsWithServices(nil, options: nil)
            labelManager.statusLabelStatusChange("Central Powered On")
        }
        else if powerState == CBCentralManagerState.PoweredOff
        {
            println ("Bluetooth is powered off")
            labelManager.statusLabelStatusChange("Bluetooth is Off")
            labelManager.rssiLabelStatusChange("RSSI: Unknown")
            labelManager.messageLabelStatusChange("The BLE Says:...")
        }
        else
        {
            println ("Something else is going on")
            labelManager.messageLabelStatusChange("Something's not right")
            
        }
    }
    // Check out the discovered peripherals
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        if central.state == .PoweredOn {
        let deviceName = "TFLY"
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        var index: Int
        let peripheralToUse: CBPeripheral!
        
        if (nameOfDeviceFound == deviceName) {
            // Update Status Label
            labelManager.statusLabelStatusChange("BLE Shield Found")
            labelManager.messageLabelStatusChange("The BLE Says:...")
            arrayReference.appendPeripheral(peripheral)
            central.stopScan()
            central.connectPeripheral(peripheral, options: nil)
            arrayReference.connectFlag = true
            println ("Shield connected")
            println(peripheral)
            index = arrayReference.findIndex(peripheral)
            if index == -1 {
                println ("No shields in array to connect to")
            }
            else {
                self.blePeripheralFinder = BlePeripheralFinder(peripheral: arrayReference.peripheralArray[index], arrayReferenceIn: arrayReference, labelManagerIn: labelManager)
            }
        }
        else {
            labelManager.statusLabelStatusChange("No Shield Found")
            labelManager.messageLabelStatusChange("No BLE :(")
        }
    }
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        labelManager.statusLabelStatusChange("Discovering peripheral services")
        peripheral.discoverServices(nil)
        println ("Discovered")
        labelManager.statusLabelStatusChange("discovered services")

    }
    
    // If disconnected, start searching again
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        //timer.invalidate()
        if central.state == .PoweredOn {
            arrayReference.connectFlag = false
        labelManager.statusLabelStatusChange("Disconnected")
        labelManager.rssiLabelStatusChange("RSSI: Unknown")
        labelManager.messageLabelStatusChange("No BLE :(")
        central.scanForPeripheralsWithServices(nil, options: nil)
        }
    }
    
    //(Padding?) check to ensure that the
    func makeSureConnectedToClosestBle (central: CBCentralManager!, currentConnectedPeripheral: CBPeripheral!){
        
        let bestPeripheral: CBPeripheral
        bestPeripheral = arrayReference.findClosestBle()
        if bestPeripheral == currentConnectedPeripheral {
            println ("Carry on")
        }
        else {
            central.cancelPeripheralConnection(currentConnectedPeripheral!)
            central.connectPeripheral(bestPeripheral, options: nil)
        }
    }
}

