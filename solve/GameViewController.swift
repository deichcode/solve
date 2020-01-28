//
//  GameViewController.swift
//  Solve
//
//  Created by Sören Schröder on 22.01.20.
//  Copyright © 2020 Sören Schröder. All rights reserved.
//

import UIKit
import CoreMotion

enum SceneState {
    case unsolved
    case solved
    case showedNotYourDay
    case knocked
    case doubleKnocked
}

class GameViewController: UIViewController {
    @IBOutlet weak var sceneImage: UIImageView!
    
    let powerCableConnectionService : PowerCableConnectionServiceProtocol
    
    let inital_black: UIImage = UIImage(named: "00_inital_black")!
    let black: UIImage = UIImage(named: "01_black")!
    let locked: UIImage = UIImage(named: "02_locked")!
    let unlocked: UIImage = UIImage(named: "03_unlocked")!
    let knock1: UIImage = UIImage(named: "04_knock")!
    let knock2: UIImage = UIImage(named: "05_knock_knock")!
    let joke1: UIImage = UIImage(named: "06_joke")!
    let joke2: UIImage = UIImage(named: "07_joke")!
    let joke3: UIImage = UIImage(named: "08_joke")!
    let joke4: UIImage = UIImage(named: "09_joke")!
    let joke5: UIImage = UIImage(named: "10_joke")!
    let jokeImages: [UIImage]
    let open: UIImage = UIImage(named: "11_open")!
    let notYourDay: UIImage = UIImage(named: "12_not_your_day")!
    var lastVisibleSceneImage: UIImage?
    
    var currentSceneState: SceneState = .unsolved
    
    var lampWasOn: Bool = false
    //var showedNotYourDay: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        powerCableConnectionService = PowerCableConnectionService()
        jokeImages = [joke1, joke2, joke3, joke4, joke5]
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if (currentSceneState == .solved) {
            observeDoor()
        }
        powerCableConnectionService.register(connectCallback: updateScene)
        powerCableConnectionService.register(disconnectCallback: updateScene)
        updateScene()
    }
    
    fileprivate func showTextAfterPuzzlesSolved() {
        DispatchQueue.main.async {
            self.sceneImage.image = self.notYourDay
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.regularSceneUpdate()
        }
        currentSceneState = .showedNotYourDay
    }
    
    /*
     * Function update the current scene based on currentSceneState
     */
    private func updateScene() {
        if(currentSceneState == .solved) {
            showTextAfterPuzzlesSolved()
        } else if(currentSceneState == .knocked){
            self.sceneImage.image = self.knock1
        } else if(currentSceneState == .doubleKnocked){
            self.sceneImage.image = self.knock2
            self.playKnockKnockJoke()
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                self.sceneImage.image = self.open
            }
        } else {
            regularSceneUpdate()
        }
    }
    
    fileprivate func regularSceneUpdate() {
        let isPluggedIn = powerCableConnectionService.isPluggedIn()
        if (!isPluggedIn) {
            if(!lampWasOn){
                sceneImage.image = inital_black
            } else {
                sceneImage.image = black
            }
        }
        else {
            lampWasOn = true
            if lastVisibleSceneImage != nil {
                sceneImage.image = lastVisibleSceneImage
            } else {
                if(currentSceneState == .unsolved){
                    sceneImage.image = locked
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.performSegue(withIdentifier: "mazeSegue", sender: self)
                    }
                } else {
                    sceneImage.image = unlocked
                }
            }
            lastVisibleSceneImage = sceneImage.image
        }
    }
    
    /*
     * Function creates a timer that periodically gets data from the accelerometer.
     * This raw data are smoothened with high pass filter.
     * If a threshold is hit, knock is recognised and scene updated.
     */
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
                        
                        /*
                         * No previous knock is detected
                         */
                        if (knockReset == 0) {
                            self.currentSceneState = .knocked
                            knockReset = knockTimer //Set up timer
                            self.updateScene()
                        }
                        /*
                         * This condition prevents recognize one knock as two
                         * because the sensors aren't still stabilized. We wait 7 cycles.
                         */
                        else if(knockReset < (knockTimer-7)){
                            self.currentSceneState = .doubleKnocked
                            knockReset = 0
                            timer.invalidate()
                            self.updateScene()
                        }
                    }
                        
                    /*
                     * At the begining we have to wait a few (=10) cycles
                     * to stabilize the values from accelerometer.
                     */
                    else if (calibration > 0){
                        calibration = calibration-1
                    }
                    
                    /*
                     * This reduces the timer in which the second knock must occur
                     * to regonize it as a double knock.
                     */
                    if(knockReset > 0){
                        knockReset = knockReset-1
                        if (knockReset == 0){
                            self.currentSceneState = .showedNotYourDay
                            self.updateScene()
                        }
                    }
                }
            })
        
        // Add the timer to the current run loop.
        RunLoop.current.add(timer, forMode: .default)
        }
    }

    /*
     * Function asynchronously displays a series of images, which create a conversation before opening the door.
     */
    private func playKnockKnockJoke() {
        var delay = 0.0
        for jokeImage in jokeImages {
            delay += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.sceneImage.image = jokeImage
            }
        }
    }
    
    /*
     * High pass filter which smoothes the data from the accelerometer
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
