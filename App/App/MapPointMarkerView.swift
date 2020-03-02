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
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let mapPoint = newValue as? MapDepositionPoint else { return }
            
            canShowCallout = true
            animatesWhenAdded = true
            markerTintColor = mapPoint.color
            glyphText = mapPoint.glyph
            leftCalloutAccessoryView = nil
            
            ImageCache.shared.obtainImage(mapPoint) { result in
                guard let result = result else { return }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    guard let currentPoint = self.annotation as? MapDepositionPoint,
                    currentPoint === mapPoint else { return }
                    
                    let imageView = UIImageView(image: result)
                    imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                    
                    self.leftCalloutAccessoryView = imageView
                }
            }
        }
    }
}
