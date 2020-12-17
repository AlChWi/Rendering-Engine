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
        let modelsURLs = FileManager.default.subpaths(atPath: DocumentService.getModelsDirectory().absoluteString)
        modelsURLs?.forEach { modelURLString in
            guard let modelURL = URL(string: modelURLString),
                  let modelName = modelURL.pathComponents.last else { return }
            models.append(Model(assetUrl: modelURL, modelName: modelName))
        }
    }
    
    func saveModelData(name: String, fileData: Data) {
        DocumentService.checkCreateModelsDirectory()
        FileManager.default.createFile(atPath: DocumentService.getModelsDirectory().appendingPathComponent("\(name).obj").absoluteString,
                                       contents: fileData,
                                       attributes: [.type:"obj"])
    }
    
    func addNewModel(name: String, fileUrl: URL) {
        do {
            let modelData = try Data(contentsOf: fileUrl)
            saveModelData(name: name, fileData: modelData)
            models.append(Model(assetUrl: DocumentService.getModelsDirectory().appendingPathComponent("\(name).obj"), modelName: "\(name).obj"))
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
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
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
