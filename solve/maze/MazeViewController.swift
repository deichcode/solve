//
//  MazeViewController.swift
//  Solve
//
//  Created by Sören Schröder on 26.01.20.
//  Copyright © 2020 Sören Schröder. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class MazeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MazeScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
                // Set this viewController as property of the MazeScene to call the segue to the next puzzle from the MazeScene
                if let gameScene = scene as? MazeScene {
                    gameScene.viewController = self
                }
            }
            
            view.ignoresSiblingOrder = true
        }
        
        
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
