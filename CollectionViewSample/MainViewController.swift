//
//  MainViewController.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 3/12/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import Foundation
import IGListKit

class MainViewController: UIViewController, CLLocationManagerDelegate, IGListAdapterDataSource, UIScrollViewDelegate {
    
    let locationManager = CLLocationManager()
    
    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 3)
    }()
    
    let collectionView = IGListCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        setupCollectionView()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupLocationManager() {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.activityType = .fitness
        self.locationManager.delegate = self
        //self.locationManager.startMonitoringSignificantLocationChanges()
        self.locationManager.requestLocation()
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {            
            downloadVenues(location: locations.first!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func downloadVenues(location: CLLocation) {
        let lat: CLLocationDegrees = location.coordinate.latitude
        let lon: CLLocationDegrees = location.coordinate.longitude
        let parameters: Parameters = [ "ll" : "\(lat),\(lon)",
            "client_id" : "MSXFM4U53MNSDLURQ0NZ0YREPNDSR3X3P2E5KU2PIF1JGHJA",
            "client_secret" : "12M34DY4SPDMUSWJBQU0TRFA3UAJC1QZXKDFZLVNK1BHNO0J",
            "categoryId" : "4d4b7105d754a06374d81259",
            "radius" : "1000",
            "v" : "20161231",
            "venuePhotos" : "1"]
        
        Alamofire.request("https://api.foursquare.com/v2/venues/explore", parameters: parameters).responseJSON { response in
                switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any],
                           let response = json["response"] as? [String: Any],
                           let groups = response["groups"] as? [Any],
                           let groupsDict = groups.first as? [String: Any],
                           let items = groupsDict["items"] as? [Any] {
                            RestaurantModel.shared.removeAll()
                            for item in items {
                                if let itemDict = item as? [String: Any] {
                                    if let venue = itemDict["venue"] as? [String: Any] {
                                       let name = venue["name"] as! String
                                       let item = RestaurantItem(name: name)
                                        if let categories = venue["categories"] as? [Any],
                                           let catDict = categories.first as? [String: Any] {
                                            item.type = catDict["name"] as? String
                                        }
                                        if let rat = venue["rating"] as? Double {
                                            item.rating = rat
                                        }
                                        if let location = venue["location"] as? [String: Any],
                                           let lat = location["lat"] as? Double,
                                           let lng = location["lng"] as? Double {
                                            item.coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                                        }
                                        if let photos = venue["photos"] as? [String: Any],
                                           let count = photos["count"] as? Int,
                                           let pGroups = photos["groups"] as? [Any],
                                           count > 0,
                                           let pGroupsDict = pGroups.first as? [String: Any],
                                           let pItems = pGroupsDict["items"] as? [Any],
                                           let pItemsDict = pItems.first as? [String: Any],
                                           let prefix = pItemsDict["prefix"] as? String,
                                           let suffix = pItemsDict["suffix"] as? String,
                                           let height = pItemsDict["height"] as? Int,
                                           let width = pItemsDict["width"] as? Int {
                                            //print(pGroups)
                                            let url = prefix + "original" + suffix
                                            print(url)
                                            let hPerw = Double(height)/Double(width)
                                            item.photo = url
                                            item.hPerW = hPerw
                                        }
                                                    
                                        //item.photo = "https://unsplash.it/\(414)/\(Int(arc4random_uniform(200)) + 200)"
                                                    
                                        print("+ \(name)")
                                                    
                                        RestaurantModel.shared.add(item: item)
                                        self.adapter.performUpdates(animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    case .failure(let error):
                        print(error)
                }
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
    
    
    // MARK: - IGListAdapterDataSource
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        switch object {
            case is RestaurantItem:
                let sectionController = RestaurantSectionController()
                /*IGListStackedSectionController(sectionControllers: [
                    RestNameSectionController(),
                    RestTypeSectionController(),
                    RestPhotoSectionController()
                    //RestMapSectionController()
                    ])!*/
                sectionController.inset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
                return sectionController
            default:
                return RestNameSectionController()
        }
    }

    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        return RestaurantModel.shared.items
    }
    
    func emptyView(for listAdapter: IGListAdapter) -> UIView? { return nil }
}
