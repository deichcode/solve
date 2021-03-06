//
//  GameViewController.swift
//  labyrinth
//
//  Created by Sören Schröder on 16.01.20.
//  Copyright © 2020 Sören Schröder. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController_maze: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                if let gameScene = scene as? MazeScene {
                    gameScene.viewController = self
                }
            }
            
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
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
