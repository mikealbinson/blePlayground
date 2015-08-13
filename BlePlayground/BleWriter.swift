//
//  BleReaderWriter.swift
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
    
    let foundCharacteristic: CBCharacteristic?
    var arrayReference: peripheralArray
    
    init(characteristic: CBCharacteristic, arrayReferenceIn: peripheralArray){
        self.foundCharacteristic = characteristic
        self.arrayReference = arrayReferenceIn
    }
    
    func writeToClosestPeripheral (datatoWrite: NSData!) {
        if arrayReference.connectFlag == true && self.foundCharacteristic?.UUID == EDISON_WRITE_NO_RESPONSE_UUID { //check again for disconnect
            arrayReference.peripheralArray[0].writeValue(datatoWrite, forCharacteristic: foundCharacteristic, type: CBCharacteristicWriteType.WithoutResponse) //write the data
            arrayReference.centralManager?.cancelPeripheralConnection(arrayReference.peripheralArray[0]) //disconnect
        }
        else {
            println ("Tried to write, but couldn't")
        }
    }
}