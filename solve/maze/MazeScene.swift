//
//  GameScene.swift
//  labyrinth
//
//  Created by Sören Schröder on 16.01.20.
//  Copyright © 2020 Sören Schröder. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class MazeScene : SKScene, SKPhysicsContactDelegate {
    
    var viewController: MazeViewController!
    
    var motionManager: CMMotionManager = CMMotionManager()
    
    let marbleName = "marble"
    let holeName = "hole"
    
    let holePosition = CGPoint(x: -20, y: 25)
    let marbleStartX = -467.0
    let marbleStartY = 339.0

    
    let holeRadius: CGFloat = 20
    let marbleRadius: CGFloat = 15
    
    // Thresholds that have been measured as 'natural magentic field', to prevent the marble be controlled by using the natural magnetic field
    let maxNaturalX = 70.0
    let maxNaturalY = 130.0

    var maxX = 0.0
    var maxY = 0.0
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        
        // For exam preparation: Explanation of Colission Bit masks https://www.makeschool.com/academy/track/standalone/build-hoppy-bunny-with-spritekit-in-swift/setting-up-collisions
        // Bitmasks
        // marble: 000000001 => 1
        // walls:  000000010 => 2
        // hole:   000000100 => 4
        
        //Setup of marble in scene
        let marble = SKShapeNode(circleOfRadius: marbleRadius)
        marble.fillColor = .gray
        marble.lineWidth = 0
        marble.name = marbleName
        marble.position = CGPoint(x: marbleStartX, y: marbleStartY)
        marble.zPosition = 2
        marble.physicsBody = SKPhysicsBody(circleOfRadius: marbleRadius)
        marble.physicsBody?.isDynamic = true
        marble.physicsBody?.categoryBitMask = 1
        marble.physicsBody?.collisionBitMask = 2 // => collides with walls
        marble.physicsBody?.contactTestBitMask = 4 // => calls did begin contact if contacts hole (but no physical colission)
        self.addChild(marble)
        
        //Setup of hole in scene
        let hole = SKShapeNode(circleOfRadius: holeRadius)
        hole.fillColor = .black
        hole.lineWidth = 0
        hole.name = holeName
        hole.position = holePosition
        hole.zPosition = 1
        hole.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        hole.physicsBody?.isDynamic = false
        hole.physicsBody?.categoryBitMask = 4
        self.addChild(hole)

        self.physicsWorld.contactDelegate = self
        
        //Set update interval (30 times per second)
        motionManager.magnetometerUpdateInterval = 1/30
        //Needs to be called to receive magenetometer values
        motionManager.startMagnetometerUpdates()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        //Detect colission betwene marble and hole.
        if(contact.bodyA.node?.name == marbleName || contact.bodyB.node?.name == marbleName ) {
            if(contact.bodyA.node?.name == holeName || contact.bodyB.node?.name == holeName ) {
                guard let marble = self.childNode(withName: marbleName) else { return }
                //Delete marble
                marble.removeFromParent()
                //Call segue to next puzzle with delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.viewController.performSegue(withIdentifier: "segueVolume", sender: self)
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is renderd => currently movement depends on framerate, could be solved with deltea time calculation
        guard let marble = self.childNode(withName: marbleName) else { return }
        if let magnetData = motionManager.magnetometerData {
            let magneticX = magnetData.magneticField.x
            let magneticY = magnetData.magneticField.y
            
            // Some scale factor to reduce the speed of the marble
            let scaleFactor = 500.0
            
            //Scale magnetic measurements or set to 0 if they seam to be natural
            let isNaturalMagnetism = abs(magneticX) < maxNaturalX && abs(magneticY) < maxNaturalY
            let scaledMagneticX = isNaturalMagnetism ? 0 : magneticX / scaleFactor
            let scaledMagneticY = isNaturalMagnetism ? 0 : magneticY / scaleFactor
            
            // Need to switch axis becaus of differen coordinate systems between game sceene and magneto meter
            let currentMarblePositionX = Double(marble.position.x)
            let currentMarblePositionY = Double(marble.position.y)
            let newMarblePositionX = currentMarblePositionX + -scaledMagneticY
            let newMarblePositionY = currentMarblePositionY + scaledMagneticX
            marble.position = CGPoint(x: newMarblePositionX, y: newMarblePositionY)
        }
    }
}
