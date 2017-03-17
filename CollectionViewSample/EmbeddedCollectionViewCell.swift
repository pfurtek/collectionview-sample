/**
 Copyright (c) 2016-present, Facebook, Inc. All rights reserved.

 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
import IGListKit

class EmbeddedCollectionViewCell: UICollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 18.0, weight: UIFontWeightSemibold)
        view.textColor = .white
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    lazy var detailLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .right
        view.font = .systemFont(ofSize: 14)
        view.textColor = .lightGray
        return view
    }()
    
    lazy var typeLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 16)
        view.textColor = .lightGray
        return view
    }()
    
    lazy var background: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }()
    
    fileprivate let paddingx: CGFloat = 0.0
    fileprivate let paddingy: CGFloat = 0.0
    fileprivate let textPaddingx: CGFloat = 15.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(collectionView)
        contentView.addSubview(background)
        contentView.addSubview(detailLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(typeLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var collectionView: IGListCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = IGListCollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.alwaysBounceVertical = false
        view.alwaysBounceHorizontal = false
        view.isPagingEnabled = true
        
        return view
    }()
    
    var smallView = true
    var once = true

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.frame
        
//        if once {
//            once = false
//            if smallView {
//                var backFrame = contentView.bounds
//                backFrame.size.height = 45
//                background.frame = backFrame
//                
//                var topFrame = contentView.bounds
//                topFrame.size.height = 25
//                titleLabel.frame = topFrame.insetBy(dx: textPaddingx, dy: 0)
//                detailLabel.frame = topFrame.insetBy(dx: textPaddingx, dy: 0)
//                
//                var bottomFrame = contentView.bounds
//                bottomFrame.size.height = 20
//                bottomFrame.origin.y += 25
//                typeLabel.frame = bottomFrame.insetBy(dx: textPaddingx, dy: 0)
//            } else {
//                var backFrame = contentView.bounds
//                backFrame.origin.y += (backFrame.size.height - 55)
//                backFrame.size.height = 55
//                background.frame = backFrame
//                
//                var topFrame = contentView.bounds
//                topFrame.origin = backFrame.origin
//                topFrame.size.height = 35
//                titleLabel.frame = topFrame.insetBy(dx: textPaddingx, dy: 0)
//                detailLabel.frame = topFrame.insetBy(dx: textPaddingx, dy: 0)
//                
//                var bottomFrame = contentView.bounds
//                bottomFrame.origin.y += (bottomFrame.size.height - 25)
//                bottomFrame.size.height = 25
//                typeLabel.frame = bottomFrame.insetBy(dx: textPaddingx, dy: 0)
//            }
//        }
    }
    
    func animate(toSmall: Bool) {
        smallView = toSmall
        if toSmall {
            var backFrame = contentView.bounds
            backFrame.size.height = 45
            background.frame = backFrame
            
            var topFrame = contentView.bounds
            topFrame.size.height = 25
            titleLabel.frame = topFrame.insetBy(dx: textPaddingx, dy: 0)
            detailLabel.frame = topFrame.insetBy(dx: textPaddingx, dy: 0)
            
            var bottomFrame = contentView.bounds
            bottomFrame.size.height = 20
            bottomFrame.origin.y += 25
            typeLabel.frame = bottomFrame.insetBy(dx: textPaddingx, dy: 0)
        } else {
            var backFrame = contentView.bounds
            backFrame.origin.y += (backFrame.size.height - 55)
            backFrame.size.height = 55
            background.frame = backFrame
            
            var topFrame = contentView.bounds
            topFrame.origin = backFrame.origin
            topFrame.size.height = 35
            titleLabel.frame = topFrame.insetBy(dx: textPaddingx, dy: 0)
            detailLabel.frame = topFrame.insetBy(dx: textPaddingx, dy: 0)
            
            var bottomFrame = contentView.bounds
            bottomFrame.origin.y += (bottomFrame.size.height - 25)
            bottomFrame.size.height = 20
            typeLabel.frame = bottomFrame.insetBy(dx: textPaddingx, dy: 0)
        }
    }

}
