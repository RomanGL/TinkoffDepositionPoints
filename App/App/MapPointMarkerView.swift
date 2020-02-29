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
            
            ImageCache.shared.obtainImage(mapPoint) { result in
                DispatchQueue.main.async { [weak self] in
                    let currentPoint = self?.annotation as? MapDepositionPoint
                    if currentPoint != mapPoint { return }
                    
                    switch result {
                    case .success(let image):
                        let imageView = UIImageView(image: image)
                        imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                        
                        self?.leftCalloutAccessoryView = imageView
                        
                    case .failure(_):
                        return
                    }
                }
            }
        }
    }
}
