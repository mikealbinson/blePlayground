//
//  BleReaderWriterClass.swift
//  BlePlayground
//
//  Created by michael on 6/19/15.
//  Copyright (c) 2015 Ticketfly. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit


//MARK: BleReadWriteClass
class BleWriter: NSObject {
    //var readPeripheralTimer = NSTimer!
    
    let foundCharacteristic: CBCharacteristic!
    var arrayReference: peripheralArray
    
    init(characteristic: CBCharacteristic, arrayReferenceIn: peripheralArray){
        self.foundCharacteristic = characteristic
        self.arrayReference = arrayReferenceIn
        //self.readPeripheralTimer.scheduledTimerWithTimeInterval (15, target: self, selector: "readClosestPeripheral", userInfo: nil, repeats: true)
    }
    
    func writeToClosestPeripheral (datatoWrite: NSData!) {
        if arrayReference.connectFlag == true {
            if self.foundCharacteristic.UUID == RBL_WRITE_NO_RESPONSE_UUID {
                arrayReference.peripheralArray[0].writeValue(datatoWrite, forCharacteristic: foundCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
            }
        }
        else {
            println ("Tried to write, but couldn't")
        }
    }
}