//
//  MainViewController.swift
//  VideoRecorderApp
//
//  Created by Aamir Shehzad on 11/10/2022.
//

import UIKit
import AVFoundation
import AssetsLibrary

class MainViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var recordOutlet: UIButton!
    @IBOutlet var recordLabel: UILabel!
    
    @IBOutlet var cameraView: UIView!
    var tempImage: UIImageView?
    
    private var session: AVCaptureSession = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var videoOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    private var audioOutput: AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()
    
   // private var videoDevice: AVCaptureDevice = AVCaptureDevice.default(for: .video) //AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    private var audioConnection: AVCaptureConnection?
    private var videoConnection: AVCaptureConnection?
    
    private var assetWriter: AVAssetWriter?
    private var audioInput: AVAssetWriterInput?
    private var videoInput: AVAssetWriterInput?
    
    private var fileManager: FileManager = FileManager()
    private var recordingURL: URL?
    
    private var isCameraRecording: Bool = false
    private var isRecordingSessionStarted: Bool = false
    
    private var recordingQueue = DispatchQueue(label: "recording.queue")
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var currentCaptureDevice: AVCaptureDevice?
    
    var usingFrontCamera = false
    
    /* This is the function i want to use to start
     recording a video */
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setup()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    /* This is the function i want to use to start
     recording a video */

    private func setup() {
        self.session.sessionPreset = AVCaptureSession.Preset.high
        
        self.recordingURL = URL(fileURLWithPath: "\(NSTemporaryDirectory() as String)/file.mov")
        if self.fileManager.isDeletableFile(atPath: self.recordingURL!.path) {
            _ = try? self.fileManager.removeItem(atPath: self.recordingURL!.path)
        }
        
        self.assetWriter = try? AVAssetWriter(outputURL: self.recordingURL!,
                                              fileType: AVFileType.mov)
        
        let audioSettings = [
            AVFormatIDKey : kAudioFormatAppleIMA4,
            AVNumberOfChannelsKey : 1,
            AVSampleRateKey : 16000.0
        ] as [String : Any]
        
        let videoSettings = [
            AVVideoCodecKey : AVVideoCodecH264,
            AVVideoWidthKey : UIScreen.main.bounds.size.width,
            AVVideoHeightKey : UIScreen.main.bounds.size.height
        ] as [String : Any]
        
        self.videoInput = AVAssetWriterInput(mediaType: AVMediaType.video,
                                             outputSettings: videoSettings)
        self.audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio,
                                             outputSettings: audioSettings)
        
        self.videoInput?.expectsMediaDataInRealTime = true
        self.audioInput?.expectsMediaDataInRealTime = true
        
        if self.assetWriter!.canAdd(self.videoInput!) {
            self.assetWriter?.add(self.videoInput!)
        }
        
        if self.assetWriter!.canAdd(self.audioInput!) {
            self.assetWriter?.add(self.audioInput!)
        }
        
        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
//           let input = AVCaptureDeviceInput(device: captureDevice)
//           session.addInput(input)
            self.deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        }
        
        if let deviceInputt = self.deviceInput {
            if self.session.canAddInput(deviceInputt) {
                self.session.addInput(deviceInputt)
            }
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        
        let rootLayer = self.view.layer
        rootLayer.masksToBounds = true
        self.previewLayer?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        let statusBarOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        let videoOrientation: AVCaptureVideoOrientation = statusBarOrientation?.videoOrientation ?? .landscapeRight
        //videoPreviewLayer.frame = view.layer.bounds
        self.previewLayer?.connection?.videoOrientation = videoOrientation
       // videoPreviewLayer.removeAllAnimations()
        
        rootLayer.insertSublayer(self.previewLayer!, at: 0)
        
        self.session.startRunning()
        
        DispatchQueue.main.async {
            self.session.beginConfiguration()
            
            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
            }
            
            self.videoConnection = self.videoOutput.connection(with: AVMediaType.video)
            if self.videoConnection?.isVideoStabilizationSupported == true {
                self.videoConnection?.preferredVideoStabilizationMode = .auto
            }
            self.session.commitConfiguration()
            
            if let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio) {
                //           let input = AVCaptureDeviceInput(device: captureDevice)
                //           session.addInput(input)
                //let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
                
                if let audioIn = try? AVCaptureDeviceInput(device: audioDevice) {
                    
                    if self.session.canAddInput(audioIn) {
                        self.session.addInput(audioIn)
                    }
                }
                
                if self.session.canAddOutput(self.audioOutput) {
                    self.session.addOutput(self.audioOutput)
                }
                
            }
            
            
           
            self.audioConnection = self.audioOutput.connection(with: AVMediaType.audio)
            
        }
    }
    
    private func startRecording() {
        if self.assetWriter?.startWriting() != true {
            print("error: \(self.assetWriter?.error.debugDescription ?? "")")
        }
        
        self.videoOutput.setSampleBufferDelegate(self, queue: self.recordingQueue)
        self.audioOutput.setSampleBufferDelegate(self, queue: self.recordingQueue)
    }
    
    private func stopRecording() {
        self.videoOutput.setSampleBufferDelegate(nil, queue: nil)
        self.audioOutput.setSampleBufferDelegate(nil, queue: nil)
        
        self.assetWriter?.finishWriting {
            print("saved")
        }
    }
    
    @IBAction func recordingButton(_ sender: Any) {
        if self.isCameraRecording {
            self.stopRecording()
        } else {
            self.startRecording()
        }
        self.isCameraRecording = !self.isCameraRecording
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer
                       sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        if !self.isRecordingSessionStarted {
            let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            self.assetWriter?.startSession(atSourceTime: presentationTime)
            self.isRecordingSessionStarted = true
        }
        
        let description = CMSampleBufferGetFormatDescription(sampleBuffer)!
        
        if CMFormatDescriptionGetMediaType(description) == kCMMediaType_Audio {
            if self.audioInput!.isReadyForMoreMediaData {
                print("appendSampleBuffer audio");
                self.audioInput?.append(sampleBuffer)
            }
        } else {
            if self.videoInput!.isReadyForMoreMediaData {
                print("appendSampleBuffer video");
                if !self.videoInput!.append(sampleBuffer) {
                    print("Error writing video buffer");
                }
            }
        }
    }
    
    /*
     // Method: goToSelectDurationViewController
     // Description: Method to go to Select Duration View Controller
     */
    func goToSelectDurationViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let objVC = storyboard.instantiateViewController(withIdentifier: "SelectDurationViewController") as? SelectDurationViewController
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        if let aController = objVC {
            navigationController?.pushViewController(aController, animated: true)
        }
    }
    
    // MARK: - IBAction Methods
    
    /*
     // Method: onBtnSignup
     // Description: IBAction for signup button
     */
    @IBAction func onBtnBackWordArrow(_ sender: Any) {
        self.goToSelectDurationViewController()
    }
    
    
}

extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        case .portrait: return .portrait
        default: return nil
        }
    }
}
