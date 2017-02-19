//
//  CameraService.swift
//  Service
//
//  Created by Kapam6a on 18.02.17.
//  Copyright © 2017 Kapam6a. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraService {
    func getCameraLayer() -> CALayer!
    func requestImage(completionHandler handler : (NSData!, NSError!) -> Void) -> Void
}

class BackCameraService : NSObject, CameraService {
    private var session : AVCaptureSession!
    private var input : AVCaptureDeviceInput!
    private var output : AVCaptureStillImageOutput!
    private var device : AVCaptureDevice!
    private var previewLayer : CALayer!
    
    override init() {
        super.init()
        configureSession()
    }
    
    func getCameraLayer() -> CALayer! {
        return previewLayer
    }
    
    func requestImage(completionHandler handler : (NSData!, NSError!) -> Void) -> Void {
        if let videoConnection = output.connectionWithMediaType(AVMediaTypeVideo) {
            output.captureStillImageAsynchronouslyFromConnection(videoConnection) {(imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                DispatchQueue.main.async {
                    handler(imageData, error)
                }
            }
        }
    }
    
    // MARK: Helpers
    private func configureSession(){
        device =  AVCaptureDevice.devices().filter({ $0.position == .Back }).first as! AVCaptureDevice
        
        input = try! AVCaptureDeviceInput(device: device)
        
        output = AVCaptureStillImageOutput()
        
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetPhoto
        session.addOutput(output)
        session.addInput(input)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        session.startRunning()
    }
}
