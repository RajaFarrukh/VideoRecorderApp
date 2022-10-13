//
//  MainViewController.swift
//  VideoRecorderApp
//
//  Created by Aamir Shehzad on 11/10/2022.
//

import UIKit
import AVFoundation
import AssetsLibrary
import MobileCoreServices
import AVKit
import Photos


class MainViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, UIGestureRecognizerDelegate {
    
    let videoPickerController = UIImagePickerController()
    var isVideoRecordingStart:Bool = false
    var capturedVideoURL:URL? = nil
    var timer = Timer()
    var timerForClip = Timer()
    var counter = 0
    var recordingSlot = 4
    var videoTimeInSec = 4
    
    @IBOutlet var startStopButton: UIButton!
    @IBOutlet var videoPickerControllerView: UIView!
    @IBOutlet var videoTimerLabel: UILabel!
    @IBOutlet var clipTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // self.setup()
        self.createAlbum()
        self.clipTimeLabel.isHidden = true
        self.clipTimeLabel.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.cameraViewAction()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func cameraViewAction() {
        videoPickerController.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            DispatchQueue.main.async {
                //OptiToast.showNegativeMessage(message: OptiConstant().cameranotavailable)
                //
            }
            return
        }
        videoPickerController.allowsEditing = true
        videoPickerController.sourceType = .camera
        videoPickerController.mediaTypes = [kUTTypeMovie as String]
        videoPickerController.videoMaximumDuration = TimeInterval(240.0)
        videoPickerController.cameraCaptureMode = .video
        videoPickerController.modalPresentationStyle = .overCurrentContext//.fullScreen
        
        addChild(videoPickerController)
        self.videoPickerControllerView.addSubview(videoPickerController.view)
        videoPickerController.view.frame = self.videoPickerControllerView.bounds
        videoPickerController.allowsEditing = false
        videoPickerController.showsCameraControls = false
        
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
    
    func startStopRecording() {
        if isVideoRecordingStart {
            isVideoRecordingStart = false
            self.videoPickerController.stopVideoCapture()
            counter = 0
            timer.invalidate()
            self.startStopButton.setTitle("Start", for: .normal)
            self.startStopButton.backgroundColor = AppUtility.hexColor(hex: "2E6A1F")
        } else {
            isVideoRecordingStart = true
            self.videoPickerController.startVideoCapture()
            self.startStopButton.setTitle("Stop", for: .normal)
            self.startStopButton.backgroundColor = UIColor.red
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }
    
    // called every time interval from the timer
    @objc func timerAction() {
        counter += 1
        let timerFormatedTime = self.secondsToHoursMinutesSeconds(counter)
        self.videoTimerLabel.text = "\(timerFormatedTime.hours):\(timerFormatedTime.minutes):\(timerFormatedTime.seconds)"
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (hours:Int, minutes:Int, seconds:Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    // called every time interval from the timer
    @objc func timerActionForClip() {
        recordingSlot -= 1
        if recordingSlot < 0 {
            self.timerForClip.invalidate()
            clipTimeLabel.isHidden = true
            self.startStopRecording()
            self.clipTimeLabel.text = ""
            self.startStopRecording()
            self.startStopRecording()
        } else {
            self.clipTimeLabel.isHidden = false
            self.clipTimeLabel.text = "\(recordingSlot)"
        }
    }
    
    func export(_ asset: AVAsset, to outputMovieURL: URL, startTime: CMTime, endTime: CMTime, composition: AVVideoComposition) {

        //Create trim range
      let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)

        //delete any old file
      do {
        try FileManager.default.removeItem(at: outputMovieURL)
      } catch {
        print("Could not remove file \(error.localizedDescription)")
      }

        //create exporter
      let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)

        //configure exporter
      exporter?.videoComposition = composition
      exporter?.outputURL = outputMovieURL
      exporter?.outputFileType = .mov
      exporter?.timeRange = timeRange

        //export!
      exporter?.exportAsynchronously(completionHandler: { [weak exporter] in
        DispatchQueue.main.async {
          if let error = exporter?.error {
            print("failed \(error.localizedDescription)")
          } else {
            print("Video saved to \(outputMovieURL)")
          }
        }
      })
    }
    
    func secondsFromString (string: String) -> Int {
        let components: Array = string.components(separatedBy: ":")
        let hours = Int(components[0] ) ?? 0
        let minutes = Int(components[1] ) ?? 0
        let seconds = Int(components[2] ) ?? 0
        return Int(((hours * 60) * 60) + (minutes * 60) + seconds)
    }
    
    // MARK: - IBAction Methods
    
    /*
     // Method: onBtnSignup
     // Description: IBAction for signup button
     */
    @IBAction func onBtnBackWordArrow(_ sender: Any) {
        self.goToSelectDurationViewController()
    }
    
    /*
     // Method: onBtnSignup
     // Description: IBAction for signup button
     */
    @IBAction func onBtnStartRecording(_ sender: Any) {
        self.startStopRecording()
    }
    
    @IBAction func onBtnMakes(_ sender: Any) {
        timerForClip = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerActionForClip), userInfo: nil, repeats: true)
    }
    
}

//MARK : UIImagePicker Delegate
extension MainViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        print(videoURL)
        capturedVideoURL = videoURL
        
        if let cVideoURL = self.capturedVideoURL {
            let currentTime = self.videoTimerLabel.text ?? "0:0:0" // hh:mm:ss
            
            let currentTimeInSec = self.secondsFromString(string: currentTime)
            
            let startSec = Float64(currentTimeInSec - 4)
            let endSec = Float64(currentTimeInSec + 4)
            
            let smallValue =  0.0401588716
            let startSecCMTime =      CMTimeMakeWithSeconds(startSec, preferredTimescale: 1)
            let startTimeInCM =   CMTimeMultiplyByFloat64(startSecCMTime , multiplier: smallValue)
            print(CMTimeGetSeconds(startTimeInCM))
            
            let endSecCMTime =      CMTimeMakeWithSeconds(endSec, preferredTimescale: 1)
            let endTimeInCM =   CMTimeMultiplyByFloat64(endSecCMTime , multiplier: smallValue)
            print(CMTimeGetSeconds(endTimeInCM))
            let asset = AVAsset(url: cVideoURL)
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", "VIdeoClipss")
            let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            print("collections")
            collections.
            
          
            //self.export(asset, to: URL(string: galleryPath), startTime: startSecCMTime, endTime: endTimeInCM, composition: composition)
           
            print("Done")
        }
        
        //videoTimeInSec
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "VIdeoClipss")   // create an asset collection with the album name
        }) { success, error in
            if success {
              
            } else {
                print("error \(error)")
            }
        }
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
 
