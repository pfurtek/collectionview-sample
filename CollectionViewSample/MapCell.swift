//
//  MapCell.swift
//  CollectionViewSample
//
//  Created by Pawel Furtek on 3/12/17.
//  Copyright © 2017 Pawel Furtek. All rights reserved.
//

import UIKit
import MapKit

class MapCell: UICollectionViewCell, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    fileprivate let mapView: MKMapView = {
        let view = MKMapView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    fileprivate let pin = MKPointAnnotation()
    
    fileprivate let paddingx: CGFloat = 0.0
    fileprivate let paddingy: CGFloat = 0.0
    
    /*fileprivate let activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.startAnimating()
        return view
    }()*/
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(mapView)
        self.mapView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = contentView.bounds.insetBy(dx: paddingx, dy: paddingy)
        mapView.frame = frame
    }
    
    func setLocation(coordinates: CLLocationCoordinate2D) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        pin.coordinate = coordinates
        self.mapView.addAnnotation(pin)
        
        let span = MKCoordinateSpanMake(0.003, 0.003)
        let region = MKCoordinateRegion(center: coordinates, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    // MARK:- MKMapViewDelegate
    
}
