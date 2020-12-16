

import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    
    var uniforms = Uniforms()
    
    let depthStencilState: MTLDepthStencilState
    
    // Camera holds view and projection matrices
    lazy var camera: Camera = {
        let camera = ArcballCamera()
        camera.distance = 2
        camera.target = [0, 1.5, 0]
        return camera
    }()
    
    // Array of Models allows for rendering multiple models
    var models: [Model] = []
    
    
    init(metalView: MTKView) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()
        metalView.device = device
        metalView.depthStencilPixelFormat = .depth32Float
        depthStencilState = Renderer.buildDepthStencilState()
        super.init()
        metalView.clearColor = MTLClearColor(red: 0,
                                             green: 0,
                                             blue: 0,
                                             alpha: 1.0)
        metalView.delegate = self
        
        // add the model to the scene
        let stairs = Model(name: "stairs.obj")
        let portal = Model(name: "portal.obj")
        let magic = Model(name: "magic.obj")
        models.append(stairs)
        models.append(portal)
        models.append(magic)
        
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
    }
    
    static func buildDepthStencilState() -> MTLDepthStencilState {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(descriptor: descriptor)!
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        camera.aspect = Float(view.bounds.width)/Float(view.bounds.height)
    }
    
    func draw(in view: MTKView) {
        guard
            let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let renderEncoder =
                commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        renderEncoder.setDepthStencilState(depthStencilState)
        
        uniforms.projectionMatrix = camera.projectionMatrix
        uniforms.viewMatrix = camera.viewMatrix
        
        // render all the models in the array
        for model in models {
            uniforms.modelMatrix = model.modelMatrix
            uniforms.normalMatrix = model.modelMatrix.upperLeft
            
            renderEncoder.setVertexBytes(&uniforms,
                                         length: MemoryLayout<Uniforms>.stride, index: 1)
            renderEncoder.setRenderPipelineState(model.pipelineState)
            
            for mesh in model.meshes {
                let vertexBuffer = mesh.mtkMesh.vertexBuffers[0].buffer
                renderEncoder.setVertexBuffer(vertexBuffer, offset: 0,
                                              index: 0)
                
                for submesh in mesh.submeshes {
                    let mtkSubmesh = submesh.mtkSubmesh
                    renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                        indexCount: mtkSubmesh.indexCount,
                                                        indexType: mtkSubmesh.indexType,
                                                        indexBuffer: mtkSubmesh.indexBuffer.buffer,
                                                        indexBufferOffset: mtkSubmesh.indexBuffer.offset)
                }
            }
        }
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
