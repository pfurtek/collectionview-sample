//
//  TypeLabelCell.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 3/12/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//

import UIKit

class TypeLabelCell: UICollectionViewCell {
    
    fileprivate let padding: CGFloat = 15.0
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 16)
        view.textColor = .lightGray
        self.contentView.addSubview(view)
        return view
    }()

    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = contentView.bounds.insetBy(dx: padding, dy: 0)
        titleLabel.frame = frame
    }
    
}
