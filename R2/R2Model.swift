//
//  R2Model.swift
//  R2
//
//  Created by Charles Jacobs on 12/11/14.
//  Copyright (c) 2014 FloydSoft. All rights reserved.
//

import Cocoa


class R2Model : NSObject
{
    var scene: Scene = Scene()
    
    // Global model parameters
    let slotFlapWidth = 6.0
    let tabWidth = 6.0
    let tabDepth = 4.0
    let minTabOffset = 1.0
    
    // Body model parameters
    let numBodySegments = 4
    let isCylinder = false
    let bodyHeight = 67.5
    let bodyRadius = 28.1
    let legOffset = 7.0
    
    // Head parameters
    let numDomeSegments = 5

    // Leg model parameters
    let legFlapWidth = 2.0
    let legRadius = 11.6
    let legTopExtraHeight = 16.5
    let legTransitionHeight = 4.7
    let legWidth = 13.7
    let legDepth = 4.0
    let legBottomHeight = 44.3
    let footWidth = 42.6
    let footHeight = 15.7
    
    override init()
    {
        super.init()

        computeR2Model()
    }
        
    func addLeftEdge()
    {
        let origin = NSPoint(x:0, y:0)
        
        let cutPath = NSBezierPath()
        
        cutPath.moveToPoint(origin)
        cutPath.relativeLineToPoint(NSPoint(x: -slotFlapWidth, y: 0))
        cutPath.relativeLineToPoint(NSPoint(x: 0, y: bodyHeight))
        cutPath.relativeLineToPoint(NSPoint(x: slotFlapWidth, y: 0))

        // Add slots
        cutPath.moveToPoint(origin + NSPoint(x:-1.0, y: minTabOffset))
        cutPath.relativeLineToPoint(NSPoint(x:0, y: tabWidth))
        
        cutPath.moveToPoint(origin + NSPoint(x:-1.0, y:(bodyHeight-tabWidth)/2.0))
        cutPath.relativeLineToPoint(NSPoint(x:0, y:tabWidth))
        
        cutPath.moveToPoint(origin + NSPoint(x:-1.0, y:bodyHeight-tabWidth-minTabOffset))
        cutPath.relativeLineToPoint(NSPoint(x:0, y:tabWidth))
    
        scene.addShape(Shape(path: cutPath, layer: "cut", colorIndex: 0))
    }

    func bodySegmentWidth() -> Double
    {
        let pi = M_PI
        let w = chordLength(2.0*pi / Double(numBodySegments)) * bodyRadius
        print("Body segment width: ", w)
        return w
    }

    func totalBodyWidth() -> Double
    {
        return bodySegmentWidth() *  Double(numBodySegments)
    }
    
    func addBottomEdge()
    {
        let totalWidth = totalBodyWidth()
        let cutPath = NSBezierPath()
        let origin = NSPoint(x: 0, y: bodyHeight)
        cutPath.moveToPoint(origin)
        cutPath.relativeLineToPoint(NSPoint(x:totalWidth, y:0))
        
        scene.addShape(Shape(path: cutPath, layer: "cut", colorIndex: 0))
    }

    func addRightEdge()
    {
        let totalWidth = totalBodyWidth()
        let cutPath = NSBezierPath()
        let origin = NSPoint(x:totalWidth, y: 0)

        cutPath.moveToPoint(origin)
        cutPath.relativeLineToPoint(NSPoint(x: tabDepth, y: 0))
        cutPath.relativeLineToPoint(NSPoint(x: 0, y: tabWidth))
        cutPath.relativeLineToPoint(NSPoint(x: -tabDepth, y: 0))
        
        cutPath.lineToPoint(origin + NSPoint(x:0, y: (bodyHeight-tabWidth)/2.0))
        cutPath.relativeLineToPoint(NSPoint(x: tabDepth, y: 0))
        cutPath.relativeLineToPoint(NSPoint(x: 0, y: tabWidth))
        cutPath.relativeLineToPoint(NSPoint(x: -tabDepth, y: 0))
        
        cutPath.lineToPoint(origin + NSPoint(x:0, y: bodyHeight-tabWidth))
        cutPath.relativeLineToPoint(NSPoint(x: tabDepth, y: 0))
        cutPath.relativeLineToPoint(NSPoint(x: 0, y: tabWidth))
        cutPath.relativeLineToPoint(NSPoint(x: -tabDepth, y: 0))
        
        scene.addShape(Shape(path: cutPath, layer: "cut", colorIndex: 0))
        
    }

