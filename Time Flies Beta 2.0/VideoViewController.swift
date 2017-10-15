//
//  VideoViewController.swift
//  Time Flies Beta
//
//  Created by George Sarantinos on 7/25/17.
//  Copyright © 2017 George Sarantinos. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia

class VideoViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var switchCamera: UIButton!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var switchToPicture: UIButton!
    
    let caputureSession = AVCaptureSession()
    var videoCaptureDevice:AVCaptureDevice?
    var previewLayer:AVCaptureVideoPreviewLayer?
    var movieFileOutput = AVCaptureMovieFileOutput()
    var outputFileLocation:URL?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCamera()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let layer = CAShapeLayer()
    
    override func viewWillLayoutSubviews() {
        self.setVideoOrientation()
    }
    
    @IBAction func backToPictureCamera(_ sender: Any) {
        self.caputureSession.stopRunning()
        self.dismiss(animated: false, completion: nil)
    }    
    
    @IBAction func startRecording(_ sender: Any) {
        if self.movieFileOutput.isRecording {
            self.movieFileOutput.stopRecording()
            layer.removeFromSuperlayer()
            switchCamera.isEnabled = true
            self.view.bringSubview(toFront: switchCamera)
            
        } else {
            self.movieFileOutput.connection(withMediaType: AVMediaTypeVideo).videoOrientation = self.videoOrientation()
            self.movieFileOutput.maxRecordedDuration = self.maxRecordTime()
            
            self.movieFileOutput.startRecording(toOutputFileURL: URL(fileURLWithPath: self.videoFileLocation()), recordingDelegate: self)
            
            layer.path = UIBezierPath(roundedRect: CGRect(x: 330, y: 80, width: 15, height: 15), cornerRadius: 50).cgPath
            layer.fillColor = UIColor.red.cgColor
            layer.strokeColor = UIColor.red.cgColor
            view.layer.addSublayer(layer)
            
            switchCamera.isEnabled = false
            self.view.sendSubview(toBack: switchCamera)
        }
    }
    
    func cameraWithPosition(position:AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified) as AVCaptureDeviceDiscoverySession
        
        for device in devices.devices as [AVCaptureDevice] {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    
    @IBAction func switchCameraFunc(_ sender: Any) {
        self.caputureSession.beginConfiguration()
        
        var currentCamera:AVCaptureDeviceInput!
        
        for connection in self.caputureSession.inputs {
            let input = connection as! AVCaptureDeviceInput
            if input.device.hasMediaType(AVMediaTypeVideo) {
                currentCamera = input
            }
        }
        
        self.caputureSession.removeInput(currentCamera)
        
        var newCamera:AVCaptureDevice!
        
        if let oldCamera = currentCamera {
            if oldCamera.device.position == .back {
                newCamera = self.cameraWithPosition(position: .front)
            } else {
                newCamera = self.cameraWithPosition(position: .back)
            }
        }
        
        var newInput:AVCaptureDeviceInput!
        
        do {
            newInput = try AVCaptureDeviceInput(device: newCamera)
            self.caputureSession.addInput(newInput)
        } catch {
            print(error)
        }
        
        self.caputureSession.commitConfiguration()
    }
    
    func setVideoOrientation() {
        if let connection = self.previewLayer?.connection {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = self.videoOrientation()
                self.previewLayer?.frame = self.view.bounds
            }
        }
    }
    
    func setupCamera() {
        self.caputureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDeviceDiscoverySession.init(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified) as AVCaptureDeviceDiscoverySession
        
        for device in devices.devices as [AVCaptureDevice] {
            if device.hasMediaType(AVMediaTypeVideo) {
                if device.position == AVCaptureDevicePosition.back {
                    self.videoCaptureDevice = device
                }
            }
        }
        
        if videoCaptureDevice != nil {
            do {
                try self.caputureSession.addInput(AVCaptureDeviceInput(device: self.videoCaptureDevice))
                
                if let audioInput = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio) {
                    try self.caputureSession.addInput(AVCaptureDeviceInput(device: audioInput))
                }
                
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.caputureSession)
                
                self.previewView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                
                self.previewView.layer.addSublayer(self.previewLayer!)
                self.previewLayer?.frame = self.previewView.frame
                
                self.setVideoOrientation()
                
                self.caputureSession.addOutput(self.movieFileOutput)
                
                self.view.bringSubview(toFront: recordButton)
                self.view.bringSubview(toFront: switchCamera)
                self.view.bringSubview(toFront: switchToPicture)
                
                self.caputureSession.startRunning()
                
                
            } catch {
                print(error)
            }
        }
        
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        print("Finished Recording: \(outputFileURL)")
    
        self.outputFileLocation = outputFileURL
        
        let watchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "videoWatchVC") as! VideoWatchViewController
        
        watchVC.urlName = outputFileURL
        
        DispatchQueue.main.async {
            self.present(watchVC, animated: true, completion: nil)
        }
    }
    
    func videoOrientation() -> AVCaptureVideoOrientation! {
        
        var videoOrientation:AVCaptureVideoOrientation!
        
        let orientation:UIDeviceOrientation = UIDevice.current.orientation
        
        switch orientation {
        case .portrait:
            videoOrientation = .portrait
            break
        case .landscapeRight:
            videoOrientation = .landscapeLeft
            break
        case .landscapeLeft:
            videoOrientation = .landscapeRight
            break
        case .portraitUpsideDown:
            videoOrientation = .portrait
            break
        default:
            videoOrientation = .portrait
        }
        
        return videoOrientation
    }
    

    func videoFileLocation() -> String {
        return NSTemporaryDirectory().appending("videoFile.mov")
    }
    
    func maxRecordTime() -> CMTime {
        let seconds:Int64 = 20
        let preferredTimeScale:Int32 = 1
        return CMTimeMake(seconds, preferredTimeScale)
    }

    // MARK: - Navigation

    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let preview = segue.destination as! VideoWatchViewController
      //  preview.fileLocation = self.outputFileLocation
    //}
}
