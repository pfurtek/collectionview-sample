//
//  ItemCollectionViewCell.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 2/28/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var deleteAction: ()->Void = {}
    
    @IBAction func deleteClicked(_ sender: Any) {
        deleteAction()
    }
}