    func getDomeOutline() -> NSBezierPath
    {
        let pi = M_PI
        let segmentWidth = bodySegmentWidth()
        let cutPath = NSBezierPath()
        cutPath.moveToPoint(NSPoint(x: 0,y: 0))
        
        let domeSegmentHeight = chordLength(pi / (2.0*Double(numDomeSegments))) * bodyRadius

        // stepping up
        for pointIndex in 1 ..< numDomeSegments
        {
            let angle = Double(pointIndex) * pi / (2.0 * Double(numDomeSegments))
            let domeSegmentWidth = segmentWidth * cos(angle)
            cutPath.lineToPoint(NSPoint(x: (segmentWidth-domeSegmentWidth)/2.0, y: -Double(pointIndex)*domeSegmentHeight))
        }

        // stepping down
        for pointIndex in (0 ... numDomeSegments).reverse()
        {
            let angle = Double(pointIndex) * pi / (2.0 * Double(numDomeSegments))
            let domeSegmentWidth = segmentWidth * cos(angle)
            cutPath.lineToPoint(NSPoint(x: (segmentWidth+domeSegmentWidth)/2.0, y: -Double(pointIndex)*domeSegmentHeight))
        }

        return cutPath
    }
    
    func getDomeFoldLines() -> NSBezierPath
    {
        let pi = M_PI
        let segmentWidth = chordLength(2.0*pi / Double(numBodySegments)) * bodyRadius
        let foldPath = NSBezierPath()
        foldPath.moveToPoint(NSPoint(x: 0,y: 0))
        
        let domeSegmentHeight = chordLength(pi / (2.0*Double(numDomeSegments))) * bodyRadius
        
        // stepping up
        for pointIndex in 0 ..< numDomeSegments
        {
            let angle = Double(pointIndex) * pi / (2.0 * Double(numDomeSegments))
            let domeSegmentWidth = segmentWidth * cos(angle)
            foldPath.moveToPoint(NSPoint(x: (segmentWidth-domeSegmentWidth)/2.0, y: -Double(pointIndex)*domeSegmentHeight))
            foldPath.lineToPoint(NSPoint(x: (segmentWidth+domeSegmentWidth)/2.0, y: -Double(pointIndex)*domeSegmentHeight))
        }
        
        return foldPath
    }
    
    func addTopEdge()
    {
        let pi = M_PI
        let cutPath = NSBezierPath()
        let foldPath = NSBezierPath()

        let domeOutline = getDomeOutline()
        let domeFolds = getDomeFoldLines()
        
        let xform = NSAffineTransform()
        xform.translateXBy(0, yBy: 0)
        let segmentWidth = chordLength(2.0*pi / Double(numBodySegments)) * bodyRadius
        for _ in 0 ..< numBodySegments
        {
            cutPath.appendBezierPath(xform.transformBezierPath(domeOutline))
            foldPath.appendBezierPath(xform.transformBezierPath(domeFolds))
            xform.translateXBy(CGFloat(segmentWidth), yBy: 0.0)
        }
        
        foldPath.moveToPoint(NSPoint(x: 0,y: 0))
        foldPath.relativeLineToPoint(NSPoint(x:totalBodyWidth(), y: 0))

        scene.addShape(Shape(path: cutPath, layer: "cut", colorIndex: 0))
        scene.addShape(Shape(path: foldPath, layer: "fold", colorIndex: 1))
        
    }

