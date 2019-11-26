//
//  ViewController.swift
//  FRS
//
//  Created by Richard Zheng on 11/12/19.
//  Copyright © 2019 Richard Zheng. All rights reserved.
//

import UIKit
import AVFoundation




class ViewController: UIViewController {
  @IBOutlet weak var previewView: UIView!
  @IBOutlet weak var snap: UIButton!
  
  var captureSession: AVCaptureSession?
  var videoPreviewLayer: AVCaptureVideoPreviewLayer?
  
  var capturePhotoOutput: AVCapturePhotoOutput?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    snap.frame = CGRect(x: 136, y: 690, width: 90, height: 90)
    snap.layer.cornerRadius = 0.5 * snap.bounds.size.width
    
    
    snap.clipsToBounds = true
    
    // Sets to front facing camera.
    guard let captureDevice = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video,
                                                      position: .front)
      else { fatalError("whoops") }
    
    do {
      let input = try AVCaptureDeviceInput(device: captureDevice)
      
      captureSession = AVCaptureSession()
      captureSession?.addInput(input)
      
      videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
      videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
      videoPreviewLayer?.frame = view.layer.bounds
      previewView.layer.addSublayer(videoPreviewLayer!)
      
      
      
      // Get an instance of ACCapturePhotoOutput class
      capturePhotoOutput = AVCapturePhotoOutput()
      capturePhotoOutput?.isHighResolutionCaptureEnabled = true
      captureSession?.addOutput(capturePhotoOutput!)

      
      captureSession?.startRunning()
    } catch {
        print(error)
        return
    }
  }
  
  @IBAction func takePic(_ sender: Any) {
    guard let capturePhotoOutput = self.capturePhotoOutput else { return }
    
    
    let photoSettings = AVCapturePhotoSettings()
    
    //still images:
    photoSettings.isAutoStillImageStabilizationEnabled = true
    //photoSettings.isAutoStillImageStabilizationEnabled = self.capturePhotoOutput!.isStillImageStabilizationSupported
    photoSettings.isHighResolutionPhotoEnabled = true
    photoSettings.flashMode = .auto
    
    capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self) //needs the extension below to work
  }
  
}

extension ViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                 didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                 previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                 resolvedSettings: AVCaptureResolvedPhotoSettings,
                 bracketSettings: AVCaptureBracketedStillImageSettings?,
                 error: Error?) {
        // if we dont have a photo buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
            return
        }
        
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
            // Saves
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}
