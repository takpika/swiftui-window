
import SwiftUI

struct window_system: View {
    @State var desktop_image = "Desktop"
    @State private var windows : Array<WindowView> = []
    @State var hover = false
    @State var activeWindow : Int? = nil
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                Image("Desktop")
                    .resizable()
                    .scaledToFill()
                    .clipped()
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
            add_window(
                view: AnyView(TestView()),
                config: WindowConfig(
                    title: "Debug Menu",
                    size: CGSize(width: 400, height: 200),
                    closable: false,
                    minimizable: false,
                    resizable: false
                )
            )
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

struct window_system_Previews: PreviewProvider {
    static var previews: some View {
        window_system()
    }
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
