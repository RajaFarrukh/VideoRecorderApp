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
    var arrayTags:[TagStruct] = []
    var selectedTag:TagStruct? = nil
    var isSavedVideo:Bool = false
    
    @IBOutlet var startStopButton: UIButton!
    @IBOutlet var videoPickerControllerView: UIView!
    @IBOutlet var videoTimerLabel: UILabel!
    @IBOutlet var clipTimeProgressView: UIProgressView!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // self.setup()
       // self.createAlbum()
        
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.cameraViewAction()
        self.arrayTags = AppUtility.retriveTagArray() //AppUtility.getDefaultTags()
        //        let tagArray = AppUtility.retriveTagArray()
        //        self.arrayTags.append(contentsOf: tagArray)
        self.reloadTagCollectionView()
        
        self.clipTimeProgressView.progress = 0.0
        let sloteValue = UserDefaults.standard.integer(forKey: "stop")
        
        if sloteValue > 0 {
            self.recordingSlot = sloteValue
            self.videoTimeInSec = sloteValue
        } else {
            self.recordingSlot = 4
            self.videoTimeInSec = 4
        }
        
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
    
    // MARK: - Other Methods
    
    /*
     // Method: setupView
     // Description: Method uset to setup page initially
     */
    func setupView() {
        self.clipTimeProgressView.isHidden = true
        self.clipTimeProgressView.progress = 0
        
        let nibName = UINib(nibName: "TagCollectionViewCell", bundle:nil)
        self.tagsCollectionView.register(nibName, forCellWithReuseIdentifier: "TagCell")
        
    }
    
    /*
     // Method: reloadTagCollectionView
     // Description: Method uset to reload tag collection view
     */
    func reloadTagCollectionView() {
        self.tagsCollectionView.delegate = self
        self.tagsCollectionView.dataSource = self
        self.tagsCollectionView.reloadData()
    }
    
    /*
     // Method: cameraViewAction
     // Description: Method uset for camera view action
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
        videoPickerController.cameraFlashMode = .off
        
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
    
    /*
     // Method: goToCreateTagViewController
     // Description: Method to go to Create Tag View Controller
     */
    func goToCreateTagViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let objVC = storyboard.instantiateViewController(withIdentifier: "CreateTagViewController") as? CreateTagViewController
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        if let aController = objVC {
            navigationController?.pushViewController(aController, animated: true)
        }
    }
    
    /*
     // Method: startStopRecording
     // Description: Method used to start stop recording
     */
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
    
    /*
     // Method: secondsToHoursMinutesSeconds
     // Description: Method used to convert seconds To Hours Minutes Seconds
     */
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (hours:Int, minutes:Int, seconds:Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    /*
     // Method: export
     // Description: Method used to export video
     */
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
    
    /*
     // Method: secondsFromString
     // Description: Method used to get seconds from string
     */
    func secondsFromString (string: String) -> Int {
        let components: Array = string.components(separatedBy: ":")
        let hours = Int(components[0] ) ?? 0
        let minutes = Int(components[1] ) ?? 0
        let seconds = Int(components[2] ) ?? 0
        return Int(((hours * 60) * 60) + (minutes * 60) + seconds)
    }
    
    /*
     // Method: cropVideo
     // Description: Method used to crop video
     */
    func cropVideo(sourceURL1: URL, statTime:Float, endTime:Float) {
        let manager = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
        let mediaType = "mp4"
        if mediaType == kUTTypeMovie as String || mediaType == "mp4" as String {
            let asset = AVAsset(url: sourceURL1 as URL)
            let length = Float(asset.duration.value) / Float(asset.duration.timescale)
            print("video length: \(length) seconds")
            
            let start = statTime
            let end = endTime
            var videoName = ""
            if let tag = self.selectedTag {
                videoName = tag.title
            } else {
                videoName = "videoClip"
            }
            
            var outputURL = documentDirectory.appendingPathComponent("VideoClips")
            do {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                outputURL = outputURL.appendingPathComponent("\(UUID().uuidString)-\(videoName).\(mediaType)")
            }catch let error {
                print(error)
            }
            
            //Remove existing file
            _ = try? manager.removeItem(at: outputURL)
            
            
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            
            let startTime = CMTime(seconds: Double(start ), preferredTimescale: 1000)
            let endTime = CMTime(seconds: Double(end ), preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    print("exported at \(outputURL)")
                    if self.isSavedVideo == false {
                        self.isSavedVideo = true
                        self.saveVideoToAlbum(outputURL) { Error in
                            ///
                        }
                    }
                case .failed:
                    print("failed \(exportSession.error)")
                case .cancelled:
                    print("cancelled \(exportSession.error)")
                default: break
                }
            }
        }
    }
    
    /*
     // Method: requestAuthorization
     // Description: Mthods to request authorization
     */
    func requestAuthorization(completion: @escaping ()->Void) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else if PHPhotoLibrary.authorizationStatus() == .authorized{
            completion()
        }
    }
    
    /*
     // Method: saveVideoToAlbum
     // Description: Mthods to save video to album
     */
