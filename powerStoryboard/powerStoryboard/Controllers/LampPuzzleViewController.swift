//
//  ViewController.swift
//  powerStoryboard
//
//  Created by Sören Schröder on 06.01.20.
//  Copyright © 2020 Sören Schröder. All rights reserved.
//

import UIKit

class LampPuzzleViewController: UIViewController {
    @IBOutlet weak var Lamp: UIImageView!
    
    let powerCableConnectionService : PowerCableConnectionServiceProtocol
    
    var offImage: UIImage = UIImage(named: "Off")!
    var onImage: UIImage = UIImage(named: "On")!
    
    required init?(coder aDecoder: NSCoder) {
        powerCableConnectionService = PowerCableConnectionService()
        super.init(coder: aDecoder)
    }
    
    private func turnLampOn() {
        Lamp.image = onImage
    }
    
    private func turnLampOff() {
        Lamp.image = offImage
    }
    
    override func viewDidLoad() {
        powerCableConnectionService.register(connectCallback: turnLampOn)
        powerCableConnectionService.register(disconnectCallback: turnLampOff)
    }
}



