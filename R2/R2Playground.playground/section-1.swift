// Playground - noun: a place where people can play

import Cocoa
import XCPlayground

class FractView : NSView
{
    var path: NSBezierPath
    var bgColor = NSColor.whiteColor()
    
    override init(frame: NSRect)
    {
        self.path = NSBezierPath()
        super.init(frame: frame)
    }

    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawRect(dirtyRect: NSRect)
    {
        bgColor.setFill()
        NSRectFill(self.bounds)
        path.stroke()
    }
    
}

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

// segment has 2 points
func kochSubdivide(segment: [NSPoint]) -> [NSPoint]
{
    var result = [NSPoint]()
    var pStart = segment[0]
    var pEnd = segment[1]
    var pMid = (pStart+pEnd) / 2.0
    var perp = perpVec(pEnd-pStart)
    var edgeLen = length(perp)
    perp = perp / edgeLen
    var p1 = (pStart*2.0 + pEnd) / 3.0
    var p2 = (pStart + 2.0*pEnd) / 3.0
    var newMid = pMid + (edgeLen/3.0)*sin(M_PI/3.0)*perp
    result.append(pStart)
    result.append(p1)
    result.append(newMid)
    result.append(p2)
    result.append(pEnd)
    return result
}

func subdividePoly(poly: [NSPoint]) -> [NSPoint]
{
    var result = [NSPoint]()
    var isFirst = true
    var prevPt = NSPoint()
    for pt in poly
    {
        if isFirst
        {
            isFirst = false
        }
        else
        {
            var newSeg = kochSubdivide([prevPt, pt])
            result.extend(newSeg[0..<newSeg.count-1])
        }
        prevPt = pt
    }
    result.append(prevPt)
    return result
}

func getPath(poly: [NSPoint]) -> NSBezierPath
{
    var result = NSBezierPath()
    var isFirst = true
    for pt in poly
    {
        if isFirst
        {
            result.moveToPoint(pt)
            isFirst = false
        }
        else
        {
            result.lineToPoint(pt)
        }
    }
    return result
}

var fractView = FractView(frame: NSRect(x:0, y:0, width:200, height:300))

var tri = [NSPoint(x:0, y:50), NSPoint(x:100, y:50), NSPoint(x:50, y:50+100*sin(M_PI/3.0)), NSPoint(x:0, y:50)]
var k1 = subdividePoly(tri)
var k2 = subdividePoly(k1)
fractView.path = getPath(k2)

XCPShowView("fractView", fractView)

