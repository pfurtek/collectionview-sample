//
//  RestaurantEmbeddedCollectionCell.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 3/14/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//

import UIKit
import IGListKit

class RestaurantEmbeddedCollectionCell: UICollectionViewCell {
    
    lazy var collectionView: IGListCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let view = IGListCollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.alwaysBounceVertical = false
        view.alwaysBounceHorizontal = false
        self.contentView.addSubview(view)
        view.layer.cornerRadius = 25
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.frame
    }
    
}
