//
//  AddCollectionViewCell.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 2/28/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//

import UIKit

class AddCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var addButton: UIButton!
    var action: ()->Void = {}
    
    @IBAction func addClicked(_ sender: Any) {
        action()
    }
    
    func addButtonSetup() {
        addButton.layer.borderWidth = 1
        addButton.layer.borderColor = UIColor.darkGray.cgColor
        addButton.layer.cornerRadius = 23
        
    }
    
}
