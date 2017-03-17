//
//  RestNameSectionController.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 3/12/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//

import Foundation
import IGListKit

class RestNameSectionController: IGListSectionController, IGListSectionType {
    
    var item: RestaurantItem?
    
    func numberOfItems() -> Int {
        return 1
    }
    
    func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 25)
    }
    
    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: DetailLabelCell.self, for: self, at: index) as! DetailLabelCell
        cell.titleLabel.text = item?.name
        cell.detailLabel.text = (item?.twitter ?? "")
        return cell
    }
    
    func didUpdate(to object: Any) {
        self.item = object as? RestaurantItem
    }
    
    func didSelectItem(at index: Int) {}
}
