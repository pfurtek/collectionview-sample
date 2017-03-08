//
//  RecordViewController.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 3/3/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//

import UIKit
import SCRecorder
import AVKit

class RecordViewController: UIViewController, SCRecorderDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var recorder = SCRecorder()
    @IBOutlet weak var previewView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    var item: VideoItem? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recorder.captureSessionPreset = SCRecorderTools.bestCaptureSessionPresetCompatibleWithAllDevices()
        recorder.delegate = self
        recorder.autoSetVideoOrientation = false
        recorder.previewView = self.previewView
        recorder.initializeSessionLazily = false
        recorder.maxRecordDuration = CMTime(seconds: 30.0, preferredTimescale: 1)

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.turnCamera(_:)))
        tapGesture.numberOfTapsRequired = 2
        self.previewView.addGestureRecognizer(tapGesture)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.moveSegments(_:)))
        self.collectionView.addGestureRecognizer(longGesture)
        
        do {
            try recorder.prepare()
        } catch {
            print(error.localizedDescription)
        }

        // Do any additional setup after loading the view.
        
        collectionView.backgroundColor = UIColor.clear
        self.view.bringSubview(toFront: collectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.recorder.session.pre
        if (recorder.session == nil) {

            let session = SCRecordSession()
            session.fileType = AVFileTypeQuickTimeMovie
            
            self.recorder.session = session
        }
        
        //self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.recorder.previewViewFrameChanged()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.recorder.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.recorder.stopRunning()
        print("before if")
        if (self.isMovingFromParentViewController || self.isBeingDismissed) && self.recorder.session != nil {
            print("past if")
            let asset = self.recorder.session!.assetRepresentingSegments()
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            do {
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                let image = UIImage(cgImage: cgImage)
                let duration = asset.duration
                let seconds = Int(duration.value) / Int(duration.timescale)
                if self.item != nil {
                    self.item!.image = image
                    self.item!.duration = seconds
                    self.item!.player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
                    self.item!.session = self.recorder.session
                    self.item!.url = self.recorder.session!.outputUrl
                } else {
                    ItemModel.shared.addVideo(with: image, url: self.recorder.session!.outputUrl, duration: seconds, session: self.recorder.session, player: AVPlayer(playerItem: AVPlayerItem(asset: asset)))
                }
            } catch {
                
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //self.navigationController?.isNavigationBarHidden = false
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonTouchDown(_ sender: Any) {
        print("Button touch down")
        recorder.record()
    }
    
    @IBAction func doneClicked(_ sender: Any) {
        self.dismiss(animated: true) { 
            
        }
    }
    
    @IBAction func buttonTouchUpInside(_ sender: Any) {
        print("button touch up inside")
        recorder.pause()
    }
    
    func turnCamera(_ sender: UITapGestureRecognizer) {
        self.recorder.switchCaptureDevices()
    }
    
    func moveSegments(_ gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func recorder(_ recorder: SCRecorder, didComplete session: SCRecordSession) {
        print("complete session")
        self.dismiss(animated: true, completion: nil)
    }
    
    func recorder(_ recorder: SCRecorder, didComplete segment: SCRecordSessionSegment?, in session: SCRecordSession, error: Error?) {
        if segment != nil {
            print("complete segment")
            print(segment!.duration.seconds)
            print(session.segments.count)
            if segment!.duration.seconds < 0.3 {
                recorder.capturePhoto({ (error, image) in
                    
                })
            }
            self.collectionView?.reloadData()
        }
    }
    
    
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.recorder.session != nil {
            return self.recorder.session!.segments.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "segmentCell", for: indexPath) as! SegmentCollectionViewCell
        
        let segment = self.recorder.session!.segments[indexPath.row] as! SCRecordSessionSegment
        
        cell.imageView.image = segment.thumbnail
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let segment = self.recorder.session!.segments[sourceIndexPath.row] as! SCRecordSessionSegment
        self.recorder.session!.removeSegment(at: sourceIndexPath.row, deleteFile: false)
        self.recorder.session!.insertSegment(segment, at: destinationIndexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        let height = Int((collectionView.bounds.height - totalSpace))
        return CGSize(width: height*9/16, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let segment = self.recorder.session!.segments[indexPath.row] as! SCRecordSessionSegment
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "Preview", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: {
            })
            let player = AVPlayer(playerItem: AVPlayerItem(asset: segment.asset!))
            let playerController = AVPlayerViewController()
            playerController.player = player
            self.present(playerController, animated: true) {
                    player.play()
            }
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (action) in
            alert.dismiss(animated: true, completion: {
            })
            self.recorder.session!.removeSegment(at: indexPath.row, deleteFile: false)
            self.collectionView.deleteItems(at: [indexPath])
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}


