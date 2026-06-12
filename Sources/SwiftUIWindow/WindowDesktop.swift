
import SwiftUI

public struct WindowRegistration {
    var view: () -> AnyView
    var config: WindowConfig
}

public protocol WindowRegistrationProvider {
    var windowRegistrations: [WindowRegistration] { get }
}

@resultBuilder
public enum WindowDesktopBuilder {
    public static func buildBlock(_ components: WindowRegistrationProvider...) -> [WindowRegistration] {
        components.flatMap(\.windowRegistrations)
    }

    public static func buildOptional(_ component: [WindowRegistration]?) -> [WindowRegistration] {
        component ?? []
    }

    public static func buildEither(first component: [WindowRegistration]) -> [WindowRegistration] {
        component
    }

    public static func buildEither(second component: [WindowRegistration]) -> [WindowRegistration] {
        component
    }

    public static func buildArray(_ components: [[WindowRegistration]]) -> [WindowRegistration] {
        components.flatMap { $0 }
    }
}

public struct Window<Content: View>: View, WindowRegistrationProvider {
    private var config: WindowConfig
    private let content: () -> Content

    public init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.config = WindowConfig(title: title)
        self.content = content
    }

    public var body: some View {
        EmptyView()
    }

    public var windowRegistrations: [WindowRegistration] {
        [
            WindowRegistration(
                view: { AnyView(content()) },
                config: config
            )
        ]
    }

    public func windowSize(_ size: CGSize) -> Self {
        var copy = self
        copy.config.size = size
        return copy
    }

    public func windowSize(width: CGFloat, height: CGFloat) -> Self {
        windowSize(CGSize(width: width, height: height))
    }

    public func windowPosition(_ position: CGPoint) -> Self {
        var copy = self
        copy.config.position = position
        return copy
    }

    public func windowClosable(_ closable: Bool) -> Self {
        var copy = self
        copy.config.closable = closable
        return copy
    }

    public func windowMinimizable(_ minimizable: Bool) -> Self {
        var copy = self
        copy.config.minimizable = minimizable
        return copy
    }

    public func windowResizable(_ resizable: Bool) -> Self {
        var copy = self
        copy.config.resizable = resizable
        return copy
    }

    public func windowShowsTitle(_ showLabel: Bool) -> Self {
        var copy = self
        copy.config.showLabel = showLabel
        return copy
    }

    public func windowShowsBar(_ showWindowBar: Bool) -> Self {
        var copy = self
        copy.config.showWindowBar = showWindowBar
        return copy
    }

    public func windowStartPosition(_ mode: WindowPosMode) -> Self {
        var copy = self
        copy.config.startPos = mode
        return copy
    }
}

public struct WindowDesktop<Background: View>: View {
    private let initialWindows: [WindowRegistration]
    private let background: () -> Background
    @State private var windows : Array<WindowView> = []
    @State private var didAddInitialWindows = false
    @State var hover = false
    @State var activeWindow : Int? = nil

    public init(
        @WindowDesktopBuilder _ windows: () -> [WindowRegistration],
        @ViewBuilder background: @escaping () -> Background
    ) {
        self.initialWindows = windows()
        self.background = background
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack{
                background()
                    .frame(width: geometry.size.width + geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing, height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom)
                    .ignoresSafeArea()
                    .gesture(
                        TapGesture()
                            .onEnded { _ in
                                UIApplication.shared.closeKeyboard()
                                activeWindow = nil
                            }
                    )
                VStack(spacing: 0) {
                    Spacer(minLength: geometry.safeAreaInsets.top)
                    ZStack {
                        ForEach(windows, id:\.id) { w in
                            w
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
                    Spacer(minLength: geometry.safeAreaInsets.bottom)
                }
                .frame(width: geometry.size.width + geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing, height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom)
                .ignoresSafeArea()
            }
        }
        .onAppear() {
            guard !didAddInitialWindows else { return }
            didAddInitialWindows = true
            for window in initialWindows {
                _ = add_window(
                    view: window.view(),
                    config: window.config
                )
            }
        }
        .statusBar(hidden: true)
        .onHover {hover in
            self.hover = hover
        }
    }
    
    func close_window(id: Int){
        for i in 0..<windows.count{
            if (windows[i].id == id){
                print("Window ID \(id) closed.")
                windows.remove(at: i)
                checkActiveWindow()
                return
            }
        }
    }
    
    func add_window(view: AnyView, config: WindowConfig) -> Int{
        var max_id = 0
        for i in windows{
            if (max_id < i.id){
                max_id = i.id
            }
        }
        let newID = max_id + 1
        let new_window = WindowView(
            id: newID,
            title: config.title,
            view: view,
            size: config.size,
            position: config.position,
            closable: config.closable,
            minimizable: config.minimizable,
            resizable: config.resizable,
            showLabel: config.showLabel,
            showWindowBar: config.showWindowBar,
            closeFunction: close_window,
            activateWindow: activate_window,
            addWindow: add_window,
            activeWindowID: $activeWindow,
            startPos: config.startPos
        )
        windows.append(new_window)
        checkActiveWindow()
        return newID
    }
    
    func activate_window(id: Int){
        for i in 0..<windows.count{
            if (windows[i].id == id){
                windows.move(fromOffsets: IndexSet([i]), toOffset: windows.count)
            }
        }
        checkActiveWindow()
    }
    
    func checkActiveWindow() {
        activeWindow = windows.last?.id
    }
}

public extension WindowDesktop where Background == Color {
    init(@WindowDesktopBuilder _ windows: () -> [WindowRegistration]) {
        self.init(windows, background: { Color.black })
    }
}

@available(*, deprecated, renamed: "WindowDesktop")
struct window_system: View {
    var body: some View {
        WindowDesktop {
            Window("Debug Menu") {
                EmptyView()
            }
            .windowSize(width: 400, height: 200)
            .windowClosable(false)
            .windowMinimizable(false)
            .windowResizable(false)
        }
    }
}

struct window_system_Previews: PreviewProvider {
    static var previews: some View {
        WindowDesktop {
            Window("Debug Menu") {
                EmptyView()
            }
            .windowSize(width: 400, height: 200)
            .windowClosable(false)
            .windowMinimizable(false)
            .windowResizable(false)
        }
    }
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
