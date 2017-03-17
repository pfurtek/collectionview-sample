//
//  RestaurantDetailViewController.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 3/14/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import Foundation
import IGListKit

class RestaurantDetailViewController: UIViewController, IGListAdapterDataSource, UIScrollViewDelegate {
    
    var item: RestaurantItem?
    
    
    lazy var adapter: IGListAdapter = {
        return IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 1)
    }()
    
    let collectionView = IGListCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
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
            //sectionController.inset = UIEdgeInsets(top: 3, left: 0, bottom: 7, right: 0)
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
