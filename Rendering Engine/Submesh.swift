
import MetalKit

class Submesh {
    var mtkSubmesh: MTKSubmesh
    let texture: Texture
    
    init(mdlSubmesh: MDLSubmesh, mtkSubmesh: MTKSubmesh) {
        self.mtkSubmesh = mtkSubmesh
        texture = Texture(material: mdlSubmesh.material)
    }
}

extension Submesh {
    struct Texture {
        let baseColor: MTLTexture?
    }
}

private extension Submesh.Texture {
    init(material: MDLMaterial?) {
        func property(with semantic: MDLMaterialSemantic) -> MTLTexture? {
            guard let property = material?.property(with: semantic),
                property.type == .string,
                let fileName = property.stringValue,
                let texture = try? Submesh.loadTexture(imageName: fileName) else { return nil }
            return texture
        }
        baseColor = property(with: MDLMaterialSemantic.baseColor)
    }
}

extension Submesh: Texturable {}
