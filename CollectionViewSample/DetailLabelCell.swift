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

class DetailLabelCell: UICollectionViewCell {

    fileprivate let padding: CGFloat = 15.0

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 18)
        view.textColor = .darkText
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        self.contentView.addSubview(view)
        return view
    }()

    lazy var detailLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .right
        view.font = .systemFont(ofSize: 14)
        view.textColor = .lightGray
        self.contentView.addSubview(view)
        return view
    }()
    
    lazy var background: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.3
        self.contentView.addSubview(view)
        return view
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = contentView.bounds.insetBy(dx: padding, dy: 0)
        titleLabel.frame = frame
        detailLabel.frame = frame
        background.frame = contentView.bounds
        self.sendSubview(toBack: background)
    }
    
    
    

}
