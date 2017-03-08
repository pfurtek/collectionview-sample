//
//  CollectionViewController.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 2/28/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import AVKit
import Fusuma
import SCRecorder
import Photos

private let reuseAddIdentifier = "addCell"
private let reuseItemIdentifier = "itemCell"
let numberOfItemsPerRow = 3

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FusumaDelegate, SCAssetExportSessionDelegate {
    
    var lastSelected = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.collectionView?.reloadData()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "editVideo" {
            let dest = segue.destination as! RecordViewController
            let item = ItemModel.shared.item(at: lastSelected) as! VideoItem
            dest.item = item
            dest.recorder.session = item.session
        }
    }
    
    
    func selectPicture() {
        /*
        let picker = UIImagePickerController()
//        picker.allowsEditing = true
        picker.delegate = self
        picker.mediaTypes = [kUTTypeMovie as String]
//        picker.modalPresentationStyle = .
        self.present(picker, animated: true)
         */
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = true // If you want to let the users allow to use video.
        
        self.present(fusuma, animated: true, completion: nil)
    }
    
    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(_ image: UIImage) {
        print("Called just after FusumaViewController is dismissed.")
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        let asset = AVURLAsset(url: fileURL, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let image = UIImage(cgImage: cgImage)
            let duration = asset.duration
            let seconds = Int(duration.value) / Int(duration.timescale)
            ItemModel.shared.addVideo(with: image, url: fileURL, duration: seconds, session: nil, player: AVPlayer(playerItem: AVPlayerItem(asset: asset)))
            self.collectionView?.reloadData()
        } catch {
            
        }
        
        print("Called just after a video has been selected.")
    }
    
    func fusumaClosed() {
        print("fusuma closed")
    }
    
    func fusumaImageSelected(_ image: UIImage) {
        print("image selected")
        
        ItemModel.shared.addImage(with: image)
        self.collectionView?.reloadData()
        
        
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
    }
    
    /*func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
     
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //var newImage: UIImage

        let videoURL = info["UIImagePickerControllerReferenceURL"] as? URL
        //print(videoURL)
        
        /*
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }*/
        
        // do something interesting here!
        //print(newImage.size)
        if let url = videoURL {
            ItemModel.shared.addItem(with: url)
            self.collectionView?.reloadData()
        }
        dismiss(animated: true)
    }*/

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return ItemModel.shared.count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseAddIdentifier, for: indexPath) as! AddCollectionViewCell
            
            cell.addButtonSetup()
            
            cell.action = {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                alert.addAction(UIAlertAction(title: "Take a video", style: UIAlertActionStyle.default, handler: { (action) in
                    print("clicked")
                    self.performSegue(withIdentifier: "takeVideo", sender: nil)
                }))
                alert.addAction(UIAlertAction(title: "Choose from Camera Roll", style: UIAlertActionStyle.default, handler: { (action) in
                    alert.dismiss(animated: true, completion: {
                    })
                    self.selectPicture()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseItemIdentifier, for: indexPath) as! ItemCollectionViewCell
            
            let item = ItemModel.shared.item(at: indexPath.row - 1)
            
            cell.imageView.image = item.image
            
            if item is VideoItem {
                let seconds = (item as! VideoItem).duration
                cell.lengthLabel.text = "📹: \(seconds/60):\(String(format: "%02d", seconds%60))"
            } else {
                cell.lengthLabel.text = ""
            }
            
            cell.deleteAction = {
                let index = self.collectionView?.indexPath(for: cell)?.row
                ItemModel.shared.removeItem(at: index! - 1)
                self.collectionView?.deleteItems(at: [IndexPath(row: index!, section: indexPath.section)])
            }
            
            return cell
        }
        
    
        // Configure the cell
    
        
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {

        return false
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            return
        }
        self.lastSelected = indexPath.row - 1
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "Preview", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: {
            })
            let item = ItemModel.shared.item(at: indexPath.row - 1)
            if item is VideoItem {
                let player = (item as! VideoItem).player
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.present(playerController, animated: true) {
                    player.play()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Save to Camera Roll", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: {
            })
            guard let item = ItemModel.shared.item(at: indexPath.row - 1) as? VideoItem else {
                return
            }
            guard let session = item.session else {
                return
            }
            let exportSession = SCAssetExportSession(asset: session.assetRepresentingSegments())
            exportSession.audioConfiguration.preset = SCPresetHighestQuality
            exportSession.outputUrl = session.outputUrl
            exportSession.outputFileType = AVFileTypeMPEG4
            exportSession.delegate = self
            exportSession.contextType = .auto
            
            exportSession.exportAsynchronously(completionHandler: {
                if exportSession.error == nil {
                    let saveToCameraRoll = SCSaveToCameraRollOperation()
                    saveToCameraRoll.saveVideoURL(exportSession.outputUrl, completion: { (path, error) in
                        if error == nil {
                            let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            let alertController = UIAlertController(title: "Saving to Camera Roll failed!", message: nil, preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK :(", style: .default, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    })
                }
            })
        }))
        let item = ItemModel.shared.item(at: indexPath.row - 1)
        if item is VideoItem && (item as! VideoItem).session != nil {
            alert.addAction(UIAlertAction(title: "Edit", style: UIAlertActionStyle.default, handler: { (action) in
                alert.dismiss(animated: true, completion: {
                })
                self.performSegue(withIdentifier: "editVideo", sender: nil)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        if proposedIndexPath.row == 0 {
            return originalIndexPath
        }
        return proposedIndexPath
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        ItemModel.shared.moveItem(from: sourceIndexPath.row - 1, to: destinationIndexPath.row - 1)
        //self.collectionView?.reloadData()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.top
            + flowLayout.sectionInset.bottom
            + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
            + CGFloat(20)
        let width = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsPerRow))
        return CGSize(width: width, height: width*16/9)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: CGFloat(10), left: CGFloat(10), bottom: CGFloat(10), right: CGFloat(10))
    }

}

class NavigationBar: UINavigationBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: self.superview!.bounds.size.width, height: 80)
    }
    
    override var frame: CGRect {
        didSet {
            if frame.size.height != 80 {
                frame.size.height = 80
            }
        }
    }
}
