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
    lazy var centralManager: CBCentralManager = {
        return CBCentralManager(delegate: self, queue: nil)
    }()
    var beaconManager: BeaconManager?


    let arrayReference = peripheralArray()
    var blePeripheralFinder: BlePeripheralFinder?
    var connectionTimer: NSTimer?
    
    let labelManager: LabelCheckManager
    
    init(labelManagerIn: LabelCheckManager){
        self.labelManager = labelManagerIn
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        connectionTimer = NSTimer.scheduledTimerWithTimeInterval (2, target: self, selector: "beaconTimerTargetStartScan", userInfo: nil, repeats: true)
        arrayReference.centralManager = centralManager
    }
    
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        var powerState = central.state
        arrayReference.powerState = powerState
        if powerState == CBCentralManagerState.PoweredOn
        {
            println ("Powered on")
            central.scanForPeripheralsWithServices(nil, options: nil)
            labelManager.statusLabelStatusChange("Central Powered On")
            beaconManager = BeaconManager(labelManagerIn: labelManager, scannerIn: self)
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
        let deviceName = "Ticketfly_Edison"
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        var index: Int
        let peripheralToUse: CBPeripheral?
        
        if (nameOfDeviceFound == deviceName && beaconManager?.closestBeacon?.rssi > -60) {
            // Update Status Label
            beaconManager?.stopBeaconScan()
            connectionTimer?.invalidate()
            labelManager.statusLabelStatusChange("Edison Found")
            beaconManager?.sendLocalNotificationWithMessage("Found a Ticketfly Beacon!")
            labelManager.messageLabelStatusChange("Would connect here")
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
                println("we found one!")
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
        arrayReference.connectFlag = false
        labelManager.statusLabelStatusChange("Disconnected")
        labelManager.rssiLabelStatusChange("RSSI: Unknown")
        labelManager.messageLabelStatusChange("Manual Write Done")
        beaconManager?.startBeaconScan()
        connectionTimer = NSTimer.scheduledTimerWithTimeInterval (2, target: self, selector: "beaconTimerTargetStartScan", userInfo: nil, repeats: true)
        central.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func beaconTimerTargetStartScan() {
        if beaconManager?.beaconToken == 0 {
            beaconManager?.startBeaconScan()
        }
    }
    
    
    /* --eventually may be helpful, but for now isn't doing anything
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
    
    func stopScanningBackground(){
        centralManager.stopScan()
    }
    
    func startScanningBackground(){
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
*/
}