    func addInterior()
    {
        let pi = M_PI
        let segmentWidth = chordLength(2.0*pi / Double(numBodySegments)) * bodyRadius
        let foldPath = NSBezierPath()
        for segmentIndex in 0 ... numBodySegments
        {
            foldPath.moveToPoint(NSPoint(x: Double(segmentIndex)*segmentWidth, y: 0))
            foldPath.relativeLineToPoint(NSPoint(x: 0, y: bodyHeight))
        }
        
        scene.addShape(Shape(path: foldPath, layer: "fold", colorIndex: 1))
    }
    
    func getLegCutoutPath() -> NSBezierPath
    {
        let segmentWidth = bodySegmentWidth()
        let path = NSBezierPath()

        // horizontal cuts
        path.moveToPoint(NSPoint(x: segmentWidth / 2.0 - legRadius, y: legOffset))
        path.relativeLineToPoint(NSPoint(x: 2 * legRadius, y: 0))

        path.moveToPoint(NSPoint(x: segmentWidth / 2.0 - legRadius, y: legOffset + legTopExtraHeight))
        path.relativeLineToPoint(NSPoint(x: 2 * legRadius, y: 0))

        // vertical cuts (TODO: tabs)
        path.moveToPoint(NSPoint(x: segmentWidth / 2.0 - legRadius + legDepth, y: legOffset))
        path.relativeLineToPoint(NSPoint(x: 0, y: legTopExtraHeight))

        path.moveToPoint(NSPoint(x: segmentWidth / 2.0 + legRadius - legDepth, y: legOffset))
        path.relativeLineToPoint(NSPoint(x: 0, y: legTopExtraHeight))

        
        // horizontal cuts
        path.moveToPoint(NSPoint(x: (segmentWidth - legWidth) / 2.0, y: legOffset + legTopExtraHeight + legTransitionHeight))
        path.relativeLineToPoint(NSPoint(x: legWidth, y: 0))

        path.moveToPoint(NSPoint(x: (segmentWidth - legWidth) / 2.0, y: bodyHeight - legTransitionHeight))
        path.relativeLineToPoint(NSPoint(x: legWidth, y: 0))

        // vertical cuts (TODO: tabs)
        path.moveToPoint(NSPoint(x: (segmentWidth - legWidth) / 2.0 + legDepth, y: legOffset + legTopExtraHeight + legTransitionHeight))
        path.lineToPoint(NSPoint(x: (segmentWidth - legWidth) / 2.0 + legDepth, y: bodyHeight - legTransitionHeight))

        path.moveToPoint(NSPoint(x: (segmentWidth + legWidth) / 2.0 - legDepth, y: legOffset + legTopExtraHeight + legTransitionHeight))
        path.lineToPoint(NSPoint(x: (segmentWidth + legWidth) / 2.0 - legDepth, y: bodyHeight - legTransitionHeight))

        return path
    }
    
    func getLegCutoutFoldPath() -> NSBezierPath
    {
        let segmentWidth = bodySegmentWidth()
        let path = NSBezierPath()
        
        // vertical folds
        path.moveToPoint(NSPoint(x: segmentWidth / 2.0 - legRadius, y: legOffset))
        path.relativeLineToPoint(NSPoint(x: 0, y: legTopExtraHeight))

        path.moveToPoint(NSPoint(x: segmentWidth / 2.0 + legRadius, y: legOffset))
        path.relativeLineToPoint(NSPoint(x: 0, y: legTopExtraHeight))
        
        
        // vertical folds
        
        // vertical folds
        path.moveToPoint(NSPoint(x: (segmentWidth - legWidth) / 2.0, y: legOffset + legTopExtraHeight + legTransitionHeight))
        path.lineToPoint(NSPoint(x: (segmentWidth - legWidth) / 2.0, y: bodyHeight - legTransitionHeight))
        
        path.moveToPoint(NSPoint(x: (segmentWidth + legWidth) / 2.0, y: legOffset + legTopExtraHeight + legTransitionHeight))
        path.lineToPoint(NSPoint(x: (segmentWidth + legWidth) / 2.0, y: bodyHeight - legTransitionHeight))
        
        return path
    }

