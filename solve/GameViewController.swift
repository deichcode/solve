//
//  GameViewController.swift
//  Solve
//
//  Created by Sören Schröder on 22.01.20.
//  Copyright © 2020 Sören Schröder. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreMotion

enum LampState {
    case unknown
    case lampOff
    case lampOn
}

enum SceneState {
    case unsolved
    case solved
}

class GameViewController: UIViewController {

    @IBOutlet weak var screenLabel: UILabel!
    @IBOutlet weak var door: UIImageView!
    @IBOutlet weak var Lamp: UIImageView!
    
    let powerCableConnectionService : PowerCableConnectionServiceProtocol
    let offImage: UIImage = UIImage(named: "lamp-off")!
    let onImage: UIImage = UIImage(named: "lamp-on")!
    let closedDoor: UIImage = UIImage(named: "door-closed.jpeg")!
    var currentLampState: LampState
    var currentSceneState: SceneState = .unsolved
    


    required init?(coder aDecoder: NSCoder) {
        powerCableConnectionService = PowerCableConnectionService()
        currentLampState = .unknown
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }

        
        powerCableConnectionService.register(connectCallback: turnLampOn)
        powerCableConnectionService.register(disconnectCallback: turnLampOff)
        if (currentSceneState == .solved) {
            screenLabel?.text = "Knock Knock"
            observeDoor()
        }
        updateScene()
    }
    
    private func updateScene() {
        let isPluggedIn = powerCableConnectionService.isPluggedIn()
        if (!isPluggedIn) {
            currentLampState = .lampOff
            Lamp?.image = offImage
            door?.image = nil
            screenLabel.text = ""
//            print("plugged out")
        }
        else {
            currentLampState = .lampOn
            Lamp.image = onImage
            door.image = closedDoor
//            screenLabel?.text = "Knock Knock"
//            observeDoor()
//            print ("plugged in")
        }
    }
    
    private func turnLampOn() {
        updateScene()
    }
    
    private func turnLampOff() {
        updateScene()
    }
    
    private func observeDoor(){
        let motion = CMMotionManager()
        let motionUpdateInterval = 1.0/60.0     //60 Hz
        
        if motion.isAccelerometerAvailable {
            motion.accelerometerUpdateInterval = motionUpdateInterval
            motion.startAccelerometerUpdates()

            var knockReset : Int = 0
            var calibration : Int = 10 //We need the first 10 cycles for calibration
            let knockTimer : Int = 60 //Timer for the second knock to occur
            // Accelerometer data
            var acceleration = Acceleration(smooth : (0,0,0), rolling : (0,0,0))
            print("cool")
            // Configure a timer to fetch the data periodically
            let timer = Timer(fire: Date(), interval: motionUpdateInterval, repeats: true, block: { (timer) in
                // Get the accelerometer data
                if let data = motion.accelerometerData {
                    // High pass filter to smoothen our data
                    let currentValues = (x: data.acceleration.x, y: data.acceleration.y,z: data.acceleration.z)
                    acceleration = self.highPassFilter(currentValues: currentValues,acceleration: acceleration)

                    /*
                     * A threshold for a knock.
                     * The knock occurs in the Z-axis.
                     * The X-axis and Y-axis are there to limit opening the door when the user moves the tablet in Z-axis without knocking. We use both raw values from the accelerometer and the smoothen data. The raw values indicate that the tablet is laying on a table, the smoothen data tells us if the tablet is moving.
                     *
                     * x is the smoothen value
                     * data.acceleration.x is the value from the accelerometer
                     */
                    if( abs(acceleration.smooth.x) < 0.02 && abs(data.acceleration.x) < 0.02 &&
                        abs(acceleration.smooth.y) < 0.02 && abs(data.acceleration.y) < 0.02 &&
                        abs(acceleration.smooth.z) > 0.05 &&
                        calibration == 0 ){

                        if (knockReset == 0) {
                            //print("First Knock")
                            self.screenLabel.text = "Knock"
                            knockReset = knockTimer //Set up timer
                        }
                        /*
                         * This condition prevents recognize one knock as two
                         * because the sensors aren't still stabilized. We wait 7 cycles
                         */
                        else if(knockReset < (knockTimer-7)){
                            //print("Double Knocked")
                            self.screenLabel.text = "Well done"
                            knockReset = 0
                            timer.invalidate()
                            let openedDoor = UIImage(named: "door-opened.jpeg")
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
                            self.screenLabel.text = "Knock Knock"
                        }
                    }
                }
            })
        
        // Add the timer to the current run loop.
        RunLoop.current.add(timer, forMode: .default)
        }
    }
    
    /*
     * High pass filter to smoothen our data
     */
    private func highPassFilter(currentValues: (x: Double, y: Double,z: Double), acceleration: Acceleration) -> Acceleration{
        let kFilteringFactor : Double = 0.5
        var nextAcceleration = Acceleration(smooth : (0,0,0), rolling : (0,0,0))
        nextAcceleration.rolling.x = (currentValues.x * kFilteringFactor) + (acceleration.rolling.x * (1.0 - kFilteringFactor))
        nextAcceleration.rolling.y = (currentValues.y * kFilteringFactor) + (acceleration.rolling.y * (1.0 - kFilteringFactor))
        nextAcceleration.rolling.z = (currentValues.z * kFilteringFactor) + (acceleration.rolling.z * (1.0 - kFilteringFactor))
        nextAcceleration.smooth.x = currentValues.x - nextAcceleration.rolling.x
        nextAcceleration.smooth.y = currentValues.y - nextAcceleration.rolling.y
        nextAcceleration.smooth.z = currentValues.z - nextAcceleration.rolling.z
        return nextAcceleration
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
