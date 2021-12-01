//
//  RenderableWorkView.swift
//  Utilities
//
//  Created by Stephen H. Gerstacker on 2021-12-01.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

import MetalKit
import SwiftUI
import UniformTypeIdentifiers

public struct RenderableWorkView: View {
    @StateObject var animator: Animator = Animator()

    var width: Int
    var height: Int
    var frameTime: Double

    var work: ((Animator) -> ())? = nil

    public init(width: Int, height: Int, frameTime: Double, work: ((Animator) -> Void)? = nil) {
        self.width = width
        self.height = height
        self.frameTime = frameTime
        self.work = work
    }

    public var body: some View {
        RenderView(pixelBuffer: animator.latestPixelBuffer)
            .onAppear(perform: startWork)
    }

    private func startWork() {
        animator.width = width
        animator.height = height
        animator.frameTime = frameTime

        let desktopPath = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first!
        let desktopUrl = URL(fileURLWithPath: desktopPath)

        let panel = NSSavePanel()
        panel.title = "Select a save location"
        panel.allowedContentTypes = [.mpeg4Movie]
        panel.directoryURL = desktopUrl
        panel.nameFieldStringValue = "Output"
        panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))

        panel.begin { response in
            guard response == .OK else {
                return
            }

            animator.url = panel.url

            let queue = DispatchQueue(label: "us.gerstacker.RenderableWorkView")

            queue.async {
                animator.start()
                work?(animator)
                animator.complete()
            }
        }
    }
}

struct RenderView: NSViewRepresentable {

    var pixelBuffer: CVPixelBuffer? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> some NSView {
        let mtkView = MTKView()
        mtkView.clearColor = MTLClearColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.delegate = context.coordinator
        mtkView.device = context.coordinator.metalDevice
        mtkView.drawableSize = mtkView.frame.size
        mtkView.framebufferOnly = false
        mtkView.preferredFramesPerSecond = 60

        return mtkView
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        context.coordinator.pixelBuffer = pixelBuffer
    }

    class Coordinator: NSObject, MTKViewDelegate {

        struct Vertex {
            let position: vector_float2
            let texture: vector_float2

            init(x: Float, y: Float, s: Float, t: Float) {
                position = vector_float2(x, y)
                texture = vector_float2(s, t)
            }
        }

        let metalDevice: MTLDevice
        let metalCommandQueue: MTLCommandQueue
        let metalPipelineState: MTLRenderPipelineState
        let metalVertexBuffer: MTLBuffer
        let metalTextureCache: CVMetalTextureCache

        var screenSize: SIMD2<Float> = .zero
        var textureSize: SIMD2<Float> = .zero

        var currentMetalTexture: CVMetalTexture? = nil
        var currentTexture: MTLTexture? = nil

        var pixelBuffer: CVPixelBuffer? = nil

        override init() {
            metalDevice = MTLCreateSystemDefaultDevice()!
            metalCommandQueue = metalDevice.makeCommandQueue()!

            let bundle = Bundle(for: Coordinator.self)
            let library: MTLLibrary = try! metalDevice.makeDefaultLibrary(bundle: bundle)
            let vertexFunction = library.makeFunction(name: "VertexShader")
            let fragmentFunction = library.makeFunction(name: "FragmentShader")

            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.label = "Main Pipeline"
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

            metalPipelineState = try! metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)

            let vertices: [Vertex] = [
                Vertex(x: 0.0, y: 0.0, s: 0.0, t: 0.0),
                Vertex(x: 1.0, y: 0.0, s: 1.0, t: 0.0),
                Vertex(x: 0.0, y: 1.0, s: 0.0, t: 1.0),
                Vertex(x: 1.0, y: 1.0, s: 1.0, t: 1.0)
            ]

            let verticesSize = MemoryLayout<Vertex>.stride * vertices.count
            metalVertexBuffer = metalDevice.makeBuffer(bytes: vertices, length:verticesSize, options: [])!

            var textureCache: CVMetalTextureCache? = nil
            CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, metalDevice, nil, &textureCache)

            metalTextureCache = textureCache!
        }

        public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            screenSize = SIMD2<Float>(Float(size.width), Float(size.height))
        }

        public func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable else {
                return
            }

            guard let commandBuffer = metalCommandQueue.makeCommandBuffer() else {
                return
            }

            commandBuffer.label = "Draw Command Buffer"

            guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
                return
            }

            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            renderPassDescriptor.colorAttachments[0].storeAction = .store

            guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                return
            }

            if let nextPixelBuffer = pixelBuffer {
                CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, metalTextureCache, nextPixelBuffer, nil, .bgra8Unorm, CVPixelBufferGetWidth(nextPixelBuffer), CVPixelBufferGetHeight(nextPixelBuffer), 0, &currentMetalTexture)

                if let metalTexture = currentMetalTexture {
                    currentTexture = CVMetalTextureGetTexture(metalTexture)
                }

                if let texture = currentTexture {
                    textureSize = SIMD2<Float>(Float(texture.width), Float(texture.height))
                }
            }

            if let texture = currentTexture {
                encoder.setRenderPipelineState(metalPipelineState)
                encoder.setFragmentTexture(texture, index: 0)
                encoder.setVertexBuffer(metalVertexBuffer, offset: 0, index: 0)
                encoder.setVertexBytes(&textureSize, length: MemoryLayout<SIMD2<Float>>.stride, index: 1)
                encoder.setVertexBytes(&screenSize, length: MemoryLayout<SIMD2<Float>>.stride, index: 2)

                encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            }

            encoder.endEncoding()

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}
