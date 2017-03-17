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
    
    var location: RestaurantCoordinate?
    
    func numberOfItems() -> Int {
        return 1
    }
    
    func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: (self.location == nil ? 0 : 250))
    }
    
    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: MapCell.self, for: self, at: index) as! MapCell
        if let loc = location {
            cell.setLocation(coordinates: loc)
        }
        return cell
    }
    
    func didUpdate(to object: Any) {
        self.location = object as? RestaurantCoordinate
    }
    
    func didSelectItem(at index: Int) {}
}
