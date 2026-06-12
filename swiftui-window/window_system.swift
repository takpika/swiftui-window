
import SwiftUI

@MainActor
public final class WindowDesktopController: ObservableObject {
    @Published public fileprivate(set) var windowIDs: [Int] = []
    @Published public fileprivate(set) var activeWindowID: Int?

    public var isAttached: Bool {
        addWindowHandler != nil
    }

    private var addWindowHandler: ((AnyView, WindowConfig) -> Int)?
    private var closeWindowHandler: ((Int) -> Bool)?
    private var activateWindowHandler: ((Int) -> Bool)?
    private var closeAllWindowsHandler: (() -> Void)?

    public nonisolated init() {}

    @discardableResult
    public func addWindow<Content: View>(
        config: WindowConfig,
        @ViewBuilder content: @escaping () -> Content
    ) -> Int? {
        addWindow(AnyView(content()), config: config)
    }

    @discardableResult
    public func addWindow(_ view: AnyView, config: WindowConfig) -> Int? {
        addWindowHandler?(view, config)
    }

    @discardableResult
    public func closeWindow(id: Int) -> Bool {
        closeWindowHandler?(id) ?? false
    }

    @discardableResult
    public func activateWindow(id: Int) -> Bool {
        activateWindowHandler?(id) ?? false
    }

    public func closeAllWindows() {
        closeAllWindowsHandler?()
    }

    fileprivate func connect(
        addWindow: @escaping (AnyView, WindowConfig) -> Int,
        closeWindow: @escaping (Int) -> Bool,
        activateWindow: @escaping (Int) -> Bool,
        closeAllWindows: @escaping () -> Void
    ) {
        addWindowHandler = addWindow
        closeWindowHandler = closeWindow
        activateWindowHandler = activateWindow
        closeAllWindowsHandler = closeAllWindows
    }

    fileprivate func disconnect() {
        addWindowHandler = nil
        closeWindowHandler = nil
        activateWindowHandler = nil
        closeAllWindowsHandler = nil
        update(windowIDs: [], activeWindowID: nil)
    }

    fileprivate func update(windowIDs: [Int], activeWindowID: Int?) {
        self.windowIDs = windowIDs
        self.activeWindowID = activeWindowID
    }
}

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
    private let controller: WindowDesktopController?
    @State private var windows : Array<WindowView> = []
    @State private var didAddInitialWindows = false
    @State var hover = false
    @State var activeWindow : Int? = nil

    public init(
        controller: WindowDesktopController? = nil,
        @WindowDesktopBuilder _ windows: () -> [WindowRegistration],
        @ViewBuilder background: @escaping () -> Background
    ) {
        self.controller = controller
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
            controller?.connect(
                addWindow: add_window,
                closeWindow: close_window,
                activateWindow: activate_window,
                closeAllWindows: close_all_windows
            )
            syncControllerState()

            guard !didAddInitialWindows else { return }
            didAddInitialWindows = true
            for window in initialWindows {
                _ = add_window(
                    view: window.view(),
                    config: window.config
                )
            }
        }
        .onDisappear() {
            controller?.disconnect()
        }
        .statusBar(hidden: true)
        .onHover {hover in
            self.hover = hover
        }
    }
    
    @discardableResult
    func close_window(id: Int) -> Bool {
        for i in 0..<windows.count{
            if (windows[i].id == id){
                print("Window ID \(id) closed.")
                windows.remove(at: i)
                checkActiveWindow()
                return true
            }
        }
        return false
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
            closeFunction: { id in _ = close_window(id: id) },
            activateWindow: { id in _ = activate_window(id: id) },
            addWindow: add_window,
            activeWindowID: $activeWindow,
            startPos: config.startPos
        )
        windows.append(new_window)
        checkActiveWindow()
        return newID
    }
    
    @discardableResult
    func activate_window(id: Int) -> Bool {
        for i in 0..<windows.count{
            if (windows[i].id == id){
                windows.move(fromOffsets: IndexSet([i]), toOffset: windows.count)
                checkActiveWindow()
                return true
            }
        }
        return false
    }

    func close_all_windows() {
        windows.removeAll()
        checkActiveWindow()
    }
    
    func checkActiveWindow() {
        activeWindow = windows.last?.id
        syncControllerState()
    }

    func syncControllerState() {
        controller?.update(
            windowIDs: windows.map(\.id),
            activeWindowID: activeWindow
        )
    }
}

public extension WindowDesktop where Background == Color {
    init(
        controller: WindowDesktopController? = nil,
        @WindowDesktopBuilder _ windows: () -> [WindowRegistration]
    ) {
        self.init(controller: controller, windows, background: { Color.black })
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
