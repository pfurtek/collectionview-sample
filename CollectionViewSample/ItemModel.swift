//
//  ItemModel.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 2/28/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SCRecorder

private let singleton: ItemModel = ItemModel()

class ItemModel {
    class var shared: ItemModel {
        return singleton
    }
    
    var count: Int {
        return items.count
    }
    
    var items: [Item] = []
    
    func addVideo(with image: UIImage, url: URL, duration: Int, session: SCRecordSession?, player: AVPlayer) {
        let newItem = VideoItem(image: image, url: url, duration: duration, session: session, player: player)
        items.append(newItem)
    }
    
    func addImage(with image: UIImage) {
        let newItem = ImageItem(image: image)
        items.append(newItem)
    }
    
    func removeItem(at index: Int) {
        print("remove\(index)")
        items.remove(at: index)
    }
        
    func moveItem(from oldIndex: Int, to newIndex: Int) {
        print("move from \(oldIndex) to \(newIndex)")
        let elem = items.remove(at: oldIndex)
        items.insert(elem, at: newIndex)
    }
    
    func item(at index: Int) -> Item {
        return items[index]
    }
}

protocol Item {
    var image: UIImage {get set}
}

class ImageItem: Item {
    internal var image: UIImage

    
    init(image: UIImage) {
        self.image = image
    }
}

class VideoItem: Item {
    internal var image: UIImage
    var duration: Int
    var url: URL
    var player: AVPlayer
    var session: SCRecordSession?
    
    init(image: UIImage, url: URL, duration: Int, session: SCRecordSession?, player: AVPlayer) {
        self.image = image
        self.url = url
        self.duration = duration
        self.session = session
        self.player = player
    }
}
