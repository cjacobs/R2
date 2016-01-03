//
//  SVGExporter.swift
//  Fract
//
//  Created by Charles Jacobs on 12/20/14.
//  Copyright (c) 2014 FloydSoft. All rights reserved.
//

import Cocoa



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
    
    func getStringForPath(path: NSBezierPath) -> String
    {
        var components = NSMutableArray(capacity: 1)

        var pointArray = NSPointArray.alloc(3)
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
        
        var resultString = components.componentsJoinedByString(" ")
        return resultString;
    }
    
    func addPath(path: NSBezierPath)
    {
        NSLog("adding path");
        var pathNode = NSXMLElement(name:"path")
        var attributes = NSMutableDictionary(capacity: 3)
        attributes["style"] = "stroke:black; fill:none"
        attributes["stroke-width"] = "0.01"
        
        attributes["d"] = getStringForPath(path)
        pathNode.setAttributesWithDictionary(attributes)
        container.addObject(pathNode)
    }
    
    func addPolygon(poly: Polygon)
    {
        var pathNode = NSXMLElement(name:"polygon")
        var attributes = NSMutableDictionary(capacity: 3)
        attributes["style"] = "stroke:black; fill:none"
        attributes["stroke-width"] = "0.01"
        let ptStrings = map(poly) { "\($0.x),\($0.y)" }
        let pathString = " ".join(ptStrings)
        attributes["points"] = pathString
        pathNode.setAttributesWithDictionary(attributes)
        container.addObject(pathNode)
    }
    
    func addPolyline(poly: Polyline)
    {
        var pathNode = NSXMLElement(name:"polyline")
        var attributes = NSMutableDictionary(capacity: 3)
        attributes["style"] = "stroke:black; fill:none"
        attributes["stroke-width"] = "0.01"
        let ptStrings = map(poly) { "\($0.x),\($0.y)" }
        let pathString = " ".join(ptStrings)
        attributes["points"] = pathString
        pathNode.setAttributesWithDictionary(attributes)
        container.addObject(pathNode)
    }
    
    func exportToXmlNode() -> NSXMLElement
    {
        var exportNode = NSXMLElement(name: "svg");
        let viewBoxString = "\(imageBounds.origin.x) \(imageBounds.origin.y) \(imageBounds.size.width) \(imageBounds.size.height)"
        let attrib = NSXMLNode.attributeWithName("viewBox", stringValue: viewBoxString) as NSXMLNode
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
            var imageAspect = self.imageBounds.size.width / self.imageBounds.size.height;
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
        
        exportNode.addAttribute(NSXMLNode.attributeWithName("width", stringValue: "\(pageSize.width) \(units)") as NSXMLNode)
        exportNode.addAttribute(NSXMLNode.attributeWithName("height", stringValue: "\(pageSize.height) \(units)") as NSXMLNode)    
    
        var namespace = NSXMLNode.namespaceWithName("", stringValue:"http://www.w3.org/2000/svg") as NSXMLNode
        exportNode.namespaces = [namespace];
        
        let transformGroup = NSXMLElement(name:"g")
        transformGroup.addAttribute(NSXMLNode.attributeWithName("transform", stringValue:"translate(0.5,0.5)") as NSXMLNode)
        exportNode.addChild(transformGroup)
        
        for entry in self.container
        {
            if(entry.isKindOfClass(NSXMLNode))
            {
                transformGroup.addChild(entry as NSXMLNode)
            }
        }
        
        return exportNode;
    }
    
    func getXmlDocument() -> NSXMLDocument
    {
        var rootNode = self.exportToXmlNode()
        var xmlDocument = NSXMLDocument(rootElement: rootNode)
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

    func writeToFile(filename: String)
    {
        var xmlData = self.getXmlData();
        xmlData.writeToFile(filename, atomically: true)
    }
}
