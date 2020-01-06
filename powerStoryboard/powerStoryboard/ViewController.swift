//
//  ViewController.swift
//  powerStoryboard
//
//  Created by Sören Schröder on 06.01.20.
//  Copyright © 2020 Sören Schröder. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var batteryState: UIDevice.BatteryState { UIDevice.current.batteryState }
    @IBOutlet weak var Lamp: UIImageView!
    
    var offImage: UIImage = UIImage(named: "Off")!
    var onImage: UIImage = UIImage(named: "On")!
    
    fileprivate func enableBatteryMonitoring() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChange), name: UIDevice.batteryStateDidChangeNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableBatteryMonitoring()
    }
    
    fileprivate func updatePluggedInState() {
        switch batteryState {
        case .charging, .full:
            Lamp.image = onImage
        case .unplugged, .unknown:
            Lamp.image = offImage
        @unknown default:
            Lamp.image = offImage
        }
    }
    
    @objc func batteryStateDidChange(_ notification: Notification) {
        updatePluggedInState()
    }
}

