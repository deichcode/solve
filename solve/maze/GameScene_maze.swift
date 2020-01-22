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

class GameScene_maze: SKScene, SKPhysicsContactDelegate {
    
    var motionManager: CMMotionManager = CMMotionManager()
    
    let marbleName = "marble"
    let holeName = "hole"
    
    let holePosition = CGPoint(x: -20, y: 25)
    let marbleStartX = -467.0
    let marbleStartY = 339.0

    
    let holeRadius: CGFloat = 20
    let marbleRadius: CGFloat = 15
    
    let maxNaturalX = 70.0
    let maxNaturalY = 130.0

    var maxX = 0.0
    var maxY = 0.0
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        
        let marble = SKShapeNode(circleOfRadius: marbleRadius)
        marble.fillColor = .gray
        marble.lineWidth = 0
        marble.name = marbleName
        marble.position = CGPoint(x: marbleStartX, y: marbleStartY)
        marble.zPosition = 2
        marble.physicsBody = SKPhysicsBody(circleOfRadius: marbleRadius)
        marble.physicsBody?.isDynamic = true
        marble.physicsBody?.categoryBitMask = 1
        marble.physicsBody?.collisionBitMask = 2
        marble.physicsBody?.contactTestBitMask = 4
        self.addChild(marble)
        
        let hole = SKShapeNode(circleOfRadius: holeRadius)
        hole.fillColor = .black
        hole.lineWidth = 0
        hole.name = holeName
        hole.position = holePosition
        hole.zPosition = 1
        hole.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        hole.physicsBody?.isDynamic = false
        hole.physicsBody?.categoryBitMask = 4
        hole.physicsBody?.contactTestBitMask = 1
        self.addChild(hole)

        self.physicsWorld.contactDelegate = self
        
//        let operationQueue = OperationQueue()
//        if(motionManager.isMagnetometerAvailable) {
//            print ("Magentometer Available")
//        }
//        if(motionManager.isMagnetometerActive) {
//            print ("Magentometer Active")
//        }
        motionManager.magnetometerUpdateInterval = 1/30
        motionManager.startMagnetometerUpdates()
        //        motionManager.startMagnetometerUpdates(to: operationQueue) { (magnetometerData, error) in
        //            guard error == nil else {
        //                print(error!)
        //                return
        //            }
        //
        //            if let magnetData = magnetometerData {
        //                print("X: ", magnetData.magneticField.x)
        //                print("Y: ", magnetData.magneticField.y)
        //            }
        //        }
        
//        if(motionManager.isMagnetometerActive) {
//            print ("Magentometer Active")
//        }
//
//        print("didMove finished")
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if(contact.bodyA.node?.name == marbleName || contact.bodyB.node?.name == marbleName ) {
            if(contact.bodyA.node?.name == holeName || contact.bodyB.node?.name == holeName ) {
                guard let marble = self.childNode(withName: marbleName) else { return }
                marble.removeFromParent()
            }
        }
    }

    //    private func magnetometerHandler(data: CMMagnetometerData?, error: Error?) {
    //        print("magnetometerHandler")
    //        print("X: ", data?.magneticField.x ?? "")
    //        print("Y: ", data?.magneticField.y ?? "")
    //    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
//        print(motionManager.isMagnetometerActive)
        
        guard let marble = self.childNode(withName: marbleName) else { return }
        if let magnetData = motionManager.magnetometerData {
            let oldX = Double(marble.position.x)
            let oldY = Double(marble.position.y)
            let magneticX = magnetData.magneticField.x
            let magneticY = magnetData.magneticField.y
            let scaleFactor = 500.0
//            print("Magnetic X", magneticX)
//            print("Magnetic Y", magneticY)
            maxX = maxX < abs(magneticX) ? abs(magneticX) : maxX
            maxY = maxY < abs(magneticY) ? abs(magneticY) : maxY
            let isNaturalMagnetism = abs(magneticX) < maxNaturalX && abs(magneticY) < maxNaturalY
            let scaledMagneticX = isNaturalMagnetism ? 0 : magneticX / scaleFactor
            let scaledMagneticY = isNaturalMagnetism ? 0 : magneticY / scaleFactor
//            print("Scaled X: ", magneticX, scaledMagneticX)
//            print("Scaled Y: ", magneticY, scaledMagneticY)
//            print("Current X", marble.position.x)
//            print("Current Y", marble.position.y)
            marble.position = CGPoint(x: oldX + -scaledMagneticY, y: oldY + scaledMagneticX)
        }
        //        marble
        
        
    }
}
