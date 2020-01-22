//
//  ViewController.swift
//  powerStoryboard
//
//  Created by Sören Schröder on 06.01.20.
//  Copyright © 2020 Sören Schröder. All rights reserved.
//

import UIKit
import PencilKit

enum SceneState {
    case unknown
    case lampOff
    case lampOnBottom
    case lampOnTop
}

class LampPuzzleViewController: UIViewController {
    @IBOutlet weak var Lamp: UIImageView!
    @IBOutlet weak var tempWriteHint: UILabel!
    let canvasView = PKCanvasView(frame: .zero)
    
    let powerCableConnectionService : PowerCableConnectionServiceProtocol
    
    let offImage: UIImage = UIImage(named: "Off")!
    let onImage: UIImage = UIImage(named: "On")!
    
    var currentState: SceneState
    var lastHorizontalDeviceOrientation: UIDeviceOrientation = UIDeviceOrientation.landscapeRight
    
    required init?(coder aDecoder: NSCoder) {
        powerCableConnectionService = PowerCableConnectionService()
        currentState = .unknown
        super.init(coder: aDecoder)
    }
    
    @objc func rotated() {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            lastHorizontalDeviceOrientation = .landscapeLeft
        case .landscapeRight:
            lastHorizontalDeviceOrientation = .landscapeRight
        default:
            break
        }
        updateScene()
    }
    
    private func turnLampOn() {
        Lamp.image = onImage
        updateScene()
    }
    
    private func turnLampOff() {
        Lamp.image = offImage
        updateScene()
    }
    
    private func isUpsideDown() -> Bool {
        return lastHorizontalDeviceOrientation == .landscapeLeft
    }
    
    private func updateScene() {
        let isPluggedIn = powerCableConnectionService.isPluggedIn()
        if (!isPluggedIn) {
            currentState = .lampOff
            Lamp.image = offImage
            print("plugged out")
            tempWriteHint.text = ""
        }
        else {
            if (isUpsideDown()) {
                currentState = .lampOnTop
                Lamp.image = onImage
                enableDrawing()
                tempWriteHint.text = "solve (Handwritten)"
                print ("go draw")
                enableDrawing()
            } else {
                currentState = .lampOnBottom
                Lamp.image = onImage
                print ("turn around")
                tempWriteHint.text = ""
            }
        }
    }
    
    private func enableDrawing() {
        // Add the pencil canvas on top of the main view.
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
        view.addSubview(canvasView)
        
        // Fit the the pencil canvas to entire screen.
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    fileprivate func observeDeviceOrientation() {
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tempWriteHint.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        observeDeviceOrientation()
        
        powerCableConnectionService.register(connectCallback: turnLampOn)
        powerCableConnectionService.register(disconnectCallback: turnLampOff)
        
        updateScene()
    }
}
