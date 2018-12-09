//
//  CameraViewController.swift
//  ImageLabeling
//
//  Created by Kanta'MacPro on 5/12/2561 BE.
//  Copyright © 2561 Kanta'MacPro. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import Firebase

class CameraViewController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var tipbar: UIImageView!
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var previewPhoto: UIImageView!
    @IBOutlet weak var resultText: UITextView!
    @IBOutlet weak var visualUIview: UIImageView!
    
    //@IBOutlet weak var visualView: UIVisualEffectView!
    let config = VisionCloudDetectorOptions()
    
    lazy var vision = Vision.vision()
    //let labelDetector = vision.labelDetector(options: )
    
    let picker = UIImagePickerController()
    
    //Camera
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    let cameraImage = UIImage(named: "cameraIMG")
    let clockImage = UIImage(named: "clockIMG")
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // let config = VisionLabelDetectorOptions(confidenceThreshold: 0.5)
        config.maxResults = 30
        let labelDetector = vision.cloudLabelDetector(options: config)
       // assignBackGround()
        visualUIview.image = UIImage(named: "BackGroundIMG")
        cameraIcon.image = cameraImage
        picker.delegate = self
        //Custom Camera
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    private func assignBackGround() {
        let background = UIImage(named: "BackGroundIMG")
        let imageView = visualUIview
        imageView!.contentMode = UIView.ContentMode.scaleAspectFill
        imageView!.clipsToBounds = true
        imageView!.image = background
        //imageView!.center = view.
        view.addSubview(imageView!)
        self.view.sendSubviewToBack(imageView!)
    }
    
    @IBAction func ImagePicker(_ sender: Any) {
        picker.sourceType = .photoLibrary
        previewPhoto.isHidden = false
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func cancelMethod(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func captureAction(_ sender: Any) {
        cameraIcon.image = clockImage
        previewPhoto.isHidden = false
        sleep(2)
        let settings = AVCapturePhotoSettings()
        settings.flashMode = AVCaptureDevice.FlashMode.off
        photoOutput?.capturePhoto(with: settings, delegate: self)
        print("Captured!")
    }
    @IBAction func activatePreviewCamera(_ sender: Any) {
        print("cameraIcon Tapped!")
        previewPhoto.isHidden = true
    }
    
    
    func setupCaptureSession(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    func setupDevice(){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in  devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front{
                frontCamera = device
            }
        }
        currentCamera = backCamera
    }
    func setupInputOutput(){
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print("error")
            
        }
        
    }
    func setupPreviewLayer(){
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
        // cameraPreviewLayer?.frame = previewView.frame
        //  previewView.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CameraViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let imageData = photo.fileDataRepresentation()
        let image = UIImage(data: imageData!)
        previewPhoto.image = image
        labelImage(image: image!)
        cameraIcon.image = cameraImage
        
    }
}

//Detect api
// MARK: ML Kit label detect
extension CameraViewController {
    func labelImage(image : UIImage){
        let labelDetector = vision.labelDetector()
        let visionImage = VisionImage(image: image)
        labelDetector.detect(in: visionImage){ (labels, error) in
            guard error == nil , let labels = labels, !labels.isEmpty else {
              //  self.showError(errorMessage: error?.localizedDescription ?? "Something went wrong")
                return
            }
            let result = labels.map({
                return "\($0.label) : \($0.confidence)"
            }).joined(separator: "\n")
            self.resultText.text = result
         //   self.showResultScreen(image: image, resultString: result)
        }
    }
}

//MARK: UIImagePickerController's delegate
extension CameraViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
   @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            self.previewPhoto.image = image
            self.labelImage(image: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
