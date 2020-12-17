//
//  ModelsService+FileService.swift
//  Rendering Engine
//
//  Created by user on 17.12.2020.
//

import AppKit

class ModelsService {
    // MARK: - Singleton
    static let shared = ModelsService()
    private init() {}
    
    // MARK: - Variables
    private(set) var models: [Model] = []
    
    // MARK: - Functions
    func fetchModels() {
        models = []
        DocumentService.checkCreateModelsDirectory()
        var modelsNames = FileManager.default.subpaths(atPath: DocumentService.getModelsDirectory().absoluteString)
        modelsNames = modelsNames?.filter({ $0.hasSuffix(".obj") })
        modelsNames?.forEach { modelName in
            let modelURL = DocumentService.getModelsDirectory().appendingPathComponent(modelName)
            models.append(Model(assetUrl: modelURL, modelName: modelName))
        }
    }
    
    func saveModelData(fileName: String, fileData: Data) {
        DocumentService.checkCreateModelsDirectory()
        FileManager.default.createFile(atPath: DocumentService.getModelsDirectory().appendingPathComponent(fileName).absoluteString,
                                       contents: fileData,
                                       attributes: nil)
    }
    
    func addNewModel(name: String, fileUrl: URL) {
        do {
            let modelData = try Data(contentsOf: fileUrl)
            saveModelData(fileName: fileUrl.pathComponents.last ?? name, fileData: modelData)
            models.append(Model(assetUrl: DocumentService.getModelsDirectory().appendingPathComponent(fileUrl.pathComponents.last ?? name), modelName: name))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchDefaultModels() {
        guard let stairsUrl = Bundle.main.url(forResource: "stairs.obj", withExtension: nil),
              let portalUrl = Bundle.main.url(forResource: "portal.obj", withExtension: nil),
              let magicUrl = Bundle.main.url(forResource: "magic.obj", withExtension: nil) else {
            fatalError("Models not found")
        }
        addNewModel(name: "stairs", fileUrl: stairsUrl)
        addNewModel(name: "portal", fileUrl: portalUrl)
        addNewModel(name: "magic", fileUrl: magicUrl)
    }
}

enum DocumentService {
    static func getDocumentsDirectory() -> URL {
        return URL(string: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path)!
    }
    
    static func getModelsDirectory() -> URL {
        return getDocumentsDirectory().appendingPathComponent("MyModels")
    }
    
    static func checkCreateModelsDirectory() {
        let modelsDirectory = getModelsDirectory()
        if !FileManager.default.fileExists(atPath: modelsDirectory.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: modelsDirectory.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
