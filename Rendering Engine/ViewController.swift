//
//  ViewController.swift
//  Rendering Engine
//
//  Created by AlChWi on 12/16/20.
//

import MetalKit

class ViewController: NSViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var metalView: MTKView!
    
    // MARK: - Variables
    var renderer: Renderer?
    
    // MARK: - Configuration
    override func viewDidLoad() {
        super.viewDidLoad()
        initConfigure()
    }
    
    private func initConfigure() {
        renderer = Renderer(metalView: metalView)
        addGestureRecognizers(to: metalView)
    }
}

extension ViewController {
    func addGestureRecognizers(to view: NSView) {
        let pan = NSPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        view.addGestureRecognizer(pan)
    }
    
    @objc func handlePan(gesture: NSPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        let delta = float2(Float(translation.x),
                           Float(translation.y))
        
        renderer?.camera.rotate(delta: delta)
        gesture.setTranslation(.zero, in: gesture.view)
    }
    
    override func scrollWheel(with event: NSEvent) {
        renderer?.camera.zoom(delta: Float(event.deltaY))
    }
}
