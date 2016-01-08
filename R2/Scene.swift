//
//  Scene.swift
//  R2
//
//  Created by Charles Jacobs on 12/12/14.
//  Copyright (c) 2014 FloydSoft. All rights reserved.
//

import Cocoa



// Ugh --- should layers be a part of the Scene class or not? Or should the shapes themselves just hold layer info?


typealias ShapeList = [Shape]

class Scene: NSObject
{
    var layers: [String: ShapeList] = [String:ShapeList]()
    
    func addShape(shape: Shape)
    {
        let shapeLayer = shape.layer
        if layers.indexForKey(shapeLayer) != nil
        {
            layers[shapeLayer]!.append(shape)
        }
        else
        {
            layers[shapeLayer] = [shape]
        }
    }
    
    func getBbox() -> NSRect
    {        
        var minPt: NSPoint = NSPoint()
        var maxPt: NSPoint = NSPoint()
        var bounds: NSRect = NSRect()
        var first = true
        for layer in layers.values
        {
            for shape in layer
            {
                let foo = shape.path
                let pathBounds = shape.path.bounds
                if first
                {
                    bounds = pathBounds
                    first = false
                }
                else
                {
                    bounds = NSUnionRect(bounds, pathBounds)
                }
/*
                
                let poly = shape.getPoly()
                
                if poly.count > 0
                {
                    if first
                    {
                        minPt = poly[0]
                        maxPt = minPt
                        first = false
                    }
                    for pt in poly
                    {
                        minPt = NSPoint(x: min(minPt.x, pt.x), y: min(minPt.y, pt.y))
                        maxPt = NSPoint(x: max(maxPt.x, pt.x), y: max(maxPt.y, pt.y))
                    }
                        
                }
*/
            }
        }
        
        
        return bounds
//        let size = maxPt-minPt
//        return NSRect(origin: minPt, size: NSSize(width:size.x, height:size.y))
    }
}
