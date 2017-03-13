//
//  RestMapSectionController.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 3/12/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//

import Foundation
import IGListKit
import CoreLocation

class RestMapSectionController: IGListSectionController, IGListSectionType {
    
    var item: RestaurantItem?
    
    func numberOfItems() -> Int {
        return 1
    }
    
    func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: (self.item == nil ? 0 : 150))
    }
    
    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: MapCell.self, for: self, at: index) as! MapCell
        if let location = self.item?.coordinates {
            cell.setLocation(coordinates: location)
        }
        return cell
    }
    
    func didUpdate(to object: Any) {
        self.item = object as? RestaurantItem
    }
    
    func didSelectItem(at index: Int) {}
}
