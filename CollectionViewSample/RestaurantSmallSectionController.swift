//
//  RestaurantSmallSectionController.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 3/14/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//

import Foundation
import IGListKit

class RestaurantSmallSectionController: IGListSectionController, IGListSectionType, IGListAdapterDataSource {
    
    var item: Objects?
    
    var parentAdapter: IGListAdapter?
    var parent: RestaurantSectionController?
    
    lazy var adapter: IGListAdapter = {
        let adapter = IGListAdapter(updater: IGListAdapterUpdater(),
                                    viewController: self.viewController,
                                    workingRangeSize: 0)
        adapter.dataSource = self
        return adapter
    }()
    
//    deinit {
//        for task in tasks {
//            task.cancel()
//        }
//    }
//    
//    override init() {
//        super.init()
//        workingRangeDelegate = self
//    }
    
    func numberOfItems() -> Int {
        return self.item?.objects.count ?? 0
    }
    
    func sizeForItem(at index: Int) -> CGSize {
        let obj = self.item!.objects[index]
        switch obj {
        case "name":
            return CGSize(width: collectionContext!.containerSize.width, height: 25)
        case "type":
            return CGSize(width: collectionContext!.containerSize.width, height: 20)
        case "photo":
            let width: CGFloat = collectionContext?.containerSize.width ?? 0
            return CGSize(width: width, height: width/CGFloat(kPhotoProportion))
        case "location":
            return CGSize(width: collectionContext!.containerSize.width, height: 450)
        default:
            return CGSize(width: collectionContext!.containerSize.width, height: 0)
            
        }
    }
    
    func cellForItem(at index: Int) -> UICollectionViewCell {
        let obj = self.item!.objects[index]
        
        switch obj {
        case "name":
            let cell = collectionContext!.dequeueReusableCell(of: DetailLabelCell.self, for: self, at: index) as! DetailLabelCell
            cell.titleLabel.text = self.item!.item.name
            if let twitter = self.item!.item.twitter {
                cell.detailLabel.text = "@" + twitter
            } else {
                cell.detailLabel.text = ""
            }
            return cell
        case "type":
            let cell = collectionContext!.dequeueReusableCell(of: TypeLabelCell.self, for: self, at: index) as! TypeLabelCell
            cell.titleLabel.text = self.item?.item.type
            return cell
        case "photo":
            let cell = collectionContext!.dequeueReusableCell(of: EmbeddedCollectionViewCell.self, for: self, at: index) as! EmbeddedCollectionViewCell
            adapter.collectionView = cell.collectionView
            
            cell.titleLabel.text = self.item!.item.name
            if self.item! is MainObjects {
                cell.animate(toSmall: true)
                cell.typeLabel.text = self.item?.item.type
                cell.titleLabel.font = .systemFont(ofSize: 18.0, weight: UIFontWeightSemibold)
                if let twitter = self.item!.item.twitter {
                    cell.detailLabel.text = "@" + twitter
                } else {
                    cell.detailLabel.text = ""
                }
                cell.typeLabel.text = self.item?.item.type
            } else {
                cell.animate(toSmall: false)
                cell.titleLabel.font = .systemFont(ofSize: 22.0, weight: UIFontWeightSemibold)
                if let twitter = self.item!.item.twitter {
                    cell.typeLabel.text = "@" + twitter
                } else {
                    cell.typeLabel.text = ""
                }
                cell.detailLabel.text = ""
            }
            
            adapter.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
            return cell
        case "location":
            let cell = collectionContext!.dequeueReusableCell(of: MapCell.self, for: self, at: index) as! MapCell
            if let location = self.item?.item.coordinates {
                cell.setLocation(coordinates: location)
            }
            return cell
        default:
            let cell = collectionContext!.dequeueReusableCell(of: TypeLabelCell.self, for: self, at: index) as! TypeLabelCell
            cell.titleLabel.text = ""
            return cell
        }
    }
    
    func didUpdate(to object: Any) {
        self.item = object as? Objects
    }
    
    func didSelectItem(at index: Int) {
        if let main = self.viewController as? MainViewController,
           main.isDetail == false {
            
            main.isDetail = true
            main.detailItem = self.item!.item
            main.navigationController?.navigationBar.topItem?.title = ""
            
            guard let photoCell = self.collectionContext?.cellForItem(at: 0, sectionController: self) as? EmbeddedCollectionViewCell else {return}
            
            UIView.animate(withDuration: 0.4, animations: {
                main.collectionView.collectionViewLayout.invalidateLayout()
                
                main.collectionView.frame = main.view.frame
                
                photoCell.animate(toSmall: false)
                
                main.adapter.scroll(to: main.detailItem!, supplementaryKinds: nil, scrollDirection: .vertical, scrollPosition: .top, animated: false)
                
                self.parentAdapter?.performUpdates(animated: true, completion: { (result) in
                })
            }, completion: { (result) in
                main.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: main, action: #selector(MainViewController.backToMain(_:)))
                main.navigationItem.leftBarButtonItem?.tintColor = .white
                main.collectionView.isPagingEnabled = true
                main.collectionView.isScrollEnabled = false
                self.parentAdapter?.collectionView?.isScrollEnabled = true
            })
        }
        
    }
    
    
    //MARK: IGListAdapterDataSource
    
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        if self.item is MainObjects {
            return (self.item?.item.photos.first != nil) ? [self.item!.item.photos.first!] : []
        }
        return (self.item?.item.photos) ?? []
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
       let child = RestPhotoSectionController()
        child.parentAdapter = self.parentAdapter
        child.parent = self.parent
        return child
    }
    
    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        return nil
    }
}
