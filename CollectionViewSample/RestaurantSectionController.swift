//
//  RestaurantSectionController.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 3/12/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//


import Foundation
import IGListKit

class RestaurantSectionController: IGListSectionController, IGListSectionType, IGListWorkingRangeDelegate {
    
    var item: RestaurantItem?
    var objects: [String] = []
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
        return self.objects.count
    }
    
    func sizeForItem(at index: Int) -> CGSize {
        let obj = self.objects[index]
        switch obj {
            case "name":
                return CGSize(width: collectionContext!.containerSize.width, height: 25)
            case "type":
                return CGSize(width: collectionContext!.containerSize.width, height: 20)
            case "photo":
                let width: CGFloat = collectionContext?.containerSize.width ?? 0
                let height: CGFloat = (self.item?.hPerW == nil) ? 0 : CGFloat(self.item!.hPerW! * Double(width))
                return CGSize(width: width, height: height)
            case "location":
                return CGSize(width: collectionContext!.containerSize.width, height: 130)
            default:
                return CGSize(width: collectionContext!.containerSize.width, height: 0)
            
        }
    }
    
    func cellForItem(at index: Int) -> UICollectionViewCell {
        let obj = self.objects[index]
        
        switch obj {
            case "name":
                let cell = collectionContext!.dequeueReusableCell(of: DetailLabelCell.self, for: self, at: index) as! DetailLabelCell
                cell.titleLabel.text = item?.name
                cell.detailLabel.text = (item?.rating?.description ?? "")
                return cell
            case "type":
                let cell = collectionContext!.dequeueReusableCell(of: TypeLabelCell.self, for: self, at: index) as! TypeLabelCell
                cell.titleLabel.text = self.item?.type
                return cell
            case "photo":
                let cell = collectionContext!.dequeueReusableCell(of: ImageCell.self, for: self, at: index) as! ImageCell
                cell.setImage(image: downloadedImage)
                return cell
            case "location":
                let cell = collectionContext!.dequeueReusableCell(of: MapCell.self, for: self, at: index) as! MapCell
                if let location = self.item?.coordinates {
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
        self.item = object as? RestaurantItem
        self.objects.removeAll()
        if let item = self.item {
            self.objects.append("name")
            if item.type != nil {
                self.objects.append("type")
            }
            if item.photo != nil {
                self.objects.append("photo")
            }
        }
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
                if let index = self.objects.index(where: { (item) -> Bool in
                        item == "photo"
                    }) {
                    if let cell = self.collectionContext?.cellForItem(at: index, sectionController: self) as? ImageCell {
                        cell.setImage(image: image)
                        self.collectionContext?.reload(in: sectionController, at: [index])
                    }
                }
            }
        }
        task?.resume()
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerDidExitWorkingRange sectionController: IGListSectionController) {}
}
