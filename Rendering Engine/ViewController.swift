//
//  ViewController.swift
//  Rendering Engine
//
//  Created by AlChWi on 12/16/20.
//

import MetalKit

class ViewController: NSViewController, SettingsChangeViewControllerDelegate {
    func changeValueOfSetting(_ data: Any?,
                              dataIndex: Int,
                              dataType: Any?,
                              xVal: Float,
                              yVal: Float,
                              zVal: Float) {
        if let data = data as? Model {
            guard let model = renderer?.models[dataIndex],
                  let dataType = dataType as? ModelSetting else { return }
            switch dataType {
            case .position:
                model.position = [xVal, yVal, zVal]
            case .rotation:
                model.rotation = [xVal, yVal, zVal]
            case .scale:
                model.scale = [xVal, yVal, zVal]
            default:
                return
            }
        } else if let data = data as? Light {
            guard let renderer = renderer,
                  let dataType = dataType as? LightSetting,
                  dataIndex < renderer.lighting.lights.count else { return }
           	 switch dataType {
            case .attenuation:
                renderer.lighting.lights[dataIndex].attenuation = [xVal, yVal, zVal]
            case .color:
                renderer.lighting.lights[dataIndex].color = [xVal, yVal, zVal]
            case .intensity:
                renderer.lighting.lights[dataIndex].intensity = xVal
            case .lightType:
                renderer.lighting.lights[dataIndex].type = LightType(rawValue: LightType.RawValue(Int(xVal)))
            case .position:
                renderer.lighting.lights[dataIndex].position = [xVal, yVal, zVal]
            default:
                return
            }
        }
        settingsTableView.reloadData()
    }
    
    
    // MARK: - Outlets
    @IBOutlet weak var metalView: MTKView!
    @IBOutlet weak var modelsCollectionView: NSCollectionView!
    @IBOutlet weak var sceneItemsTableView: NSTableView!
    @IBOutlet weak var settingsTableView: NSTableView!
    
    // MARK: - Variables
    var renderer: Renderer?
    
    private var selectedSceneItem: Any?
    
    // MARK: - Configuration
    override func viewDidLoad() {
        super.viewDidLoad()
        initConfigure()
    }
    
