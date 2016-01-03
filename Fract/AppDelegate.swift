//
//  AppDelegate.swift
//  R2
//
//  Created by Charles Jacobs on 12/9/14.
//  Copyright (c) 2014 FloydSoft. All rights reserved.
//

import Cocoa




@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource
{
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var pathView: PathView!
    
    // Model parameters
    
    var numSides: Int = 3
    var numSubdivisions: Int = 1
    var isStar: Bool = false
    var perpExtDist: Double = 2.0
    var transExtDist: Double = 0.0
    var middleWidth: Double = 0.1
    var starInsideRadius: Double = 0.25
    var scen: Scene! = nil

    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        // Init UI stuff
        recomputeModel()
    }
    
    func recomputeModel()
    {
        scene = Scene()
        
        if numSides < 2
        {
            return;
        }    
        
        let fn = {poly in kochSubdivideGeneral(poly, perpDist: self.perpExtDist, transDist: self.transExtDist, middleWidth: self.middleWidth)}
        var originalPoly: [NSPoint] = []
        if(isStar)
        {
            //        let shape = Shape(originalPoly: makeStar(6, NSPoint(x: 50, y:50), 0, [5, 30, 10, 40])) // cool!
//            originalPoly = makeStar(numSides, NSPoint(x: 5, y:5), 0, [0.5, 3.0, 0.5, 3.0])
            originalPoly = makeStar(numSides, center: NSPoint(x: 5, y:5), startAngle: 0, radii: [1.0, starInsideRadius])
        }
        else
        {
            originalPoly = makePolygon(numSides, center: NSPoint(x: 5, y:5), startAngle: 0, radius: 1.0)
            
        }
        
        let shape = Shape(originalPoly: originalPoly)
        shape.subdivideFunc = fn
        shape.subdivisionLevel = numSubdivisions
        scene.shapes.append(shape)
        
        recomputePaths()
    }

    func applicationWillTerminate(aNotification: NSNotification)
    {
        // Insert code here to tear down your application
    }

    func recomputePaths()
    {
        scene.computePaths()

        pathView.findBoundingBox()
        
        // TODO: figure out scale
        pathView.setScale(NSSize(width: 60.0, height: 60.0))
        pathView.needsDisplay = true
    }
    
    @IBAction func modelParamsChanged(sender:NSControl)
    {
        recomputeModel()
    }
    
    @IBAction func numSubdivisionsChanged(sender: NSControl)
    {
        for shape in scene.shapes
        {
            shape.subdivisionLevel = numSubdivisions
        }
        
        recomputePaths()
    }

    var filename: String = "out.svg"
    
    @IBAction func saveSvg(sender: AnyObject)
    {
        let exporter = SVGExporter()
        let bbox = scene.getBbox()
        exporter.pageSize = bbox.size
        exporter.imageBounds = bbox
        for shape in scene.shapes
        {
            exporter.addPolyline(shape.getPoly())
        }
        
        exporter.writeToFile("/Users/cjacobs/Dev/Fract/output/" + filename)
    }
    
    var numSliders = 1
    func numberOfRowsInTableView(tableView: NSTableView) -> Int
    {
        return numSliders
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?
    {
        return NSNumber(double: 1.5)
    }

}

// TODO:
// make a model class that holds the original polygon and the subidived one
// allow user to drag the control points of original one
// (?) allow curved segments
// allow multiple original polygons with independent properties (curvy, subdiv level, scale, pos, rotation, etc.)
// add simple commands to center polys relative to each other
// add buttons to create regular polygons
// allow rotating polys
