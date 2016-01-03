//
//  Scene.swift
//  R2
//
//  Created by Charles Jacobs on 12/12/14.
//  Copyright (c) 2014 FloydSoft. All rights reserved.
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
    var originalPolygon: Polygon = []
    var subdivisionLevel: Int = 0
    var path: NSBezierPath!
    var subdivideFunc: ([NSPoint]) -> [NSPoint] = kochSubdivide
    
    init(originalPoly: Polygon)
    {
        originalPolygon = originalPoly;
        super.init()
    }
    
    func getPoly() -> Polygon
    {
        var newPoly = originalPolygon
        for iter in 0 ..< subdivisionLevel
        {
            newPoly = subdividePoly(newPoly, subFn: subdivideFunc)
        }
        return newPoly
    }
    
    func computePath()
    {
        let newPoly = getPoly()
        path = getPath(newPoly)
    }
}

class Scene: NSObject
{
    var shapes: [Shape] = []
    
    func computePaths()
    {
        for shape in shapes
        {
            shape.computePath()
        }
    }

    func getBbox() -> NSRect
    {
        var minPt = shapes[0].getPoly()[0]
        var maxPt = minPt
        
        for shape in shapes
        {
            let poly = shape.getPoly()
            for pt in poly
            {
                minPt = NSPoint(x: min(minPt.x, pt.x), y: min(minPt.y, pt.y))
                maxPt = NSPoint(x: max(maxPt.x, pt.x), y: max(maxPt.y, pt.y))
            }
        }
        
        let size = maxPt-minPt
        return NSRect(origin: minPt, size: NSSize(width:size.x, height:size.y))
    }
}