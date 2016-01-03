//
//  NSPointMath.swift
//  Fract
//
//  Created by Charles Jacobs on 12/11/14.
//  Copyright (c) 2014 FloydSoft. All rights reserved.
//

import Foundation

func perpVec(v: NSPoint) -> NSPoint
{
    return NSPoint(x: v.y, y: -v.x)
}

func length(v: NSPoint) -> Double
{
    var x = Double(v.x)
    var y = Double(v.y)
    return sqrt(x*x + y*y)
}

func + (left: NSPoint, right: NSPoint) -> NSPoint
{
    return NSPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: NSPoint, right: NSPoint) -> NSPoint
{
    return NSPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (pt: NSPoint, s: Double) -> NSPoint
{
    return NSPoint(x: pt.x * CGFloat(s), y: pt.y * CGFloat(s))
}

func * (s: Double, pt: NSPoint) -> NSPoint
{
    return NSPoint(x: pt.x * CGFloat(s), y: pt.y * CGFloat(s))
}

func / (pt: NSPoint, s: Double) -> NSPoint
{
    return NSPoint(x: pt.x / CGFloat(s), y: pt.y / CGFloat(s))
}

