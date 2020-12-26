//
//  TouchThroughView.swift
//  Rendering Engine
//
//  Created by AlChWi on 12/26/20.
//

import Cocoa

class TouchThroughView: NSView {
    
    var filePath: String?
    let expectedExt = ["obj", "mtl"]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(sender) == true {
            self.layer?.backgroundColor = NSColor(calibratedRed: 50 / 255, green: 50 / 255, blue: 50 / 255, alpha: 0.3).cgColor
            return .copy
        } else {
            return NSDragOperation()
        }
    }
    
    fileprivate func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        guard let board = drag.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
              let path = board[0] as? String
        else { return false }
        
        let suffix = URL(fileURLWithPath: path).pathExtension
        for ext in self.expectedExt {
            if ext.lowercased() == suffix {
                return true
            }
        }
        return false
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
              let path = pasteboard[0] as? String
        else { return false }
        
        self.filePath = path
        if !path.hasPrefix("file://") {
            self.filePath = "file://" + path
        }
        if let filePath = filePath,
           let pathURL = URL(string: filePath) {
            ModelsService.shared.addNewModel(name: pathURL.pathComponents.last ?? "ModelName error", fileUrl: pathURL)
            NotificationCenter.default.post(name: .init("didAddModel"), object: nil)
        }
        
        return true
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        let hitView = super.hitTest(point)
        if hitView == self {
            return nil
        } else {
            return hitView
        }
    }
}
