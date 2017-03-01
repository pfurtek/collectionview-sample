//
//  ItemModel.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 2/28/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//

import UIKit

private let singleton: ItemModel = ItemModel()

//private let images: [String] = ["eggs", "pizza", "quesadilla"]

class ItemModel {
    class var shared: ItemModel {
        return singleton
    }
    
    var count: Int {
        return items.count
    }
    
    var items: [Item] = []
    
    /*func addItem() {
        let rand = Int(Date().timeIntervalSince1970*60)%3
        let image = images[rand]
        let newItem = Item(image: image)
        items.append(newItem)
    }*/
    
    func addItem(with image: UIImage) {
        let newItem = Item(image: image)
        items.append(newItem)
    }
    
    func removeItem(at index: Int) {
        items.remove(at: index)
    }
    
    func moveItem(from oldIndex: Int, to newIndex: Int) {
        items.insert(items.remove(at: oldIndex), at: newIndex)
    }
    
    func item(at index: Int) -> Item {
        return items[index]
    }
}

class Item {
    var image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
}
