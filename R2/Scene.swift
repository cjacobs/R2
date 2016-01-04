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
//    var shapes: [Shape] = []
    
    func computePaths()
    {
        for layer in layers.values
        {
            for shape in layer
            {
                shape.computePath()
            }
        }
    }

    func addShape(shape: Shape)
    {
        let shapeLayer = shape.layer
        if var layer = layers[shapeLayer]
        {
            layer.append(shape)
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

        var first = true
        for layer in layers.values
        {
            for shape in layer
            {
                let poly = shape.getPoly()
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
        }
        
        let size = maxPt-minPt
        return NSRect(origin: minPt, size: NSSize(width:size.x, height:size.y))
    }
}
