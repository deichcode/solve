//
//  ViewController.swift
//  volume
//
//  Created by Marius Völkel on 02.01.20.
//  Copyright © 2020 Marius Völkel. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {
    //audioLevel used to detect up/down Volume button
    private var audioLevel : Float = 0.0
    
    var helpButtonCount : Int = 0
    
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var volumeImage: UIImageView!
    
    @IBOutlet weak var down_left_Label: UILabel!
    @IBOutlet weak var up_right_Label: UILabel!
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
        // Do any additional setup after loading the view.
        let volumeView = MPVolumeView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        volumeView.isHidden = false
        volumeView.alpha = 0.01
        view.addSubview(volumeView)

        up_right_Label.text = ""
        down_left_Label.text = ""
        
        listenVolumeButton()
        increaseLabel(up: 0, down: 0)
    }
    
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
    
    func listenVolumeButton(){
         let audioSession = AVAudioSession.sharedInstance()
         do {
              try audioSession.setActive(true, options: [])
         audioSession.addObserver(self, forKeyPath: "outputVolume",
                                  options: NSKeyValueObservingOptions.new, context: nil)
              audioLevel = audioSession.outputVolume
         } catch {
              print("Error")
         }
    }
     
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
         if keyPath == "outputVolume"{
              let audioSession = AVAudioSession.sharedInstance()
              if audioSession.outputVolume > audioLevel {
                levelDecide(updown: "up")
                print("Up")
              }
              if audioSession.outputVolume < audioLevel {
                levelDecide(updown: "down")
                print("Down")
              }
              audioLevel = audioSession.outputVolume
              print(audioSession.outputVolume)
         }
    }
    
    private var upCount : Int = 0

    //gets Volume Up/Down as input and will decide in which state the solve is
    func levelDecide(updown: String) {
        if updown == "up" {
            print("up")
            if upCount == 0 {
                upCount = 1
            } else if upCount == 1{
                upCount = 2
            } else {
                upCount = 0
            }
        } else if updown == "down" {
            print("down")
            if upCount == 2 {
                print("Success")
                // create the alert
                let alert = UIAlertController(title: "Sucess", message: "You solved the puzzle", preferredStyle: UIAlertController.Style.alert)
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Next...", style: UIAlertAction.Style.default, handler: nil))
                // show the alert
                self.present(alert, animated: true, completion: nil)
            } else {
                upCount = 0
            }
        } else {
            print("Error")
        }
        
    }

}

