//
//  GlyfPointAnnotation.swift
//  Glyf
//
//  Created by Philip Chacko on 9/2/15.
//  Copyright (c) 2015 Phil Chacko. All rights reserved.
//

import UIKit
import MapKit

class GlyfPointAnnotation: MKPointAnnotation {
    var screenname = ""
    var screenimage = ""
    var imageName: String!
    var linkUrl: String!
    var postText = ""
    var heartCount = 0
    var heartedBy = [String]()
    var heartedByUser = false
    var viewedByUser = false
    var objectId = ""
    
    func reset() {
        screenname = ""
        screenimage = ""
        imageName = ""
        linkUrl = ""
        postText = ""
        heartCount = 0
        heartedBy = [""]
        heartedByUser = false
        viewedByUser = false
        objectId = ""
    }
}
/*
class GlyfAnnotationView: MKAnnotationView {
    override init!(annotation: MKAnnotation!, reuseIdentifier: String!) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        /*
        var rect = CGRect()
        rect.size.height = self.image.size.height * 3
        rect.size.width = self.image.size.width * 3
        rect.origin = CGPoint(x: 0, y: 0)
        UIGraphicsBeginImageContext(rect.size)
        self.image.drawInRect(rect)
        var resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.image = resizedImage
        */
        
        
        //self.image.size = CGSizeMake(64, 78)
        //self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.width * 3, self.frame.height * 3)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}*/