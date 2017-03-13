//
//  RestaurantModel.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 3/12/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//

import Foundation
import IGListKit
import CoreLocation

private let singleton: RestaurantModel = RestaurantModel()

class RestaurantModel {
    class var shared: RestaurantModel {
        return singleton
    }
    
    var count: Int {
        return items.count
    }
    
    var items: [RestaurantItem] = []
    
    func add(item: RestaurantItem) {
        items.append(item)
    }
    
    func removeItem(at index: Int) {
        items.remove(at: index)
    }
    
    func removeAll() {
        items.removeAll()
    }
    
    func moveItem(from oldIndex: Int, to newIndex: Int) {
        let elem = items.remove(at: oldIndex)
        items.insert(elem, at: newIndex)
    }
    
    func item(at index: Int) -> RestaurantItem {
        return items[index]
    }
}

class RestaurantItem {
    var name: String
    var type: String?
    var rating: Double?
    var photo: String?
    var hPerW: Double?
    var coordinates: CLLocationCoordinate2D?
    
    init(name: String) {
        self.name = name
    }
}

extension RestaurantItem: IGListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return self.name as NSString
    }
    
    func isEqual(toDiffableObject object: IGListDiffable?) -> Bool {
        guard let obj = object as? RestaurantItem else {
            return false
        }
        if obj.name != self.name {
            return false
        }
        if obj.type != self.type {
            return false
        }
        if obj.rating != self.rating {
            return false
        }
        if obj.photo != self.photo {
            return false
        }
        if obj.coordinates?.latitude != self.coordinates?.latitude {
            return false
        }
        if obj.coordinates?.longitude != self.coordinates?.longitude {
            return false
        }
        if obj.hPerW != self.hPerW {
            return false
        }
        return true
    }
}
