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
    
    var r2Model: R2Model = R2Model()
    
    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        // Init UI stuff
        recomputeModel()
    }
    
    func recomputeModel()
    {
//        r2Model.recompute()
        recomputePaths()
    }

    func applicationWillTerminate(aNotification: NSNotification)
    {
        // Insert code here to tear down your application
    }

    func recomputePaths()
    {
        pathView.findBoundingBox()
        
        // TODO: figure out scale
        pathView.setScale(NSSize(width: 60.0, height: 60.0))
        pathView.needsDisplay = true
    }
    
    @IBAction func modelParamsChanged(sender:NSControl)
    {
        recomputeModel()
    }
    

    var filename: String = "out.svg"
    
    @IBAction func saveSvg(sender: AnyObject)
    {
        let scene = r2Model.scene
        let exporter = SVGExporter()
        let bbox = scene.getBbox()
        exporter.pageSize = bbox.size
        exporter.imageBounds = bbox
        
        for layer in scene.layers.values
        {
            for shape in layer
            {
                exporter.addPath(shape.path, withLayer: shape.layer, andColorIndex: shape.colorIndex)
            }
        }
        
        exporter.writeToFile("/Users/cjacobs/Dev/R2/output/" + filename)
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
