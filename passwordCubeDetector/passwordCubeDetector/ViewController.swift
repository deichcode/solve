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

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var first_letter_label: UILabel!
    @IBOutlet weak var second_letter_label: UILabel!
    @IBOutlet weak var third_letter_label: UILabel!
    @IBOutlet weak var fourth_letter_label: UILabel!
    
    
    @IBOutlet weak var password_field_image: UIImageView!
    @IBOutlet weak var first_letter_image: UIImageView!
    @IBOutlet weak var second_letter_image: UIImageView!
    @IBOutlet weak var third_letter_image: UIImageView!
    @IBOutlet weak var fourth_letter_image: UIImageView!
    
    var session = AVCaptureSession()
    var requests = [VNRequest]()
    
    var textRecognitionRequest = VNRecognizeTextRequest()
    var recognizedText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let password_field = UIImage(named: "image_password_field.png")
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
    
    func selectDevice() -> AVCaptureDevice{
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video, position: .front) {
            return device
        } else {
            fatalError("Missing front camera")
        }
    }
    func startLiveVideo() {
            //1
            session.sessionPreset = AVCaptureSession.Preset.photo
            let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
            
            //2
        let deviceInput = try! AVCaptureDeviceInput(device: selectDevice())
            let deviceOutput = AVCaptureVideoDataOutput()
            
            
            deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
            session.addInput(deviceInput)
            session.addOutput(deviceOutput)
            
            
            //3
            let imageLayer = AVCaptureVideoPreviewLayer(session: session)
            imageLayer.frame = imageView.bounds
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
                        for observation in requestResults {
                            guard let candidiate = observation.topCandidates(1).first else { return }
                              self.recognizedText += candidiate.string
                            self.recognizedText += "\n"
                        }
                       print(self.recognizedText)
                        if self.recognizedText.contains("O") {
                            DispatchQueue.main.async {
                            self.first_letter_label.text = "O"
                            let letter_image = UIImage(named: "image_o.png")
                            self.first_letter_image.image = letter_image
                            }
                        }
                        if self.recognizedText.contains("P") {
                            DispatchQueue.main.async {
                            self.second_letter_label.text = "P"
                            let letter_image = UIImage(named: "image_p.png")
                            self.second_letter_image.image = letter_image
                            }
                        }
                        if self.recognizedText.contains("E") {
                            DispatchQueue.main.async {
                            self.third_letter_label.text = "E"
                            let letter_image = UIImage(named: "image_e.png")
                            self.third_letter_image.image = letter_image
                            }
                        }
                        if self.recognizedText.contains("N") {
                            DispatchQueue.main.async {
                            self.fourth_letter_label.text = "N"
                            let letter_image = UIImage(named: "image_n.png")
                            self.fourth_letter_image.image = letter_image
                            }
                        }
                        DispatchQueue.main.async {
                            if self.first_letter_label.text == "O" && self.second_letter_label.text == "P" && self.third_letter_label.text == "E" && self.fourth_letter_label.text == "N" {
                                // create the alert
                                let alert = UIAlertController(title: "Sucess", message: "You solved the puzzle", preferredStyle: UIAlertController.Style.alert)

                                // add the actions (buttons)
                                alert.addAction(UIAlertAction(title: "Next...", style: UIAlertAction.Style.default, handler: nil))
                                // show the alert
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            })
            textRecognitionRequest.recognitionLevel = .accurate
        }
        
        func startTextboxDetection() {
            let textBoxRequest = VNDetectTextRectanglesRequest(completionHandler: self.detectTextHandler)
            textBoxRequest.reportCharacterBoxes = true
            self.requests = [textBoxRequest]
        }
        
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

        func highlightLetters(box: VNRectangleObservation) {
            let x = box.topLeft.x * imageView.frame.size.width
            let y = (1 - box.topLeft.y) * imageView.frame.size.height
            let width = (box.topRight.x - box.bottomLeft.x) * imageView.frame.size.width
            let height = (box.topLeft.y - box.bottomLeft.y) * imageView.frame.size.height
            
            let outline = CALayer()
            outline.frame = CGRect(x: x, y: y, width: width, height: height)
            outline.borderWidth = 1.0
            outline.borderColor = UIColor.red.cgColor
            
            imageView.layer.addSublayer(outline)
        }
    }

    extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }
            
            var requestOptions:[VNImageOption : Any] = [:]
            
            if let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
                requestOptions = [.cameraIntrinsics:camData]
            }
            
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
            
            do {
                try imageRequestHandler.perform(self.requests)
            } catch {
                print(error)
            }
            
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
              do {
                  try handler.perform([textRecognitionRequest])
              } catch {
                  print(error)
              }
            
        }
    }


