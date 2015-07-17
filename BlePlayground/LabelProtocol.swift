//
//  LabelProtocol.swift
//  BlePlayground
//
//  Created by michael on 6/23/15.
//  Copyright (c) 2015 Ticketfly. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth


protocol LabelDelegate {
    var rssiLabel: UILabel? {get}
    var messageLabel: UILabel? {get}
    var statusLabel: UILabel? {get}
    
    func statusLabelStatusChange (changeString: String)
    func messageLabelStatusChange (changeString: String)
    func rssiLabelStatusChange (changeString: String)
    
}


class LabelCheckManager: LabelDelegate {
    var statusCheckTimer: NSTimer?
    var messageCheckTimer: NSTimer?
    var rssiCheckTimer: NSTimer?
    
    
    var rssiLabel: UILabel?
    var messageLabel: UILabel?
    var statusLabel: UILabel?
    
    init (messageLabelIn: UILabel, rssiLabelIn: UILabel, statusLabelIn: UILabel) {
        rssiLabel = rssiLabelIn
        messageLabel = messageLabelIn
        statusLabel = statusLabelIn
    }
    
    func statusLabelStatusChange(changeString: String) {
        statusLabel?.text = changeString
    }
    
    func messageLabelStatusChange(changeString: String) {
        messageLabel?.text = changeString
    }
    
    func rssiLabelStatusChange(changeString: String) {
        rssiLabel?.text = changeString
    }
    
}