//
//  ViewController.swift
//  BleScanner
//
//  Created by michael on 6/15/15.
//  Copyright (c) 2015 Ticketfly. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

let RBL_MAIN_UUID = CBUUID(string: "5558C39F-910A-8588-1202-0C22C209ECBC")
let RBL_SERVICE_UUID = CBUUID(string: "713D0000-503E-4C75-BA94-3148F18D941E")
let RBL_NOTIFY_UUID = CBUUID(string:"713D0002-503E-4C75-BA94-3148F18D941E")
let RBL_WRITE_NO_RESPONSE_UUID = CBUUID(string:"713D0003-503E-4C75-BA94-3148F18D941E")
let RBL_BLE_FRAMEWORK_VER = 0x0200

let EDISON_WRITE_NO_RESPONSE_UUID = CBUUID(string:"2340503E-0DE1-4B6E-ACB4-209EB49580F8")
let EDISON_MAIN_UUID = CBUUID(string: "26F6396B-F42A-258F-5376-861FF34AFC80")
let EDISON_SERVICE_UUID = CBUUID(string: "7562438A-2284-4D03-AC70-B15509F87B94")

let enableValue = "7eab2192-29bc-11e5-b345-feff819cdc9f"
let TICKETSAMPLEDATA: NSData! = enableValue.dataUsingEncoding(NSUTF8StringEncoding)

var bleScanner: BleScanner?

class ViewController: UIViewController{
    let sendButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    
       override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Set up title label
        var titleLabel = UILabel()
        titleLabel.text = "My BLE Shield"
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: view.frame.midX, y: titleLabel.bounds.midY+28)
        view.addSubview(titleLabel)
        
        // Set up status label
        var statusLabel = UILabel()
        statusLabel.textAlignment = NSTextAlignment.Center
        statusLabel.text = "Loading..."
        statusLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        statusLabel.sizeToFit()
        statusLabel.frame = CGRect(x: view.frame.origin.x, y: titleLabel.frame.maxY, width: view.frame.width, height: statusLabel.bounds.height)
        self.view.addSubview(statusLabel)
        
        // Set up message label
        var messageLabel = UILabel()
        messageLabel.text = "The BLE Says:..."
        messageLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 35)
        messageLabel.sizeToFit()
        messageLabel.center = self.view.center
        self.view.addSubview(messageLabel)
        
        //RSSI label
        var RssiLabel = UILabel()
        RssiLabel.text = "RSSI: Unknown"
        RssiLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        RssiLabel.sizeToFit()
        RssiLabel.frame = CGRect(x: view.frame.origin.x+27, y: statusLabel.frame.maxY+50, width: view.frame.width, height: RssiLabel.bounds.height)
        self.view.addSubview(RssiLabel)
        
        //sendButton setup
        sendButton.frame = CGRectMake(110, 400, 100, 50)
        //sendButton.backgroundColor = UIColor.greenColor()
        sendButton.setTitle("Send Ticket", forState: UIControlState.Normal)
        sendButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(sendButton)
        println ("done")
        
        let labelManager = LabelCheckManager (messageLabelIn: messageLabel, rssiLabelIn: RssiLabel, statusLabelIn: statusLabel)
        bleScanner = BleScanner(labelManagerIn: labelManager)
        println ("done2")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func buttonAction (sender:UIButton!)
    {
        if bleScanner?.arrayReference.connectFlag == true && bleScanner?.centralManager.state == CBCentralManagerState.PoweredOn {
            println ("Manual Write")
            bleScanner?.blePeripheralFinder?.bleWriter?.writeToClosestPeripheral(TICKETSAMPLEDATA)
            bleScanner?.centralManager.cancelPeripheralConnection(bleScanner?.blePeripheralFinder?.bleShield)
        }
    }
    
}

