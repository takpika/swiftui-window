
import SwiftUI

struct window_system: View {
    @State var desktop_image = "Desktop"
    @State private var windows : Array<WindowView> = []
    @State var hover = false
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                Image("Desktop")
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .gesture(
                        TapGesture()
                            .onEnded { _ in
                                UIApplication.shared.closeKeyboard()
                            }
                    )
                ForEach(windows, id:\.id) { w in
                    w
                }
            }
        }
        .onAppear() {
            add_window(view: AnyView(TestView()), title: "Debug Menu", size: CGSize(width: 350, height: 200), closable: false, minimizable: false ,resizable: false)
        }
        .statusBar(hidden: true)
    }
    
    func close_window(id: Int){
        for i in 0..<windows.count{
            if (windows[i].id == id){
                print("Window ID \(id) closed.")
                windows.remove(at: i)
                return
            }
        }
    }
    
    func add_window(view: AnyView, title: String="New Window", size: CGSize=CGSize(width: 300, height: 300), position: CGPoint=CGPoint(x: 50, y: 50), closable: Bool=true, minimizable: Bool=true, resizable: Bool=true) -> Int{
        var max_id = 0
        for i in windows{
            if (max_id < i.id){
                max_id = i.id
            }
        }
        let new_window = WindowView(id: max_id+1, title: title, view: view, size: size, position: position, closable: closable, minimizable: minimizable, resizable: resizable, closeFunction: close_window, activateWindow: activate_window, addWindow: add_window)
        windows.append(new_window)
        return max_id+1
    }
    
    func activate_window(id: Int){
        for i in 0..<windows.count{
            if (windows[i].id == id){
                windows.move(fromOffsets: IndexSet([i]), toOffset: windows.count)
            }
        }
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
