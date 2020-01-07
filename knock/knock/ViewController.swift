//
//  ViewController.swift
//  knock
//
//  Created by Marek Elznic on 07/01/2020.
//  Copyright © 2020 Marek Elznic. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var door: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up door and load image
        let closedDoor = UIImage(named: "door-closed.jpg")
        door.image = closedDoor
        
        //Enable interaction and create tap recognizer
        door.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tapRecognizer.numberOfTapsRequired = 2
        door.addGestureRecognizer(tapRecognizer)

    }
    //If tap is recognized, the door image is changed
    @objc func doubleTapped() {
        print("Tap")
        let openedDoor = UIImage(named: "door-opened.jpg")
        door.image = openedDoor
    }
    
}
