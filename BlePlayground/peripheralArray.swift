//
//  BleManager.swift
//  BlePlayground
//
//  Created by michael on 6/18/15.
//  Copyright (c) 2015 Ticketfly. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

//MARK: BleManager

//MARK: peripheralArray
class peripheralArray: NSObject {
    var peripheralArray = [CBPeripheral]()
    var characteristicDictionary = [CBPeripheral: CBCharacteristic]()
    var rssiDictionary = [CBPeripheral: Int]()
    var connectionDictionary = [CBPeripheral: CBPeripheralState]()
    var connectFlag = false
    var powerState: CBCentralManagerState
    
    
    override init(){
    powerState = .PoweredOff
    }
    
    func appendPeripheral(peripheral: CBPeripheral, characteristic : CBCharacteristic) {
        var peripheralFlag = false
        
        for peripherals in peripheralArray {
            if peripheral == peripherals {
                peripheralFlag = true
                println("already had that one")
            }
        }
        if peripheralFlag == false {
            peripheralArray.append (peripheral)
            characteristicDictionary[peripheral] = characteristic
            rssiDictionary[peripheral] = peripheral.RSSI.integerValue
            connectionDictionary[peripheral] = peripheral.state
        }
    }
    
    func appendPeripheral(peripheral: CBPeripheral) -> Int {
        var peripheralFlag = false
        
        for peripherals in peripheralArray {
            if peripheral == peripherals {
                peripheralFlag = true
            }
        }
        
        if connectionDictionary[peripheral] != peripheral.state{
            connectionDictionary[peripheral] = peripheral.state
        }
        
        if peripheralFlag == false {
            peripheralArray.append (peripheral)
            connectionDictionary[peripheral] = peripheral.state
        }
        return 0
    }
    
    func appendPeripheralRssi(peripheral: CBPeripheral, rssi: Int){
        rssiDictionary [peripheral] = rssi
    }
    
    func findClosestBle () -> CBPeripheral {
        var count = 0
        var bestConnection = -100
        var rssiChecker: Int
        var bestPeripheralConnection: CBPeripheral!
        var peripheral: CBPeripheral
        
        for (peripheral, rssiChecker) in self.rssiDictionary {
            if count != 0 && rssiChecker >= bestConnection && bestConnection != 0 {
                bestPeripheralConnection = peripheral
                
            }
            else {
                bestConnection = rssiChecker
            }
        }
        return bestPeripheralConnection
    }
    
    func updateRssiVal (peripheral: CBPeripheral){
        for peripherals in peripheralArray{
            if peripheral == peripherals{
                rssiDictionary [peripheral] = peripheral.RSSI.integerValue
            }
        }
    }
    
    func findIndex (peripheral: CBPeripheral) -> Int {
        
        if let index = (find(peripheralArray, peripheral)) {
            return index
        }
        else {
            println ("no elements to index")
            return -1
        }
    }
    
}