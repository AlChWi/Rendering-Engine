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
    
    private var savedModelsCollection: [Model] = []
    
    // MARK: - Configuration
    override func viewDidLoad() {
        super.viewDidLoad()
        initConfigure()
    }
    
    private func initConfigure() {
        renderer = Renderer(metalView: metalView)
        ModelsService.shared.fetchModels()
        savedModelsCollection.append(contentsOf: ModelsService.shared.models)
        modelsCollectionView.dataSource = self
        modelsCollectionView.delegate = self
        sceneItemsTableView.dataSource = self
        sceneItemsTableView.delegate = self
        settingsOutlineView.dataSource = self
        settingsOutlineView.delegate = self
        addGestureRecognizers(to: metalView)
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 160.0, height: 140.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        modelsCollectionView.collectionViewLayout = flowLayout
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
        return savedModelsCollection.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ModelPreview"), for: indexPath) as? ModelPreview else { fatalError("failed to reuse ModelPreview") }
        
        cell.configure(with: savedModelsCollection[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        indexPaths.forEach { indexPath in
            collectionView.item(at: indexPath)?.view.layer?.backgroundColor = .init(red: 255, green: 255, blue: 255, alpha: 0.4)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            collectionView.deselectItems(at: indexPaths)
            collectionView.delegate?.collectionView?(collectionView, didDeselectItemsAt: indexPaths)
        }
    }

    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        indexPaths.forEach { indexPath in
            collectionView.item(at: indexPath)?.view.layer?.backgroundColor = .clear
        }
    }
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return (renderer?.lights.count ?? 0) + (renderer?.models.count ?? 0)
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let renderer = renderer else { return nil }
        if renderer.models.isEmpty {
            return "light \(row)"
        }
        if row > renderer.models.count - 1 {
            return "light \(row - renderer.models.count)"
        }
        return "model \(renderer.models[row].name)"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let renderer = renderer else { return nil }
        if renderer.models.isEmpty {
            return NSTextField(labelWithString: "light \(row)")
        }
        if row > renderer.models.count - 1 {
            return NSTextField(labelWithString: "light \(row - renderer.models.count)")
        }
        return NSTextField(labelWithString: "model \(renderer.models[row].name)")
    }
    
    func tableVi
}

extension ViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return nil
    }
}
