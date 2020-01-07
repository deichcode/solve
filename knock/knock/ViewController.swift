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
        
        let motion = CMMotionManager()
        let motionUpdateInterval = 1.0/60.0     //60 Hz
        var knockReset : Int = 0    //Cycle counter
        let initialTimer = 60
        
        if motion.isAccelerometerAvailable {
            motion.accelerometerUpdateInterval = motionUpdateInterval
            motion.startAccelerometerUpdates()

            // Configure a timer to fetch the data periodically
            let timer = Timer(fire: Date(), interval: motionUpdateInterval, repeats: true, block: { (timer) in
                // Get the accelerometer data.
                if let data = motion.accelerometerData {
                    let x = data.acceleration.x
                    let y = data.acceleration.y
                    let z = data.acceleration.z
                    /*
                     * A threshold for a knock.
                     * The knock occurs in the Z-axis.
                     * The X-axis and Y-axis are there to limit opening the door when the user moves the tablet in Z-axis without knocking.
                     */
                    if( (x > -0.1 && x < 0.1) &&
                        (y > -0.1 && y < 0.1) &&
                        (z < -1.0 || z > -0.98)){

                        //print("x:", x, ", y:", y, ", z:", z)
                        if (knockReset == 0) {
                            // First knock
                            print("First Knock")
                            knockReset = initialTimer //Set up timer
                        }
                        /*
                         * This condition prevents recognize one knock as two
                         * because the sensors aren't still stabilized.
                         */
                        else if(knockReset < (initialTimer-10)){
                            // Second knock
                            print("Double Knocked")
                            knockReset = 0
                            
                            timer.invalidate()
                            let openedDoor = UIImage(named: "door-opened.jpg")
                            self.door.image = openedDoor
                        }
                        //else False double knock
                    }
                    /* else if(z < -1.0 || z > -0.98)
                     * False knock
                     */
                    //Reduce reset timer
                    if(knockReset > 0){
                        knockReset = knockReset-1
                    }
                }
            })
        // Add the timer to the current run loop.
        RunLoop.current.add(timer, forMode: .default)
        }
    }
    
    //If tap is recognized, the door image is changed
    @objc func doubleTapped() {
        print("Tap")
        let openedDoor = UIImage(named: "door-opened.jpg")
        door.image = openedDoor
    }
    
    func startAccelerometers() {
       // Make sure the accelerometer hardware is available.

    }
    
}
