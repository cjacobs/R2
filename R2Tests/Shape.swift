//
//  Shape.swift
//  R2
//
//  Created by Charles Jacobs on 1/3/16.
//  Copyright © 2016 FloydSoft. All rights reserved.
//

import Cocoa

class Shape: NSObject
{
    var layer: String
    var colorIndex: Int
    var path: NSBezierPath!
    
    init(path: NSBezierPath, layer: String, colorIndex: Int)
    {
        self.path = path
        self.layer = layer
        self.colorIndex = colorIndex
    }
}