//    func saveVideoToAlbum(_ outputURL: URL, _ completion: ((Error?) -> Void)?) {
//        requestAuthorization {
//
//            let fetchOptions = PHFetchOptions()
//            fetchOptions.predicate = NSPredicate(format: "title = %@", "VideoClips")
//            let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
//            let firstobj = collection.firstObject
//
//            if let assetCollection = collection.firstObject {
//
//                PHPhotoLibrary.shared().performChanges({
//                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
//                    if let assetPlaceholder = assetChangeRequest?.placeholderForCreatedAsset {
//                        let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection)
//                        albumChangeRequest?.addAssets([assetPlaceholder] as NSFastEnumeration)
//                    }
//                }){ (result, error) in
//                    DispatchQueue.main.async {
//                        if let error = error {
//                            print(error.localizedDescription)
//                        } else {
//                            print("Saved successfully")
//                        }
//                        self.selectedTag = nil
//                        self.reloadTagCollectionView()
//                        completion?(error)
//                    }
//                }
//
//            }
//        }
//    }

    func saveVideoToAlbum(_ outputURL: URL, _ completion: ((Error?) -> Void)?) {
            requestAuthorization {
                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(with: .video, fileURL: outputURL, options: nil)
                }) { (result, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            print("Saved successfully")
                        }
                        self.selectedTag = nil
                        self.reloadTagCollectionView()
                        completion?(error)
                    }
                }
            }
        }
    
    /*
     // Method: deleteTag
     // Description: Mthods to delete tag
     // Params: index:Int
     */
    func deleteTag(index:Int) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Conformation Required!", message: "Are you sure you want to delete the tag.", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("Delete Pressed")
            
            self.arrayTags.remove(at: index)
            AppUtility.saveTagArray(tagArray: self.arrayTags)
            self.arrayTags = AppUtility.retriveTagArray()
            self.reloadTagCollectionView()
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
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
     // Method: onBtnCreateTag
     // Description: IBAction for create tag
     */
    @IBAction func onBtnCreateTag(_ sender: Any) {
        self.goToCreateTagViewController()
    }
    
    /*
     // Method: onBtnSignup
     // Description: IBAction for signup button
     */
    @IBAction func onBtnStartRecording(_ sender: Any) {
        self.startStopRecording()
    }
    
    /*
     // Method: deleteClicked
     // Description: IBAction for delete tag button
     */
    @objc func deleteClicked(sender : UIButton) {
        print("delete Clicked")
        self.deleteTag(index: sender.tag)
    }
    
    /*
     // Method: timerAction
     // Description: IBAction for called every time interval from the timer
     */
    @objc func timerAction() {
        counter += 1
        let timerFormatedTime = self.secondsToHoursMinutesSeconds(counter)
        self.videoTimerLabel.text = "\(timerFormatedTime.hours):\(timerFormatedTime.minutes):\(timerFormatedTime.seconds)"
        
        let sloteValue = UserDefaults.standard.integer(forKey: "start")
        if sloteValue < counter {
            self.tagsCollectionView.isHidden = false
        } else {
            self.tagsCollectionView.isHidden = true
        }
        
    }
    
    /*
     // Method: timerActionForClip
     // Description: IBAction for called every time interval from the timer for clip
     */
    @objc func timerActionForClip() {
        recordingSlot -= 1
        if recordingSlot < 0 {
            self.view.isUserInteractionEnabled = true
            self.timerForClip.invalidate()
            self.clipTimeProgressView.isHidden = true
            self.startStopRecording()
            self.clipTimeProgressView.progress = 0.0
            self.startStopRecording()
            
            let sloteValue = UserDefaults.standard.integer(forKey: "stop")
            
            if sloteValue > 0 {
                self.recordingSlot = sloteValue
                self.videoTimeInSec = sloteValue
            } else {
                self.recordingSlot = 4
                self.videoTimeInSec = 4
            }
            
            
        } else {
            self.view.isUserInteractionEnabled = false
            self.clipTimeProgressView.isHidden = false
            let progress = videoTimeInSec - recordingSlot
            print("progress = \(Float(progress) / 10)")
            self.clipTimeProgressView.progress = Float(progress) / 10
        }
    }
    
    /*
     // Method: onBtnFlash
     // Description: IBAction for flash button
     */
    @IBAction func onBtnFlash(_ sender: Any) {
        if self.videoPickerController.cameraFlashMode == .on {
            self.videoPickerController.cameraFlashMode = .off
        } else {
            self.videoPickerController.cameraFlashMode = .on
        }
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
            
            var currentTimeInSec = self.secondsFromString(string: currentTime)
            
            var startValue = UserDefaults.standard.integer(forKey: "start")
            if startValue <= 0 {
                startValue = 4
            }
            var stopValue = UserDefaults.standard.integer(forKey: "stop")
            if stopValue <= 0 {
                stopValue = 4
            }
            
            currentTimeInSec = currentTimeInSec - stopValue
            
            let startSec = Float64(currentTimeInSec - startValue)
            let endSec = Float64(currentTimeInSec + stopValue)
            
            self.cropVideo(sourceURL1: cVideoURL, statTime: Float(startSec), endTime: Float(endSec))
            print("Done")
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    func createAlbum() {
        //Get PHFetch Options
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "VideoClips")
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        //Check return value - If found, then get the first album out
        if let _: AnyObject = collection.firstObject {
            print("Already Exist")
            //self.assetCollection = collection.firstObject!
        } else {
            print("Not Exist")
            //If not found - Then create a new album
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "VideoClips")   // create an asset collection with the album name
            }) { success, error in
                if success {
                    // created
                    //  self.assetCollection = self.fetchAssetCollectionForAlbum()
                } else {
                    print("error \(error)")
                }
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


// MARK: - UICollectionView Delegate and Database Methods

extension MainViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:TagCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath as IndexPath) as! TagCollectionViewCell
        
        let tagStruch = self.arrayTags[indexPath.row]
        cell.colorView.backgroundColor = AppUtility.hexColor(hex: tagStruch.color)
        cell.titleLabel.text = tagStruch.title
        
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action:#selector(self.deleteClicked), for: .touchUpInside)
        
        if tagStruch.title ==  self.selectedTag?.title {
            cell.selectedTagView.backgroundColor = .white
        } else {
            cell.selectedTagView.backgroundColor = .clear
        }
        
        cell.backgroundColor = UIColor.clear
        return cell
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isVideoRecordingStart {
            self.selectedTag = arrayTags[indexPath.row]
            self.isSavedVideo = false
            timerForClip = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerActionForClip), userInfo: nil, repeats: true)
            self.reloadTagCollectionView()
        } else {
            AppUtility.showMessage(title: "Info.", message: "Please Start Video First.", controller: self)
        }
      
        
    }
    
}
