//
//  ViewController.swift
//  BleScanner
//
//  Created by michael on 6/15/15.
//  Copyright (c) 2015 Ticketfly. All rights reserved.
//

import UIKit
import CoreBluetooth

let RBL_MAIN_UUID = CBUUID(string: "5558C39F-910A-8588-1202-0C22C209ECBC")
let RBL_SERVICE_UUID = CBUUID(string: "713D0000-503E-4C75-BA94-3148F18D941E")
let RBL_NOTIFY_UUID = CBUUID(string:"713D0002-503E-4C75-BA94-3148F18D941E")
let RBL_WRITE_NO_RESPONSE_UUID = CBUUID(string:"713D0003-503E-4C75-BA94-3148F18D941E")
let RBL_BLE_FRAMEWORK_VER = 0x0200

let enableValue = "75iGkxWAw695wp"
let TICKETSAMPLEDATA: NSData! = enableValue.dataUsingEncoding(NSUTF8StringEncoding)

class ViewController: UIViewController{
    var titleLabel : UILabel!
    var statusLabel : UILabel!
    var messageLabel : UILabel!
    var RssiLabel: UILabel!
    let sendButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    var bleScanner: BleScanner!
    var labelManager: LabelCheckManager!
    //var labelSetupTimer: NSTimer!


       override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Set up title label
        titleLabel = UILabel()
        titleLabel.text = "My BLE Shield"
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: self.view.frame.midX, y: self.titleLabel.bounds.midY+28)
        self.view.addSubview(titleLabel)
        
        // Set up status label
        statusLabel = UILabel()
        statusLabel.textAlignment = NSTextAlignment.Center
        statusLabel.text = "Loading..."
        statusLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        statusLabel.sizeToFit()
        statusLabel.frame = CGRect(x: self.view.frame.origin.x, y: self.titleLabel.frame.maxY, width: self.view.frame.width, height: self.statusLabel.bounds.height)
        self.view.addSubview(statusLabel)
        
        // Set up message label
        messageLabel = UILabel()
        messageLabel.text = "The BLE Says:..."
        messageLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 35)
        messageLabel.sizeToFit()
        messageLabel.center = self.view.center
        self.view.addSubview(messageLabel)
        
        //RSSI label
        RssiLabel = UILabel()
        RssiLabel.text = "RSSI: Unknown"
        RssiLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        RssiLabel.sizeToFit()
        RssiLabel.frame = CGRect(x: self.view.frame.origin.x+27, y: self.statusLabel.frame.maxY+50, width: self.view.frame.width, height: self.RssiLabel.bounds.height)
        self.view.addSubview(RssiLabel)
        
        //sendButton setup
        sendButton.frame = CGRectMake(110, 400, 100, 50)
        //sendButton.backgroundColor = UIColor.greenColor()
        sendButton.setTitle("Send Ticket", forState: UIControlState.Normal)
        sendButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(sendButton)
        println ("done")
        
        labelManager = LabelCheckManager (messageLabelIn: messageLabel, rssiLabelIn: RssiLabel, statusLabelIn: statusLabel)
        bleScanner = BleScanner(labelManagerIn: labelManager)
        println ("done2")
            }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buttonAction (sender:UIButton!)
    {
        if bleScanner.arrayReference.connectFlag == true && bleScanner.centralManager.state == CBCentralManagerState.PoweredOn {
        println ("Manual Write")
        bleScanner.blePeripheralFinder.bleWriter.writeToClosestPeripheral(TICKETSAMPLEDATA)
        }
    }

}