    func addLegCutouts()
    {
        let segmentWidth = bodySegmentWidth()

        let cutoutPath = NSBezierPath()
        let foldPath = NSBezierPath()
        let legCutoutPath = getLegCutoutPath()
        let legFoldPath = getLegCutoutFoldPath()

        let xform = NSAffineTransform()

        xform.translateXBy(CGFloat((Double(numBodySegments)/2.0 - 1.0) * segmentWidth), yBy: 0)
        cutoutPath.appendBezierPath(xform.transformBezierPath(legCutoutPath))
        foldPath.appendBezierPath(xform.transformBezierPath(legFoldPath))

        xform.translateXBy(CGFloat((Double(numBodySegments)/2.0) * segmentWidth), yBy: 0)
        cutoutPath.appendBezierPath(xform.transformBezierPath(legCutoutPath))
        foldPath.appendBezierPath(xform.transformBezierPath(legFoldPath))

        scene.addShape(Shape(path: cutoutPath, layer: "cut", colorIndex: 0))
        scene.addShape(Shape(path: foldPath, layer: "fold", colorIndex: 1))
    }

    // TODO: rotate these to be in the same coord space as body, then just rotate the result if needed for layout
    func getLegCutPath() -> NSBezierPath
    {
        // let legBottomFlapHeight = 0.75 * legBottomHeight;
        let x = legOffset + legRadius + legTopExtraHeight;
        let legBottomFlapHeight = bodyHeight - x - legTransitionHeight
        let legBottomNoFlapHeight = legBottomHeight - legBottomFlapHeight
        
        let legPath = NSBezierPath()
        let endAngle = 255.0 // degrees
        let endAngleDiffRad = (270.0-endAngle) * 2.0 * M_PI / 360.0
        legPath.appendBezierPathWithArcWithCenter(NSPoint(x:legRadius, y: legRadius), radius: CGFloat(legRadius), startAngle: 90, endAngle: CGFloat(endAngle))

        // patch to wrap around top
        let legTopCirc = M_PI * legRadius;
        let legPatchStartX = sin(endAngleDiffRad) * legRadius
        legPath.lineToPoint(NSPoint(x: legRadius - legPatchStartX,y: 0))
        legPath.relativeLineToPoint(NSPoint(x: -(legTopCirc-legPatchStartX-tabWidth), y: 0))
        legPath.relativeLineToPoint(NSPoint(x: 0, y: tabDepth))
        legPath.relativeLineToPoint(NSPoint(x: -tabWidth, y: 0))
        legPath.relativeLineToPoint(NSPoint(x: 0, y: -tabDepth))
        legPath.relativeLineToPoint(NSPoint(x: 0, y: -legDepth))
        legPath.relativeLineToPoint(NSPoint(x: legTopCirc, y: 0))
        legPath.relativeLineToPoint(NSPoint(x: 0, y: legDepth))

        // upper leg
        legPath.moveToPoint(NSPoint(x:legRadius, y: 0))
        legPath.relativeLineToPoint(NSPoint(x:0, y: -legFlapWidth))
        legPath.relativeLineToPoint(NSPoint(x:legTopExtraHeight, y:0))
        legPath.relativeLineToPoint(NSPoint(x:0, y: legFlapWidth))
        legPath.relativeLineToPoint(NSPoint(x:legTransitionHeight, y:(2*legRadius - legWidth)/2))
        // lower leg
        legPath.relativeLineToPoint(NSPoint(x:0, y: -legFlapWidth))
        legPath.relativeLineToPoint(NSPoint(x:legBottomFlapHeight, y:0)) // problem: dont want this flap to extend all the way down
        legPath.relativeLineToPoint(NSPoint(x:0, y: legFlapWidth))
        legPath.relativeLineToPoint(NSPoint(x:legBottomNoFlapHeight, y:0)) // problem: dont want this flap to extend all the way down
        
        legPath.relativeLineToPoint(NSPoint(x:footHeight, y: -(footWidth-legWidth)/2))
        legPath.relativeLineToPoint(NSPoint(x:0, y:footWidth))
        
        // upper leg
        legPath.moveToPoint(NSPoint(x:legRadius, y: 2*legRadius))
        legPath.relativeLineToPoint(NSPoint(x:0, y: legFlapWidth))
        legPath.relativeLineToPoint(NSPoint(x:legTopExtraHeight, y:0))
        legPath.relativeLineToPoint(NSPoint(x:0, y: -legFlapWidth))
        legPath.relativeLineToPoint(NSPoint(x:legTransitionHeight, y:-(2*legRadius - legWidth)/2))
        // lower leg
        legPath.relativeLineToPoint(NSPoint(x:0, y: legFlapWidth))
        legPath.relativeLineToPoint(NSPoint(x:legBottomFlapHeight, y:0)) // problem
        legPath.relativeLineToPoint(NSPoint(x:0, y: -legFlapWidth))
        legPath.relativeLineToPoint(NSPoint(x:legBottomNoFlapHeight, y:0)) // problem
        legPath.relativeLineToPoint(NSPoint(x:footHeight, y: (footWidth-legWidth)/2))
        
        
        // TODO: bottom of foot
        // other side of foot
        // upper edges of foot
        
        return legPath
    }