    private func initConfigure() {
        renderer = Renderer(metalView: metalView)
        ModelsService.shared.fetchModels()
        modelsCollectionView.dataSource = self
        modelsCollectionView.delegate = self
        sceneItemsTableView.dataSource = self
        sceneItemsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.delegate = self
        addGestureRecognizers(to: metalView)
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 160.0, height: 140.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        modelsCollectionView.collectionViewLayout = flowLayout
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didAddModel),
            name: .init("didAddModel"),
            object: nil)
    }
    
    @objc
    private func didAddModel() {
        modelsCollectionView.reloadData()
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
        return ModelsService.shared.models.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ModelPreview"), for: indexPath) as? ModelPreview else { fatalError("failed to reuse ModelPreview") }
        
        cell.configure(with: ModelsService.shared.models[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        indexPaths.forEach { indexPath in
            collectionView.item(at: indexPath)?.view.layer?.backgroundColor = .init(red: 255, green: 255, blue: 255, alpha: 0.4)
        }
        if let indexPath = indexPaths.first {
            renderer?.models.append(ModelsService.shared.models[indexPath.item])
            sceneItemsTableView.reloadData()
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
        if tableView == settingsTableView {
            guard let selectedItem = selectedSceneItem else { return 0 }
            switch selectedItem {
            case is Model:
                return ModelSetting.casesCount()
            case is Light:
                return LightSetting.casesCount()
            default:
                return 0
            }
        }
        
        return (renderer?.lighting.lights.count ?? 0) + (renderer?.models.count ?? 0)
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableView == settingsTableView {
            return nil
            guard let selectedItem = selectedSceneItem else { return nil }
            if let selectedItem = selectedItem as? Model {
                switch row {
                case 0:
                    return ModelSetting.position
                case 1:
                    return ModelSetting.rotation
                case 2:
                    return ModelSetting.scale
                case 3:
                    return ModelSetting.delete
                default:
                    return nil
                }
            } else if let selectedItem = selectedItem as? Light {
                switch row {
                case 0:
                    return LightSetting.position
                case 1:
                    return LightSetting.lightType
                case 2:
                    return LightSetting.intensity
                case 3:
                    return LightSetting.attenuation
                case 4:
                    return LightSetting.color
                case 5:
                    return LightSetting.delete
                default:
                    return nil
                }
            }
            return nil
        }
        
        guard let renderer = renderer else { return nil }
        if renderer.models.isEmpty {
            if !renderer.lighting.lights.isEmpty {
                return "light \(row)"
            }
            return nil
        }
        if row > renderer.models.count - 1 {
            if !renderer.lighting.lights.isEmpty {
                return "light \(row - renderer.models.count)"
            }
            return nil
        }
        return "model \(renderer.models[row].name)"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == settingsTableView {
            guard let selectedItem = selectedSceneItem else { return nil }
            var titeString = ""
            
            if let selectedItem = selectedItem as? Model {
                switch row {
                case 0:
                    titeString = "position \(selectedItem.position.x) \(selectedItem.position.y) \(selectedItem.position.z)"
                case 1:
                    titeString = "rotation \(selectedItem.position.x) \(selectedItem.position.y) \(selectedItem.position.z)"
                case 2:
                    titeString = "scale \(selectedItem.position.x) \(selectedItem.position.y) \(selectedItem.position.z)"
                case 3:
                    titeString = "delete"
                default:
                    return nil
                }
            } else if let selectedItem = selectedItem as? Light {
                switch row {
                case 0:
                    titeString = "position \(selectedItem.position.x) \(selectedItem.position.y) \(selectedItem.position.z)"
                case 1:
                    titeString = "lightType \(selectedItem.position.x) \(selectedItem.position.y) \(selectedItem.position.z)"
                case 2:
                    titeString = "intensity \(selectedItem.intensity)"
                case 3:
                    titeString = "attenuation \(selectedItem.position.x) \(selectedItem.position.y) \(selectedItem.position.z)"
                case 4:
                    titeString = "color \(selectedItem.position.x) \(selectedItem.position.y) \(selectedItem.position.z)"
                case 5:
                    titeString = "delete"
                default:
                    return nil
                }
            } else {
                return nil
            }
            
            return NSTextField(labelWithString: titeString)
        }
        
        guard let renderer = renderer else { return nil }
        if renderer.models.isEmpty {
            if !renderer.lighting.lights.isEmpty {
                return NSTextField(labelWithString: "light \(row)")
            }
            return nil
        }
        if row > renderer.models.count - 1 {
            if !renderer.lighting.lights.isEmpty {
                return NSTextField(labelWithString: "light \(row - renderer.models.count)")
            }
            return nil
        }
        return NSTextField(labelWithString: "model \(renderer.models[row].name)")
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else { return }
        let index = tableView.selectedRow
        
        if tableView == settingsTableView {
            guard let selectedItem = selectedSceneItem else { return }
            let settingsVC = SettingsChangeViewController()
            settingsVC.delegate = self
            settingsVC.data = selectedItem
            if let selectedItem = selectedItem as? Model {
                settingsVC.dataIndex = index
                switch index {
                case 0:
//                    return ModelSetting.position
                    settingsVC.modelDataType = ModelSetting.position
                    presentAsSheet(settingsVC)
                case 1:
//                    return ModelSetting.rotation
                    settingsVC.modelDataType = ModelSetting.rotation
                    presentAsSheet(settingsVC)
                case 2:
//                    return ModelSetting.scale
                    settingsVC.modelDataType = ModelSetting.scale
                    presentAsSheet(settingsVC)
                case 3:
//                    return ModelSetting.delete
                    if sceneItemsTableView.selectedRow < renderer?.models.count ?? 0,
                       renderer?.models.count ?? 0 > 1 {
                        renderer?.models.remove(at: sceneItemsTableView.selectedRow)
                    }
                    settingsTableView.reloadData()
                    sceneItemsTableView.reloadData()
                default:
                    return
                }
            } else if let selectedItem = selectedItem as? Light {
                if let modelsCount = renderer?.models.count {
                    settingsVC.dataIndex = index - modelsCount - 1
                }
                switch index {
                case 0:
//                    return LightSetting.position
                    settingsVC.lightDataType = LightSetting.position
                    presentAsSheet(settingsVC)
                case 1:
//                    return LightSetting.lightType
                    settingsVC.lightDataType = LightSetting.lightType
                    presentAsSheet(settingsVC)
                case 2:
//                    return LightSetting.intensity
                    settingsVC.lightDataType = LightSetting.intensity
                    presentAsSheet(settingsVC)
                case 3:
//                    return LightSetting.attenuation
                    settingsVC.lightDataType = LightSetting.attenuation
                    presentAsSheet(settingsVC)
                case 4:
//                    return LightSetting.color
                    settingsVC.lightDataType = LightSetting.color
                    presentAsSheet(settingsVC)
                case 5:
//                    return LightSetting.delete
                    if let modelsCount = renderer?.models.count,
                       sceneItemsTableView.selectedRow < modelsCount + (renderer?.lighting.lights.count ?? 0),
                       renderer?.lighting.lights.count ?? 0 > 1 {
                        renderer?.lighting.lights.remove(at: sceneItemsTableView.selectedRow - modelsCount)
                    }
                    settingsTableView.reloadData()
                    sceneItemsTableView.reloadData()
                default:
                    return
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                tableView.deselectAll(self)
            }
            return
        }
        
        guard let renderer = renderer else { return }
        selectedSceneItem = nil
        if renderer.models.isEmpty {
            if !renderer.lighting.lights.isEmpty {
                selectedSceneItem = renderer.lighting.lights[index]
            }
        } else if index > renderer.models.count - 1 {
            if !renderer.lighting.lights.isEmpty {
                selectedSceneItem = renderer.lighting.lights[index  - renderer.models.count]
            }
        } else {
            selectedSceneItem = renderer.models[index]
        }
        settingsTableView.reloadData()
    }
}
