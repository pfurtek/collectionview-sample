//
//  RestaurantSectionController.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 3/12/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//


import Foundation
import IGListKit

let kPhotoProportion = 1.4

class RestaurantSectionController: IGListSectionController, IGListSectionType, IGListAdapterDataSource, IGListWorkingRangeDelegate {
    
    var item: RestaurantItem?
    var detailObjects: DetailObjects?
    var mainObjects: MainObjects?
    var tasks: [URLSessionDataTask] = []
    
    var navBarBackImage: UIImage?
    
    lazy var adapter: IGListAdapter = {
        let adapter = IGListAdapter(updater: IGListAdapterUpdater(),
                                    viewController: self.viewController,
                                    workingRangeSize: 0)
        adapter.dataSource = self
        return adapter
    }()
    
    deinit {
        for task in tasks {
            //task.cancel()
        }
    }
    
    override init() {
        super.init()
        workingRangeDelegate = self
    }
    
    func numberOfItems() -> Int {
        return 1
    }
    
    func sizeForItem(at index: Int) -> CGSize {
        print("size for item")
        
        if (viewController as? MainViewController)?.isDetail ?? false,
           (viewController as? MainViewController)?.detailItem?.isEqual(toDiffableObject: self.item) ?? false {
            return collectionContext!.containerSize
        }
        let height = Double(collectionContext!.containerSize.width)/kPhotoProportion
        return CGSize(width: collectionContext!.containerSize.width, height: CGFloat(height))
        
    }
    
    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: RestaurantEmbeddedCollectionCell.self, for: self, at: index) as! RestaurantEmbeddedCollectionCell
        adapter.collectionView = cell.collectionView
        
        cell.collectionView.isScrollEnabled = false
        
        
        
        //adapter.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
        return cell
    }
    
    func didUpdate(to object: Any) {
        self.item = object as? RestaurantItem
        self.mainObjects = nil
        self.detailObjects = nil
        if let item = self.item {
            self.mainObjects = MainObjects(item: item)
            self.detailObjects = DetailObjects(item: item)
            if item.photos.count > 0 {
                self.detailObjects?.objects.insert("photo", at: 0)
                self.mainObjects?.objects.append("photo")
            }
            if item.coordinates != nil {
                self.detailObjects?.objects.append("location")
            }
        }
    }
    
    func didSelectItem(at index: Int) {
        
    }
    
    
    //MARK: IGListAdapterDataSource
    
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        if self.item == nil {
            print("none")
            return []
        }
        if (self.viewController as? MainViewController)?.isDetail ?? false,
            (viewController as? MainViewController)?.detailItem?.isEqual(toDiffableObject: self.item) ?? false {
            print("detail")
            return [self.detailObjects!]
        }
        print("main")
        return [self.mainObjects!]
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        let child = RestaurantSmallSectionController()
        child.parentAdapter = listAdapter
        child.parent = self
        return child
    }
    
    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        return nil
    }
    
    //MARK: IGListWorkingRangeDelegate
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerWillEnterWorkingRange sectionController: IGListSectionController) {
        guard tasks.count == 0,
            let item = self.item,
            item.photos.count > 0,
            let section = collectionContext?.section(for: self)
            else { return }

        
        for photo in item.photos {
            guard let url = URL(string: photo.url) else {return}
            guard let forIndex = item.photos.index(where: { (photoItem) -> Bool in
                    return photo.isEqual(toDiffableObject: photoItem)
                }) else {return}
            print("Downloading image \(item.photos[forIndex].url) for section \(section)")
            
            let task = URLSession.shared.dataTask(with: url) { data, response, err in
                guard let photoIndex = item.photos.index(where: { (photoItem) -> Bool in
                        return photo.isEqual(toDiffableObject: photoItem)
                    }) else {return}
                
                guard let data = data, let image = UIImage(data: data) else {
                    return print("Error downloading \(item.photos[photoIndex].url): \(err.debugDescription)")
                }
                
                print("got item: \(item.name), photoIndex: \(photoIndex), image: \(image)")
                
                RestaurantModel.shared.item(at: section).photos[photoIndex].photo = image
                if photoIndex == 0 {
                    DispatchQueue.main.async {
                        print("downloaded for \(section)")
                        self.adapter.reloadData(completion: nil)
                    }
                }
            }
            self.tasks.append(task)
            task.resume()
        }
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerDidExitWorkingRange sectionController: IGListSectionController) {}
}

class Objects {
    var objects: [String] = []
    var item: RestaurantItem
    
    init(item: RestaurantItem) {
        self.item = item
    }
}

extension Objects: IGListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return self.item.diffIdentifier()
    }
    
    func isEqual(toDiffableObject object: IGListDiffable?) -> Bool {
        guard let obj = object as? Objects else {
            return false
        }
        if !obj.item.isEqual(toDiffableObject: self.item) {
            return false
        }
        if obj.objects.count != self.objects.count {
            return false
        }
        for ob in self.objects {
            if !obj.objects.contains(ob) {
                return false
            }
        }
        return true
    }
}

class MainObjects: Objects {}
class DetailObjects: Objects {}
