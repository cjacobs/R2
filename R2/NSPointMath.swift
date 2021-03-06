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
    let x = Double(v.x)
    let y = Double(v.y)
    return sqrt(x*x + y*y)
}

func normalize(v: NSPoint) -> NSPoint
{
    return v / length(v);
}

func + (left: NSPoint, right: NSPoint) -> NSPoint
{
    return NSPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: NSPoint, right: NSPoint) -> NSPoint
{
    return NSPoint(x: left.x - right.x, y: left.y - right.y)
}

prefix func - (v:NSPoint) -> NSPoint
{
    return NSPoint(x: -v.x, y: -v.y)
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

func += (inout left: NSPoint, right: NSPoint)
{
    left = left + right
}

func -= (inout left: NSPoint, right: NSPoint)
{
    left = left - right
}

func *= (inout left: NSPoint, right: Double)
{
    left = left * right
}

func /= (inout left: NSPoint, right: Double)
{
    left = left / right
}


// this should go in some other file:
func chordLength(angle: Double) -> Double
{
    return 2.0 * sin(angle/2.0)
}