//
//  ViewController.swift
//  passwordCubeDetector
//
//  Created by Marius Völkel on 16.01.20.
//  Copyright © 2020 Marius Völkel. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController_passwordCube: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var password_field_image: UIImageView!
    
    // camera capture
    var session = AVCaptureSession()
    
    //request for Textboxes and Textrecognition
    var requests = [VNRequest]()
    var textRecognitionRequest = VNRecognizeTextRequest()
    
    //swap between single letters
    var state : String = "none"
    
    // output variable
    var recognizedText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let password_field = UIImage(named: "password.png")
        self.password_field_image.image = password_field
        
        startLiveVideo()
        startTextboxDetection()
        startTextDetection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let targetViewController = segue.destination as? GameViewController else {
            return
        }
        targetViewController.currentSceneState = .solved
    }
    
    //function to get camera device
    func selectDevice() -> AVCaptureDevice{
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video, position: .front) {
            return device
        } else {
            fatalError("Missing front camera")
        }
    }
    
    func startLiveVideo() {
        //We begin by modifying the settings of our AVCaptureSession. set the AVMediaType as video live stream
        session.sessionPreset = AVCaptureSession.Preset.photo
        let deviceInput = try! AVCaptureDeviceInput(device: selectDevice())
        let deviceOutput = AVCaptureVideoDataOutput()
        
        //pixel buffer for device to work with
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        //transform the shown stream to the device orientation
        let imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.frame = imageView.bounds
        imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        imageView.layer.addSublayer(imageLayer)

        session.startRunning()
    }
        
    override func viewDidLayoutSubviews() {
        imageView.layer.sublayers?[0].frame = imageView.bounds
    }
   
    func startTextDetection(){
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
                    self.recognizedText = ""
                    //overservations is a list with possible candidates, choose the best one
                    for observation in requestResults {
                        guard let candidiate = observation.topCandidates(1).first else { return }
                          self.recognizedText += candidiate.string
                        self.recognizedText += "\n"
                    }
                    print(self.recognizedText)
                    
                    if self.state == "none" {
                        if self.recognizedText.contains("P") {
                            DispatchQueue.main.async {
                            let letter_image = UIImage(named: "image_o.png")
                            self.password_field_image.image = letter_image
                            }
                            self.state = "O"
                        }
                    }
                    
                    if self.state == "O" {
                        if self.recognizedText.contains("O") {
                            DispatchQueue.main.async {
                            let letter_image = UIImage(named: "image_p.png")
                            self.password_field_image.image = letter_image
                            }
                            self.state = "P"
                        }
                    }
                    if self.state == "P" {
                        if self.recognizedText.contains("A") {
                            DispatchQueue.main.async {
                            let letter_image = UIImage(named: "image_e.png")
                            self.password_field_image.image = letter_image
                            }
                            self.state = "E"
                        }
                    }
                    if self.state == "E" {
                        if self.recognizedText.contains("V") {
                            DispatchQueue.main.async {
                            let letter_image = UIImage(named: "image_n.png")
                            self.password_field_image.image = letter_image
                            }
                            self.state = "N"
                            sleep(2)
                        }
                    }
                    DispatchQueue.main.async {
                        if self.state == "N" {
                            self.performSegue(withIdentifier: "segueMain", sender: self)
                        }
                    }
                    
                }
            }
            
        })
            textRecognitionRequest.recognitionLevel = .accurate
        }
        
        //detection of text and boxes around it, no interpretation of the text
        func startTextboxDetection() {
            let textBoxRequest = VNDetectTextRectanglesRequest(completionHandler: self.detectTextHandler)
            textBoxRequest.reportCharacterBoxes = true
            self.requests = [textBoxRequest]
        }
        
        //results of box detection and call of draing function
        func detectTextHandler(request: VNRequest, error: Error?) {
            guard let observations = request.results else {
                print("no result")
                return
            }
            
            let result = observations.map({$0 as? VNTextObservation})
            DispatchQueue.main.async() {
                self.imageView.layer.sublayers?.removeSubrange(1...)
                for region in result {
                    if let boxes = region?.characterBoxes {
                        for characterBox in boxes {
                            self.highlightLetters(box: characterBox)
                        }
                    }
                }
            }
        }
    
        // draw a box around the detected rectangle and add it to imageView
        func highlightLetters(box: VNRectangleObservation) {
            let x = box.topLeft.x * imageView.frame.size.width
            let y = (1 - box.topLeft.y) * imageView.frame.size.height
            let width = (box.topRight.x - box.bottomLeft.x) * imageView.frame.size.width
            let height = (box.topLeft.y - box.bottomLeft.y) * imageView.frame.size.height
            
            let outline = CALayer()
            outline.frame = CGRect(x: x, y: y, width: width, height: height)
            outline.borderWidth = 2.0
            outline.borderColor = UIColor.red.cgColor
            
            imageView.layer.addSublayer(outline)
        }
    }

    //video buffer for both requests
    extension ViewController_passwordCube: AVCaptureVideoDataOutputSampleBufferDelegate {
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }
            
            var requestOptions:[VNImageOption : Any] = [:]
            
            if let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
                requestOptions = [.cameraIntrinsics:camData]
            }
            
            //text box recognition with orientation
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 3)!, options: requestOptions)
            do {
                try imageRequestHandler.perform(self.requests)
            } catch {
                print(error)
            }
            
            //text recognition and interpretation with orientation
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 3)!, options: requestOptions)
            do {
                try handler.perform([textRecognitionRequest])
            } catch {
                  print(error)
            }
        }
    }


