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
    @IBOutlet weak var modelsCollectionView: NSCollectionView!
    @IBOutlet weak var sceneItemsTableView: NSTableView!
    @IBOutlet weak var settingsOutlineView: NSOutlineView!
    
    // MARK: - Variables
    var renderer: Renderer?
    
    // MARK: - Configuration
    override func viewDidLoad() {
        super.viewDidLoad()
        initConfigure()
    }
    
    private func initConfigure() {
        renderer = Renderer(metalView: metalView)
        modelsCollectionView.dataSource = self
        modelsCollectionView.delegate = self
        sceneItemsTableView.dataSource = self
        sceneItemsTableView.delegate = self
        settingsOutlineView.dataSource = self
        settingsOutlineView.delegate = self
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

extension ViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        return NSCollectionViewItem()
    }
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    
}

extension ViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
    
}
