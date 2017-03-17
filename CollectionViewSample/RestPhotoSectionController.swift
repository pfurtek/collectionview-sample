//
//  RestPhotoSectionController.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 3/12/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//

import Foundation
import IGListKit

class RestPhotoSectionController: IGListSectionController, IGListSectionType {
    
    var photo: RestaurantPhoto?
//    var downloadedImage: UIImage?
//    var task: URLSessionDataTask?
    
//    deinit {
//        task?.cancel()
//    }
//    
//    override init() {
//        super.init()
//        workingRangeDelegate = self
//        
//    }
    
    var parentAdapter: IGListAdapter?
    var parent: RestaurantSectionController?
    
    func numberOfItems() -> Int {
        return 1
    }
    
    func sizeForItem(at index: Int) -> CGSize {
        let width: CGFloat = collectionContext?.containerSize.width ?? 0
        return CGSize(width: width, height: width/CGFloat(kPhotoProportion))
    }
    
    func didSelectItem(at index: Int) {
        if let main = self.viewController as? MainViewController,
           main.isDetail == false {
            
            main.isDetail = true
            main.detailItem = self.photo!.owner
            main.navigationController?.navigationBar.topItem?.title = ""
            
            guard let mySection = main.adapter.sectionController(for: main.detailItem!) as?RestaurantSectionController,
                let smallSection = mySection.adapter.sectionController(for: mySection.detailObjects!) as? RestaurantSmallSectionController,
                let photoCell = smallSection.collectionContext?.cellForItem(at: 0, sectionController: smallSection) as? EmbeddedCollectionViewCell else {return}
            

            
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
                self.parentAdapter?.collectionView?.isScrollEnabled = true
                main.collectionView.isScrollEnabled = false
                main.collectionView.isPagingEnabled = true
            })
        }
    }
    
    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: ImageCell.self, for: self, at: index) as! ImageCell
        
        print("showing item: \(self.photo!.owner.name), photoIndex: \(index), image: \(self.photo!.photo)")
        
        cell.setImage(image: self.photo!.photo)
        
        return cell
    }
    
    func didUpdate(to object: Any) {
        self.photo = object as? RestaurantPhoto
    }
    
    
//
//    //MARK: IGListWorkingRangeDelegate
//    
//    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerWillEnterWorkingRange sectionController: IGListSectionController) {
//        guard downloadedImage == nil,
//            task == nil,
//            let section = collectionContext?.section(for: self),
//            let item = self.item,
//            let url = URL(string: item.photos[section])
//            else { return }
//        
//        
//        print("Downloading image \(item.photos[section]) for section \(section)")
//        
//        task = URLSession.shared.dataTask(with: url) { data, response, err in
//            guard let data = data, let image = UIImage(data: data) else {
//                return print("Error downloading \(item.photos[section]): \(err.debugDescription)")
//            }
//            DispatchQueue.main.async {
//                self.downloadedImage = image
//                print("downloaded for \(section)")
//                    if let cell = self.collectionContext?.cellForItem(at: 0, sectionController: self) as? ImageCell {
//                        cell.setImage(image: image)
//                        self.collectionContext?.reload(in: sectionController, at: [0])
//                    }
//            }
//        }
//        task?.resume()
//    }
//    
//    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerDidExitWorkingRange sectionController: IGListSectionController) {}
}
