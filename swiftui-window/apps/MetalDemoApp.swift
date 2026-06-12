import SwiftUI
import MetalKit
import QuartzCore

struct MetalDemoApp: View {
    static let config = WindowConfig(
        title: "Metal Demo",
        size: CGSize(width: 520, height: 360),
        minimizable: false,
        startPos: WindowPosMode.center
    )

    @State private var resolution: CGSize = .zero

    var body: some View {
        ZStack {
            MetalDemoView(resolution: $resolution)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Text("Metal")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                    Spacer(minLength: 0)
                    Text("\(Int(resolution.width)) x \(Int(resolution.height)) px")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .monospacedDigit()
                }

                Spacer(minLength: 0)

                Text("△  ○  ✕  ◇  +  #  @")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)

                Spacer(minLength: 0)
            }
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.7), radius: 6, x: 0, y: 2)
            .padding()
        }
    }
}

struct MetalDemoView: UIViewRepresentable {
    @Binding var resolution: CGSize

    func makeCoordinator() -> Renderer {
        Renderer(resolution: $resolution)
    }

    func makeUIView(context: Context) -> MTKView {
        let view = MTKView()
        view.device = MTLCreateSystemDefaultDevice()
        view.delegate = context.coordinator
        view.framebufferOnly = true
        view.enableSetNeedsDisplay = false
        view.isPaused = false
        view.preferredFramesPerSecond = 60
        view.clearColor = MTLClearColor(red: 0.05, green: 0.07, blue: 0.11, alpha: 1.0)
        context.coordinator.configure(device: view.device)
        return view
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.configure(device: uiView.device)
    }

    final class Renderer: NSObject, MTKViewDelegate {
        private let resolution: Binding<CGSize>
        private var commandQueue: MTLCommandQueue?
        private let startTime = CACurrentMediaTime()

        init(resolution: Binding<CGSize>) {
            self.resolution = resolution
        }

        func configure(device: MTLDevice?) {
            guard commandQueue == nil else { return }
            commandQueue = device?.makeCommandQueue()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            DispatchQueue.main.async {
                self.resolution.wrappedValue = size
            }
        }

        func draw(in view: MTKView) {
            guard
                let commandQueue,
                let commandBuffer = commandQueue.makeCommandBuffer(),
                let renderPassDescriptor = view.currentRenderPassDescriptor
            else {
                return
            }

            let elapsed = CACurrentMediaTime() - startTime
            let red = 0.08 + 0.05 * sin(elapsed * 0.7)
            let green = 0.11 + 0.06 * sin(elapsed * 0.9 + 1.4)
            let blue = 0.20 + 0.12 * sin(elapsed * 0.6 + 2.1)
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
                red: red,
                green: green,
                blue: blue,
                alpha: 1.0
            )

            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            encoder?.endEncoding()

            if let drawable = view.currentDrawable {
                commandBuffer.present(drawable)
            }
            commandBuffer.commit()
        }
    }
}
