//
//  ViewController.swift
//  Time Flies Beta
//
//  Created by George Sarantinos on 7/18/17.
//  Copyright © 2017 George Sarantinos. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer:CALayer!
    var captureDevice:AVCaptureDevice!
    
    var takePhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        prepareCamera()
    }
    
    func prepareCamera () {
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        if let availableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .back).devices {
            captureDevice = availableDevices.first
            beginSession()
            
        }
    }
    
    @IBOutlet weak var cameraButtonView: UIButton!
    @IBOutlet weak var folderButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    
    func postAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    var squares: [CAShapeLayer] = []
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self.view)
        
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: CGRect(x: location.x - 40, y: location.y - 40, width: 80, height: 80), cornerRadius: 50).cgPath
        layer.fillColor = nil
        layer.strokeColor = UIColor.yellow.cgColor
        view.layer.addSublayer(layer)
        
        if(squares.count >= 1) {
            squares[0].removeFromSuperlayer()
            squares.remove(at: 0)
        }
        
        squares.append(layer)
        
        if let device = captureDevice {
            do {
                device.unlockForConfiguration()
                try device.lockForConfiguration()
                
                device.focusPointOfInterest = location
                device.focusMode = .autoFocus
                device.exposurePointOfInterest = location
                device.exposureMode = .autoExpose
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                    device.unlockForConfiguration()
                    layer.removeFromSuperlayer()
                })
            }
            catch {
                
            }
        }
    }
    
    func beginSession () {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                for input in inputs {
                    captureSession.removeInput(input)
                }
            }
            
            captureSession.addInput(captureDeviceInput)
            
        } catch {
            print(error.localizedDescription)
        }
        
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.previewLayer = previewLayer
            self.view.layer.addSublayer(self.previewLayer)
            self.previewLayer.frame = self.view.layer.frame
            self.view.bringSubview(toFront:cameraButtonView)
            self.view.bringSubview(toFront: folderButton)
            self.view.bringSubview(toFront: switchCameraButton)
            
            captureSession.startRunning()
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String):NSNumber(value:kCVPixelFormatType_32BGRA)]
            
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput) {
                captureSession.addOutput(dataOutput)
            }
            
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.brianadvent.captureQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        takePhoto = true
    }
    
    @IBAction func goToTF(_ sender: Any) {
        
        let timeFlies = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "timeFliesVC") as! timeFliesViewController
        
        DispatchQueue.main.async {
            let transition = CATransition()
            transition.duration = 0.1
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.present(timeFlies, animated: false, completion: {
                self.stopCaptureSession()
            })
        }
    }
    
    
    @IBAction func goToVideoCamera(_ sender: Any) {
        let videoCamera = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "videoCameraVC") as! VideoViewController
        
        DispatchQueue.main.async {
            self.present(videoCamera, animated: false, completion: {
                self.stopCaptureSession()
            })
        }
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
    
        if takePhoto {
            takePhoto = false
            
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {

                let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoVC") as! PhotoViewController
                    
                photoVC.takenPhoto = image
                    
                DispatchQueue.main.async {
                    self.present(photoVC, animated: true, completion: {
                        self.stopCaptureSession()
                    })
                }
            }
        }
    }
    
    func getImageFromSampleBuffer(buffer:CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }
    
    func stopCaptureSession() {
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

