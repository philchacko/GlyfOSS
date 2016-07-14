//
//  MapOverlayView.swift
//  Glyf
//
//  Created by Philip Chacko on 9/16/15.
//  Copyright (c) 2015 Phil Chacko. All rights reserved.
//

import UIKit

protocol MapOverlayViewDelegate {}

class MapOverlayView: UIView {
    
    var delegate: ViewController?
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if delegate?.selectedGooglePlace != nil {
            delegate?.selectedGooglePlace = nil
        }
        self.userInteractionEnabled = false
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.userInteractionEnabled = false
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.userInteractionEnabled = false
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.userInteractionEnabled = false
    }
    
    func setUserInteraction(enabled: Bool) {
        self.userInteractionEnabled = enabled
    }
    
    
    /*
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if let pointInMap = delegate?.mapView.convertPoint(point, fromView: self) {
            let inmap = delegate?.mapView.pointInside(pointInMap, withEvent: event)
            
            if inmap != nil {
                if inmap! {
                    return delegate!.mapView
                }
            }
        }
        return super.hitTest(point, withEvent: event)
    }*/
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
