//
//  Shape.swift
//  R2
//
//  Created by Charles Jacobs on 1/3/16.
//  Copyright © 2016 FloydSoft. All rights reserved.
//

import Cocoa



func getPath(poly: [NSPoint]) -> NSBezierPath
{
    let result = NSBezierPath()
    
    for index in 0 ..< poly.count-1 // skip last point (because we're going to call closePath()
    {
        let pt = poly[index]
        if index == 0
        {
            result.moveToPoint(pt)
        }
        else
        {
            result.lineToPoint(pt)
        }
    }
    
    result.closePath()
    
    return result
}

typealias Polygon = [NSPoint]
typealias Polyline = [NSPoint]

class Shape: NSObject
{
    var layer: String
    var colorIndex: Int
    var originalPolygon: Polygon = []
    var path: NSBezierPath!
    
    init(originalPoly: Polygon)
    {
        originalPolygon = originalPoly;
        layer = ""
        colorIndex = 0
        super.init()
    }
    
    init(originalPoly: Polygon, layer: String, colorIndex: Int)
    {
        self.originalPolygon = originalPoly
        self.layer = layer;
        self.colorIndex = colorIndex
    }
    
    func getPoly() -> Polygon
    {
        return originalPolygon
    }
    
    func computePath()
    {
        let newPoly = getPoly()
        path = getPath(newPoly)
    }
}