    func getLegFoldPath() -> NSBezierPath
    {
        let legPath = NSBezierPath()

        // TODO: add fold for tab on wraparound patch
        
        legPath.moveToPoint(NSPoint(x:legRadius, y: 0))
        legPath.relativeLineToPoint(NSPoint(x:legTopExtraHeight, y:0))
        legPath.relativeLineToPoint(NSPoint(x:legTransitionHeight, y:(2*legRadius - legWidth)/2))
        legPath.relativeLineToPoint(NSPoint(x:legBottomHeight, y:0))
        legPath.relativeLineToPoint(NSPoint(x:footHeight, y: -(footWidth-legWidth)/2))
        legPath.relativeLineToPoint(NSPoint(x:0, y:footWidth))
        
        legPath.moveToPoint(NSPoint(x:legRadius, y: 2*legRadius))
        legPath.relativeLineToPoint(NSPoint(x:legTopExtraHeight, y:0))
        legPath.relativeLineToPoint(NSPoint(x:legTransitionHeight, y:-(2*legRadius - legWidth)/2))
        legPath.relativeLineToPoint(NSPoint(x:legBottomHeight, y:0))
        legPath.relativeLineToPoint(NSPoint(x:footHeight, y: (footWidth-legWidth)/2))
        
        return legPath
    }

    func addLegs()
    {
        let cutPath = NSBezierPath()
        let foldPath = NSBezierPath()
        let legCutPath = getLegCutPath()
        let legFoldPath = getLegFoldPath()
        let xform = NSAffineTransform()
        xform.translateXBy(0, yBy: CGFloat(bodyHeight*1.2))
        cutPath.appendBezierPath(xform.transformBezierPath(legCutPath))
        foldPath.appendBezierPath(xform.transformBezierPath(legFoldPath))

        xform.translateXBy(1.1*legCutPath.bounds.width, yBy: 0)
        cutPath.appendBezierPath(xform.transformBezierPath(legCutPath))
        foldPath.appendBezierPath(xform.transformBezierPath(legFoldPath))

        scene.addShape(Shape(path: cutPath, layer: "cut", colorIndex: 0))
        scene.addShape(Shape(path: foldPath, layer: "fold", colorIndex: 1))
    }

    // utility function for generating polygons
    func computeR2Model()
    {
        addLeftEdge()
        
        addBottomEdge()
        
        addRightEdge()

        addTopEdge()

        addInterior()
        
        addLegCutouts()

        addLegs()
    }

}