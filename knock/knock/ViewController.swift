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
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up door and load image
        let closedDoor = UIImage(named: "door-closed.jpg")
        door.image = closedDoor
        
        let motion = CMMotionManager()
        let motionUpdateInterval = 1.0/60.0     //60 Hz
        
        if motion.isAccelerometerAvailable {
            motion.accelerometerUpdateInterval = motionUpdateInterval
            motion.startAccelerometerUpdates()

            var knockReset : Int = 0
            var calibration : Int = 10 //We need the first 10 cycles for calibration
            let knockTimer : Int = 60 //Timer for the second knock to occur
            // Accelerometer data
            var rollingX : Double = 0
            var rollingY : Double = 0
            var rollingZ : Double = 0
            var x : Double = 0
            var y : Double = 0
            var z : Double = 0
            let kFilteringFactor : Double = 0.5
            
            // Configure a timer to fetch the data periodically
            let timer = Timer(fire: Date(), interval: motionUpdateInterval, repeats: true, block: { (timer) in
                // Get the accelerometer data
                if let data = motion.accelerometerData {
                    // High pass filter to smoothen our data
                    rollingX = (data.acceleration.x * kFilteringFactor) + (rollingX * (1.0 - kFilteringFactor))
                    rollingY = (data.acceleration.y * kFilteringFactor) + (rollingY * (1.0 - kFilteringFactor))
                    rollingZ = (data.acceleration.z * kFilteringFactor) + (rollingZ * (1.0 - kFilteringFactor))
                    x = data.acceleration.x - rollingX
                    y = data.acceleration.y - rollingY
                    z = data.acceleration.z - rollingZ

                    /*
                     * A threshold for a knock.
                     * The knock occurs in the Z-axis.
                     * The X-axis and Y-axis are there to limit opening the door when the user moves the tablet in Z-axis without knocking. We use both raw values from the accelerometer and the smoothen data. The raw values indicate that the tablet is laying on a table, the smoothen data tells us if the tablet is moving.
                     *
                     * x is the smoothen value
                     * data.acceleration.x is the value from the accelerometer
                     */
                    if( abs(x) < 0.02 && abs(data.acceleration.x) < 0.02 &&
                        abs(y) < 0.02 && abs(data.acceleration.y) < 0.02 &&
                        abs(z) > 0.05 &&
                        calibration == 0 ){

                        if (knockReset == 0) {
                            //print("First Knock")
                            self.label.text = "Knock"
                            knockReset = knockTimer //Set up timer
                        }
                        /*
                         * This condition prevents recognize one knock as two
                         * because the sensors aren't still stabilized. We wait 7 cycles
                         */
                        else if(knockReset < (knockTimer-7)){
                            //print("Double Knocked")
                            self.label.text = "Well done"
                            knockReset = 0
                            timer.invalidate()
                            let openedDoor = UIImage(named: "door-opened.jpg")
                            self.door.image = openedDoor
                        }
                        //else{print("False double knock")}
                    }
                        
                    /*
                     * First we have to calibrate the sensors
                     */
                    else if (calibration > 0){
                        calibration = calibration-1
                    }
                    //else if(z < -1.0 || z > -0.98){print("False knock")}
                    
                    /*
                     * This reduces the timer in which the second knock must occur
                     * to regonize it as a double knock.
                     */
                    if(knockReset > 0){
                        knockReset = knockReset-1
                        if (knockReset == 0){
                            self.label.text = "Knock Knock"
                        }
                    }
                }
            })
        // Add the timer to the current run loop.
        RunLoop.current.add(timer, forMode: .default)
        }
    }
}
