//
//  ViewController.swift
//  volume
//
//  Created by Marius Völkel on 02.01.20.
//  Copyright © 2020 Marius Völkel. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController_volume: UIViewController {
    //audioLevel used to detect up/down Volume button
    private var audioLevel : Float = 0.0
    
    var helpButtonCount : Int = 0
    
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var volumeImage: UIImageView!
    
    @IBOutlet weak var effectLeftImage: UIImageView!
    @IBOutlet weak var effectRightImage: UIImageView!
    
    @IBOutlet weak var up_right_Label: UILabel!
    @IBOutlet weak var down_left_Label: UILabel!
    @IBOutlet weak var buttonLabel: UIButton!
    
    
    @IBAction func helpButton(_ sender: Any) {
        if helpButtonCount == 0 {
            buttonLabel.setTitle("more help", for: .normal)
            let volume = UIImage(named: "speakers-1521314_1280.png")
            self.volumeImage.image = volume
            helpButtonCount += 1
        } else if helpButtonCount == 1 {
            let arrow = UIImage(named: "right-297788_1280.png")
            self.arrowImage.image = arrow
            helpButtonCount += 1
        } else {
            // create the alert
            let alert = UIAlertController(title: "No more help", message: "You should be able to solve this now 😉", preferredStyle: UIAlertController.Style.alert)
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide the volume control
        let volumeView = MPVolumeView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        volumeView.isHidden = false
        volumeView.alpha = 0.01
        view.addSubview(volumeView)
        
        up_right_Label.text = ""
        down_left_Label.text = ""
        
        listenVolumeButton()
        increaseLabel(up: 0, down: 0)
    }
    
    //animation of counting labels
    func increaseLabel(up :Int, down :Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.up_right_Label.text = String(up)
            self.down_left_Label.text = String(down)
            if up == 0 {self.up_right_Label.text = ""}
            if down == 0 {self.down_left_Label.text = ""}
            if up == 0 && down == 0 {self.increaseLabel(up: 1, down: 0)}
            if up == 1 && down == 0 {self.increaseLabel(up: 2, down: 0)}
            if up == 2 && down == 0 {self.increaseLabel(up: 0, down: 1)}
            if up == 0 && down == 1 {self.increaseLabel(up: 0, down: 0)}
        }
    }
    
    //observing of volume buttons
    func listenVolumeButton(){
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true, options: [])
            //observe forKeyPath outputVolume
            audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
            
            audioLevel = audioSession.outputVolume
            } catch {
                print("Error")
            }
        
    }
    
    // observer difference in audio level used to determine if up/down was pressed
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
         if keyPath == "outputVolume"{
              let audioSession = AVAudioSession.sharedInstance()
              if audioSession.outputVolume > audioLevel {
                DispatchQueue.main.async {
                    let effect = UIImage(named: "speedLinesRounded.png")
                    self.effectLeftImage.image = effect
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.effectLeftImage.image = nil
                }
                levelDecide(updown: "up")
              }
              if audioSession.outputVolume < audioLevel {
                DispatchQueue.main.async {
                    let effect = UIImage(named: "speedLinesRounded.png")
                    self.effectRightImage.image = effect
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.effectRightImage.image = nil
                }
                levelDecide(updown: "down")
              }
              audioLevel = audioSession.outputVolume
              print(audioSession.outputVolume)
         }
    }
    
    private var upCount : Int = 0

    //gets Volume Up/Down as input and will decide in which state the solve is
    func levelDecide(updown: String) {
        print(upCount)
        if updown == "up" {
            if upCount == 0 {
                upCount = 1
            } else if upCount == 1{
                upCount = 2
            } else {
                upCount = 0
            }
        } else if updown == "down" {
            if upCount == 2 {
                self.performSegue(withIdentifier: "seguePasswordCube", sender: self)
            } else {
                upCount = 0
            }
        } else {
            print("Error")
        }
        
    }
    
    
}

