//
//  SVGExporter.swift
//  Fract
//
//  Created by Charles Jacobs on 12/20/14.
//  Copyright (c) 2014 FloydSoft. All rights reserved.
//

//
// TODO: keep list of layers, which turn into <g> nodes, I guess
//

import Cocoa

typealias Polygon = [NSPoint]
typealias Polyline = [NSPoint]

class SVGExporter: NSObject
{
    var imageBounds: NSRect = NSRect()
    var pageSize: NSSize = NSSize()
    var container: NSMutableArray = NSMutableArray(capacity:100)
    
    override init()
    {
        super.init()
    }

    func addRect(rect: NSRect)
    {
        
    }
    
    func addRect(rect: NSRect, withLayer: String, andColorIndex: Int)
    {
        
    }
    
    func addPath(path: NSBezierPath)
    {
        NSLog("adding path");
        let pathNode = NSXMLElement(name:"path")
        var attributes = [String: String]()
        attributes["style"] = "stroke:black; fill:none"
        attributes["stroke-width"] = "1"
        
        attributes["d"] = getStringForPath(path)
        pathNode.setAttributesWithDictionary(attributes)
        container.addObject(pathNode)
    }
    
    // TODO: implement layer and color stuff
    func addPath(path: NSBezierPath, withLayer: String, andColorIndex: Int)
    {
        NSLog("adding path");
        let pathNode = NSXMLElement(name:"path")
        var attributes = [String: String]()
        attributes["style"] = "stroke:black; fill:none"
        attributes["stroke-width"] = "1"
        attributes["fill"] = "none";
        
        attributes["d"] = getStringForPath(path)
        pathNode.setAttributesWithDictionary(attributes)
        container.addObject(pathNode)
    }

    func addPolygon(poly: Polygon)
    {
        let pathNode = NSXMLElement(name:"polygon")
        var attributes = [String: String]()
        attributes["style"] = "stroke:black; fill:none"
        attributes["stroke-width"] = "0.01"
        let ptStrings = poly.map { "\($0.x),\($0.y)" }
        let pathString = ptStrings.joinWithSeparator(" ")
        attributes["points"] = pathString
        pathNode.setAttributesWithDictionary(attributes)
        container.addObject(pathNode)
    }
    
    func addPolyline(poly: Polyline)
    {
        let pathNode = NSXMLElement(name:"polyline")
        var attributes = [String: String]()
        attributes["style"] = "stroke:black; fill:none"
        attributes["stroke-width"] = "0.01"
        let ptStrings = poly.map { "\($0.x),\($0.y)" }
        let pathString = ptStrings.joinWithSeparator(" ")
        attributes["points"] = pathString
        pathNode.setAttributesWithDictionary(attributes)
        container.addObject(pathNode)
    }
    
    
    func getStringForPath(path: NSBezierPath) -> String
    {
        let components = NSMutableArray(capacity: 1)

        let pointArray = NSPointArray.alloc(3)
        for index in 0 ..< path.elementCount
        {
            let elementType = path.elementAtIndex(index, associatedPoints: pointArray)
            switch(elementType)
            {
            case .MoveToBezierPathElement:
                components.addObject("M \(pointArray[0].x) \(pointArray[0].y) ")
            case .LineToBezierPathElement:
                components.addObject("L \(pointArray[0].x) \(pointArray[0].y) ")
            case .CurveToBezierPathElement:
                components.addObject("C \(pointArray[0].x) \(pointArray[0].y) \(pointArray[1].x) \(pointArray[1].y) \(pointArray[2].x) \(pointArray[2].y) ")
            case .ClosePathBezierPathElement:
                components.addObject("Z")
            default:
                NSLog("Error: unknown bezier path element");
            }
        }
        pointArray.dealloc(3);
        
        let resultString = components.componentsJoinedByString(" ")
        return resultString;
    }
    
    func writeToFile(filename: String)
    {
        let xmlData = self.getXmlData();
        xmlData.writeToFile(filename, atomically: true)
    }

    
    func exportToXmlNode() -> NSXMLElement
    {
        let exportNode = NSXMLElement(name: "svg");
        let viewBoxString = "\(imageBounds.origin.x) \(imageBounds.origin.y) \(imageBounds.size.width) \(imageBounds.size.height)"
        let attrib = NSXMLNode.attributeWithName("viewBox", stringValue: viewBoxString) as! NSXMLNode
        exportNode.addAttribute(attrib)
    
        // compute size (in inches)
        var units = "px"
        if(self.pageSize.width == 0 || self.pageSize.height == 0)
        {
            // unspecified, use image bounds
            self.pageSize = self.imageBounds.size;
        }
        else
        {
            units = "in";
            let imageAspect = self.imageBounds.size.width / self.imageBounds.size.height;
            if( imageAspect > (self.pageSize.width / self.pageSize.height))
            {
                // image bounds has wider aspect ratio than page --- constrain page width, recompute height
                self.pageSize = NSMakeSize(self.pageSize.width,  self.pageSize.width / imageAspect);
            }
            else
            {
                self.pageSize = NSMakeSize(self.pageSize.height * imageAspect, self.pageSize.height);
            }
        }
        
        exportNode.addAttribute(NSXMLNode.attributeWithName("width", stringValue: "\(pageSize.width) \(units)") as! NSXMLNode)
        exportNode.addAttribute(NSXMLNode.attributeWithName("height", stringValue: "\(pageSize.height) \(units)") as! NSXMLNode)    
    
        let namespace = NSXMLNode.namespaceWithName("", stringValue:"http://www.w3.org/2000/svg") as! NSXMLNode
        exportNode.namespaces = [namespace];
        
        let transformGroup = NSXMLElement(name:"g")
        transformGroup.addAttribute(NSXMLNode.attributeWithName("transform", stringValue:"translate(0.5,0.5)") as! NSXMLNode)
        exportNode.addChild(transformGroup)
        
        for entry in self.container
        {
            if(entry.isKindOfClass(NSXMLNode))
            {
                transformGroup.addChild(entry as! NSXMLNode)
            }
        }
        
        return exportNode;
    }
    
    func getXmlDocument() -> NSXMLDocument
    {
        let rootNode = self.exportToXmlNode()
        let xmlDocument = NSXMLDocument(rootElement: rootNode)
        xmlDocument.version = "1.0"
        xmlDocument.characterEncoding = "UTF-8"
    
        return xmlDocument;
    }
    
    func getXml() -> String
    {
        return getXmlDocument().XMLStringWithOptions(Int(NSXMLDocumentTidyXML|NSXMLNodePrettyPrint))
    }
    
    func getXmlData() -> NSData
    {
        return getXmlDocument().XMLDataWithOptions(Int(NSXMLDocumentTidyXML|NSXMLNodePrettyPrint))
    }
}
