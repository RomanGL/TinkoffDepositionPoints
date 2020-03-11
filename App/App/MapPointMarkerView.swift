//
//  MapPointMarkerView.swift
//  App
//
//  Created by r.gladkikh on 27.02.2020.
//  Copyright © 2020 r.gladkikh. All rights reserved.
//

import UIKit
import MapKit

class MapPointMarkerView: MKMarkerAnnotationView {
    private var pointAnnotation: MapDepositionPoint?
    
    override var annotation: MKAnnotation? {
        willSet {
            self.pointAnnotation = newValue as? MapDepositionPoint
            guard let pointAnnotation = pointAnnotation else { return }
            
            canShowCallout = true
            animatesWhenAdded = true
            markerTintColor = pointAnnotation.color
            glyphText = pointAnnotation.glyph
            leftCalloutAccessoryView = nil
            
            displayPriority = pointAnnotation.isHighPriority
                ? .required
                : .defaultHigh
        }
    }
    
    func loadImage() {
        guard let point = pointAnnotation else { return }
        
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.startAnimating()
        
        self.leftCalloutAccessoryView = indicator
            
        ImageCache.shared.obtainImage(point) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                guard point == self.pointAnnotation else { return }

                indicator.stopAnimating()

                let imageView = UIImageView(image: result ?? UIImage(systemName: "xmark.circle"))
                imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)

                self.leftCalloutAccessoryView = imageView
            }
        }
    }
}
