//
//  PathView.swift
//  R2
//
//  Created by Charles Jacobs on 12/11/14.
//  Copyright (c) 2014 FloydSoft. All rights reserved.
//

import Cocoa

class PathView : NSView
{
    @IBOutlet weak var delegate: AppDelegate!
    var bgColor = NSColor.whiteColor()
    var bbox = NSRect()
    
    override init(frame: NSRect)
    {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }

    let unitSize:NSSize = NSSize(width:1.0, height: 1.0)
    // Returns the scale of the receiver's coordinate system, relative to the window's base coordinate system.
    func scale() -> NSSize
    {
        
        return self.convertSize(unitSize, toView: nil)
    }
    
    func setScale(newScale: NSSize)
    {
        self.resetScaling()
        self.scaleUnitSquareToSize(newScale)
        self.needsDisplay = true;
    }
    
    // Makes the scaling of the receiver equal to the window's base coordinate system.
    func resetScaling()
    {
        self.scaleUnitSquareToSize(self.convertSize(unitSize, fromView: nil))
    }
    
    func findBoundingBox() -> NSRect
    {
        let scene = delegate.r2Model.scene
        let bbox = scene.getBbox()
        
        return bbox
    }
    
    override func drawRect(dirtyRect: NSRect)
    {
        let model = delegate.r2Model.scene

        self.resetScaling()
        let bounds = self.bounds
        let bbox = model.getBbox()
        let xScale = bounds.width / bbox.width
        let yScale = bounds.height / bbox.height
        let minScale = min(xScale, yScale)
        setScale(NSSize(width: minScale, height: minScale))
        self.bounds.origin = bbox.origin
        // TODO: set translation
        
        for layer in model.layers.values
        {
            for shape in layer
            {
                let path = shape.path
                if(path != nil)
                {
                    let layer = shape.layer
                    if layer == "cut"
                    {
                        path.lineWidth = 0.2
                    }
                    else if layer == "fold"
                    {
                        path.lineWidth = 0.05
                        let pattern: [CGFloat] = [4.0, 2.0]
                        path.setLineDash(pattern, count: 2, phase: 0);
                    }

                    path.stroke()
                }
            }
        }
    }
}