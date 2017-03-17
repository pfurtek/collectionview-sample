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
    var twitter: String?
    var photos: [RestaurantPhoto] = []
    var hPerW: Double?
    var coordinates: RestaurantCoordinate?
    
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
        if obj.twitter != self.twitter {
            return false
        }
        /*if obj.photos != self.photos {
            return false
        }*/
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

class RestaurantPhoto {
    var photo: UIImage?
    var url: String
    var owner: RestaurantItem
    
    init(url: String, owner: RestaurantItem) {
        self.url = url
        self.owner = owner
    }
}

extension RestaurantPhoto: IGListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return self.url as NSString
    }
    
    func isEqual(toDiffableObject object: IGListDiffable?) -> Bool {
        guard let obj = object as? RestaurantPhoto else {
            return false
        }
        if obj.url != self.url {
            return false
        }
        if obj.photo != self.photo {
            return false
        }
        return true
    }
}

/*
 Needed to extend IGListDiffable, but CLLocationCoordinate2D is a struct, not a class
 */
class RestaurantCoordinate {
    var longitude: CLLocationDegrees
    var latitude: CLLocationDegrees
    var clCoordinate: CLLocationCoordinate2D
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.latitude = latitude
        self.longitude = longitude
        self.clCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension RestaurantCoordinate: IGListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return "\(self.latitude),\(self.longitude)" as NSString
    }
    
    func isEqual(toDiffableObject object: IGListDiffable?) -> Bool {
        guard let obj = object as? RestaurantCoordinate else {
            return false
        }
        if obj.longitude != self.longitude {
            return false
        }
        if obj.latitude != self.latitude {
            return false
        }
        return true
    }
}
