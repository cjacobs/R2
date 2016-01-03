//
//  R2Model.swift
//  R2
//
//  Created by Charles Jacobs on 12/11/14.
//  Copyright (c) 2014 FloydSoft. All rights reserved.
//

import Cocoa

// utility function for generating polygons
func makePolygon(numSides: Int, center: NSPoint, startAngle: Double, radius: Double) -> Polygon
{
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
    
    return pts
}

// utility function for generating polygons
func makeStar(numSides: Int, center: NSPoint, startAngle: Double, radii: [Double]) -> Polygon
{
    var pts: Polygon = []
    var angle = startAngle
    for index in 0 ..< 2*numSides
    {
        let radius = radii[index % radii.count]
        let x = CGFloat(radius * cos(angle))
        let y = CGFloat(radius * sin(angle))
        pts.append(NSPoint(x:x, y:y) + center)
        
        angle += 2.0*M_PI / Double(2*numSides);
    }
    
    // close the path
    pts.append(pts[0])
    
    return pts
}

// segment has 2 points
func kochSubdivide(segment: [NSPoint]) -> [NSPoint]
{
    return kochSubdivideGeneral(segment, perpDist: 1.0, transDist: 0.0, middleWidth: 1.0/3.0)
}

// pass in 1 for perpDist, 0 for transDist, and 0.333 for middleWidth to get normal Koch snowflake

func kochSubdivideGeneral(segment: [NSPoint], perpDist: Double, transDist: Double, middleWidth: Double) -> [NSPoint]
{
    var result = [NSPoint]()
    let pStart = segment[0]
    let pEnd = segment[1]
    let pMid = (pStart+pEnd) / 2.0
    var perp = perpVec(pEnd-pStart)
    let edgeLen = length(perp)
    let edgeVec = (pEnd-pStart)
    var edgeDir = edgeVec / edgeLen
    perp = perp / edgeLen
    let frac = (1.0-middleWidth)/2.0
    let p1 = (((1.0-frac)*pStart) + (frac*pEnd))
    let p2 = ((frac*pStart) + ((1.0-frac)*pEnd))
    let newMid = pMid + (middleWidth*edgeLen)*sin(M_PI/3.0)*perpDist*perp + transDist*edgeVec
    result.append(pStart)
    result.append(p1)
    result.append(newMid)
    result.append(p2)
    result.append(pEnd)
    return result
}


func subdividePoly(poly: [NSPoint], subFn: [NSPoint]->[NSPoint]) -> [NSPoint]
{
    var result = [NSPoint]()
    for index in 1 ..< poly.count
    {
        let prevPt = poly[index-1]
        let pt = poly[index]
        var newSeg = subFn([prevPt, pt])
        result.appendContentsOf(newSeg[0..<newSeg.count-1])
    }
    result.append(poly.last!)
    return result
}