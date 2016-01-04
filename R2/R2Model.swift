//
//  R2Model.swift
//  R2
//
//  Created by Charles Jacobs on 12/11/14.
//  Copyright (c) 2014 FloydSoft. All rights reserved.
//

import Cocoa

// utility function for generating polygons
func getR2Model() -> Scene
{
    var scene: Scene = Scene()

    // add left edge
    
    // add bottom
    
    // add right edge
    
    // add top
    
    // add interior cutouts
    
    // add leg 1
    
    // add leg 2
    
    /*
    var pts: Polygon = []

    var angle = startAngle
    for _ in 0 ..< numSides
    {
        let x = CGFloat(radius * cos(angle))
        let y = CGFloat(radius * sin(angle))
        pts.append(NSPoint(x:x, y:y) + center)
        
        angle += 2.0*M_PI / Double(numSides);
    }
    
    // close the path
    pts.append(pts[0])
    
    var shape = Shape(pts)
    scene.addShape(shape)
  */  
    return scene
}

