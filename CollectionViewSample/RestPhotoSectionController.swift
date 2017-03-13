//
//  RestPhotoSectionController.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 3/12/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//

import Foundation
import IGListKit

class RestPhotoSectionController: IGListSectionController, IGListSectionType, IGListWorkingRangeDelegate {
    
    var item: RestaurantItem?
    var downloadedImage: UIImage?
    var task: URLSessionDataTask?
    
    var urlString: String? {
        guard let item = item, let url = item.photo
            else { return nil }
        return url
    }
    
    deinit {
        task?.cancel()
    }
    
    override init() {
        super.init()
        workingRangeDelegate = self
    }
    
    func numberOfItems() -> Int {
        return 1
    }
    
    func sizeForItem(at index: Int) -> CGSize {
        let width: CGFloat = collectionContext?.containerSize.width ?? 0
        let height: CGFloat = (self.item?.hPerW == nil) ? 0 : CGFloat(self.item!.hPerW! * Double(width))
        return CGSize(width: width, height: height)        
    }
    
    func didSelectItem(at index: Int) {}
    
    //MARK: IGListWorkingRangeDelegate
    
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerWillEnterWorkingRange sectionController: IGListSectionController) {
        guard downloadedImage == nil,
            task == nil,
            let urlString = urlString,
            let url = URL(string: urlString)
            else { return }
        
        
        let section = collectionContext?.section(for: self) ?? 0
        print("Downloading image \(urlString) for section \(section)")
        
        task = URLSession.shared.dataTask(with: url) { data, response, err in
            guard let data = data, let image = UIImage(data: data) else {
                return print("Error downloading \(urlString): \(err.debugDescription)")
            }
            DispatchQueue.main.async {
                self.downloadedImage = image
                print("downloaded for \(section)")
                    if let cell = self.collectionContext?.cellForItem(at: 0, sectionController: self) as? ImageCell {
                        cell.setImage(image: image)
                        self.collectionContext?.reload(in: sectionController, at: [0])
                    }
            }
        }
        task?.resume()
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerDidExitWorkingRange sectionController: IGListSectionController) {}
    
    
    func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: ImageCell.self, for: self, at: index) as! ImageCell
        cell.setImage(image: downloadedImage)
        return cell
    }
    
    func didUpdate(to object: Any) {
        self.item = object as? RestaurantItem
    }
}
