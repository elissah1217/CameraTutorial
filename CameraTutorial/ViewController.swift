//
//  ViewController.swift
//  CameraTutorial
//
//  Created by Jean-Francois Demers on 2015-02-19.
//  Copyright (c) 2015 JFDSoft. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var startView: UIView!
    var stillImageOutput: AVCaptureStillImageOutput?
    
    
    @IBOutlet weak var capturedImage: UIImageView!
    
    
    var selectedDevice: AVCaptureDevice? = nil;
    let captureSession = AVCaptureSession();
    var previewLayer: AVCaptureVideoPreviewLayer? = nil;
    var observer:NSObjectProtocol? = nil;
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        stillImageOutput = AVCaptureStillImageOutput()
        selectedDevice = findCameraWithPosition(.Front);
        startCapture();
        

        processOrientationNotifications();
        self.view.addSubview(startView)
        self.view.addSubview(capturedImage)

    }

    deinit {
        // Cleanup
        if observer != nil {
            NSNotificationCenter.defaultCenter().removeObserver(observer!);
        }
        
        UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications();
            }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func findCameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo);
        for device in devices as! [AVCaptureDevice] {
            if(device.position == position) {
                println(device.hasMediaType(AVMediaTypeVideo))
                return device;
            }
        }
        
        return nil;
    }
    
    func startCapture() {
        if let device = selectedDevice {
            var err : NSError? = nil
            captureSession.addInput(AVCaptureDeviceInput(device: device, error: &err))
            
            if err != nil {
                println("error: \(err?.localizedDescription)")
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.view.layer.addSublayer(previewLayer)
            previewLayer?.frame = self.view.layer.frame;
            captureSession.startRunning()
            
//            if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
//                
//            }
            
            
        }
    }
    
    
    
    
    
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator);
        if let layer = previewLayer {
            layer.frame = CGRectMake(0,0,size.width, size.height);
        }
    }
    
    func processOrientationNotifications() {
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications();
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIDeviceOrientationDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [unowned self](notification: NSNotification!) -> Void in
            if let layer = self.previewLayer {
                switch UIDevice.currentDevice().orientation {
                case .LandscapeLeft: layer.connection.videoOrientation = .LandscapeRight;
                case .LandscapeRight: layer.connection.videoOrientation = .LandscapeLeft;
                default: layer.connection.videoOrientation = .Portrait;
                }
            }
        }
    }
    
    
    
    
    
    
    
    @IBAction func didPressTakePhoto(sender: AnyObject) {
        println("take photo")
        //stillImageOutput = AVCaptureStillImageOutput()

        
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            

            //videoConnection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    var dataProvider = CGDataProviderCreateWithCFData(imageData)
                    var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, kCGRenderingIntentDefault)
                    
                    var image = UIImage(CGImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.Right)
                    self.capturedImage.image = image
                    println(self.capturedImage.frame.size)
                }
            })
        }
    }
    
    @IBAction func didPressTakeAnother(sender: AnyObject) {
        captureSession.startRunning()
    }

    
    
    
}

