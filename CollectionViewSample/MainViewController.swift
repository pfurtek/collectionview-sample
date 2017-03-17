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
    var askedForLocation = false
    
    var isDetail = false
    var detailItem: RestaurantItem?
    var detailSectionController: RestaurantSectionController?
    
    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 1)
    }()
    
    let collectionView = IGListCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        setupCollectionView()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.isTranslucent = true
        
        
        self.adapter.scrollViewDelegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var frame = view.bounds
        frame.size.height -= 64
        frame.origin.y += 64
        collectionView.frame = frame
        collectionView.layoutSubviews()
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
        self.askForRestaurants()
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        //collectionView.backgroundColor = .black
        adapter.dataSource = self
    }
    
    func askForRestaurants() {
        self.askedForLocation = true
        self.locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0, self.askedForLocation {
            self.askedForLocation = false
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
                                if let itemDict = item as? [String: Any],
                                   let venue = itemDict["venue"] as? [String: Any],
                                   let name = venue["name"] as? String {
                                    let item = RestaurantItem(name: name)
                                    if let categories = venue["categories"] as? [Any],
                                        let catDict = categories.first as? [String: Any] {
                                        item.type = catDict["name"] as? String
                                    }
                                    if let contact = venue["contact"] as? [String: Any],
                                        let twitter = contact["twitter"] as? String {
                                        item.twitter = twitter
                                    }
                                    if let rat = venue["rating"] as? Double {
                                        item.rating = rat
                                    }
                                    if let location = venue["location"] as? [String: Any],
                                        let lat = location["lat"] as? Double,
                                        let lng = location["lng"] as? Double {
                                        item.coordinates = RestaurantCoordinate(latitude: lat, longitude: lng)
                                    }
                                    if let photos = venue["photos"] as? [String: Any],
                                       let pGroups = photos["groups"] as? [Any],
                                       let pGroupsDict = pGroups.first as? [String: Any],
                                       let pItems = pGroupsDict["items"] as? [[String:Any]] {
                                        for pItem in pItems {
                                            if let prefix = pItem["prefix"] as? String,
                                               let suffix = pItem["suffix"] as? String,
                                               let height = pItem["height"] as? Int,
                                               let width = pItem["width"] as? Int {
                                                let url = prefix + "original" + suffix
                                                print(url)
                                                let hPerw = Double(height)/Double(width)
                                                item.photos.append(RestaurantPhoto(url: url, owner: item))
                                                item.hPerW = hPerw
                                            }
                                        }
                                        item.photos.append(RestaurantPhoto(url: "https://unsplash.it/\(414)/\(Int(arc4random_uniform(200)) + 200)", owner: item))
                                        item.photos.append(RestaurantPhoto(url: "https://unsplash.it/\(414)/\(Int(arc4random_uniform(200)) + 200)", owner: item))
                                        
                                        print("+ \(name)")
                                        
                                        RestaurantModel.shared.add(item: item)
                                    }
                                }
                            }
                            self.adapter.performUpdates(animated: true, completion: nil)
                        }
                    case .failure(let error):
                        print(error)
                }
            }
        
    }
    
    func backToMain(_ sender: UIBarButtonItem) {
        self.isDetail = false
        self.navigationItem.leftBarButtonItem = nil
        
        if let mySection = self.adapter.sectionController(for: self.detailItem!) as? RestaurantSectionController {
            print("adapter")
            
            var frame = self.view.bounds
            frame.size.height -= 64
            frame.origin.y += 64
            
            if let smallSection = mySection.adapter.sectionController(for: mySection.detailObjects!) as? RestaurantSmallSectionController {
                guard let photoCell = smallSection.collectionContext?.cellForItem(at: 0, sectionController: smallSection) as? EmbeddedCollectionViewCell else {return}
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    
                    photoCell.animate(toSmall: true)
                    
                    self.collectionView.frame = frame
                    
                    mySection.adapter.performUpdates(animated: true, completion: nil)
                }, completion: { (result) in
                    mySection.adapter.collectionView!.isScrollEnabled = false
                    self.collectionView.isPagingEnabled = false
                    self.collectionView.isScrollEnabled = true
                    self.navigationController?.navigationBar.topItem?.title = "SnackChat"
                })
            }
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    
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
                sectionController.inset = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
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
