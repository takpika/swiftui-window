
import SwiftUI

struct window: View {
    let id: Int
    @State var view: AnyView
    @Binding var title: String
    @Binding var size : CGSize
    @Binding var position : CGPoint
    @Binding var closable : Bool
    @Binding var minimizable : Bool
    @Binding var resizable : Bool
    @Binding var active : Bool
    @Binding var isHidden : Bool
    @Binding var fullScreen : Bool
    @State var closeFunction : (Int) -> Void
    @State var activateWindow : (Int) -> Void
    @State var addWindow : (AnyView, String, CGSize, CGPoint, Bool, Bool, Bool) -> Int
    let windowsize : CGSize
    
    @State private var current_size : CGSize = CGSize()
    @State private var ximage = "circle.fill"
    @State private var minusimage = "circle.fill"
    @State private var plusimage = "circle.fill"
    @State private var buttonSize : CGFloat = 30
    @State private var beforeSize : CGSize = CGSize()
    @State private var beforePosition : CGPoint = CGPoint()
    
    var window_drag: some Gesture {
            DragGesture()
            .onChanged{ value in
                activateWindow(id)
                self.position = CGPoint(
                    x: position.x
                        + value.translation.width,
                    y: position.y
                        + value.translation.height
                )
                if (position.x < 0){
                    position.x = 0
                }
                if (position.y < 0){
                    position.y = 0
                }
                if (position.x+size.width > windowsize.width){
                    position.x = windowsize.width - size.width
                }
                if (position.y+size.height > windowsize.height){
                    position.y = windowsize.height - size.height
                }
                if (fullScreen && (position.x != 0 || position.y != 0)){
                    fullScreen = false
                    size = beforeSize
                }
            }
            
        }
    
    var window_resize: some Gesture {
        DragGesture()
            .onChanged{ value in
                activateWindow(id)
                self.size = CGSize(width: size.width+value.translation.width, height: size.height+value.translation.height)
                if size.width < current_size.width{
                    size.width = current_size.width
                }
                if size.height < current_size.height{
                    size.height = current_size.height
                }
            }
    }
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                Rectangle()
                    .fill(Color("Background"))
                VStack{
                    ZStack{
                        if active{
                            Rectangle()
                                .fill(Color("WindowBar"))
                                .gesture(window_drag)
                                .onTapGesture(count: 2){
                                    if resizable{
                                        plus_button()
                                    }
                                }
                        }else{
                            Rectangle()
                                .fill(Color("InactiveWindowBar"))
                        }
                        HStack{
                            if closable || minimizable || resizable{
                                if closable{
                                    ZStack{
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: buttonSize-1, height: buttonSize-1)
                                        Image(systemName: ximage)
                                            .font(.system(size: buttonSize))
                                            .foregroundColor(.red)
                                    }
                                    .onHover{ isHoverd in
                                        if (isHoverd) {
                                            ximage = "xmark.circle.fill"
                                        }else{
                                            ximage = "circle.fill"
                                        }
                                    }
                                    .onTapGesture{
                                        closeFunction(id)
                                    }
                                }else{
                                    invalid_controlbutton(buttonSize: $buttonSize)
                                }
                                if minimizable{
                                    ZStack{
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: buttonSize-1, height: buttonSize-1)
                                        Image(systemName: minusimage)
                                            .font(.system(size: buttonSize))
                                            .foregroundColor(.yellow)
                                    }
                                    .onHover{ isHoverd in
                                        if (isHoverd) {
                                            minusimage = "minus.circle.fill"
                                        }else{
                                            minusimage = "circle.fill"
                                        }
                                    }
                                }else{
                                    invalid_controlbutton(buttonSize: $buttonSize)
                                }
                                if resizable{
                                    ZStack{
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: buttonSize-1, height: buttonSize-1)
                                        Image(systemName: plusimage)
                                            .font(.system(size: buttonSize))
                                            .foregroundColor(.green)
                                    }
                                    .onHover{ isHoverd in
                                        if (isHoverd) {
                                            plusimage = "plus.circle.fill"
                                        }else{
                                            plusimage = "circle.fill"
                                        }
                                    }
                                    .onTapGesture {
                                        plus_button()
                                    }
                                }else{
                                    invalid_controlbutton(buttonSize: $buttonSize)
                                }
                            }
                            Spacer()
                            Text(title)/*
                                .onTapGesture(count: 2){
                                    if resizable{
                                        plus_button(reverse: false)
                                    }
                                }*/
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 40)
                    Spacer()
                    view
                        .environment(\.titleSetKey, set_title)
                        .environment(\.titleGetKey, get_title)
                        .environment(\.windowIDGetKey, get_id)
                        .environment(\.closeKey, close_window)
                        .environment(\.window_AllAddKey, addWindow)
                        .environment(\.window_SimpleAddKey, addWindow_simple)
                        .environment(\.sizeSetKey, change_size)
                        .environment(\.sizeGetKey, geometry.size)
                        .environment(\.positionSetKey, change_position)
                        .environment(\.positionGetKey, position)
                        .environment(\.permission_SetKey, change_permission)
                        .environment(\.permission_GetKey, check_permission)
                        .environment(\.fullScreen_GetKey, fullScreen)
                        .environment(\.fullScreen_SetKey, set_full_screen)
                    Spacer()
                    ZStack{
                        if active{
                            Rectangle()
                                .fill(Color("WindowBar"))
                            if resizable{
                                HStack{
                                    Spacer()
                                    ZStack{
                                        Rectangle()
                                            .fill(Color("WindowBar"))
                                            .frame(width: 12, height: 12)
                                        Image(systemName: "line.horizontal.3")
                                            .padding(.horizontal)
                                            .font(.system(size:12))
                                    }
                                    .gesture(window_resize)
                                }
                            }
                        }else{
                            Rectangle()
                                .fill(Color("InactiveWindowBar"))
                        }
                    }
                    .frame(height: 15)
                }
            }
            .cornerRadius(15)
            .onTapGesture {
                activateWindow(id)
            }
            .onAppear{
                current_size = geometry.size
            }
            /*
            .onHover { hover in
                    print("Mouse hover: \(hover)")
                if hover{
                    buttonSize = 20
                }else{
                    buttonSize = 30
                }
                }*/
        }
    }
    
    func get_id() -> Int {
        return id
    }
    
    func plus_button(){
        activateWindow(id)
        let animationDuration = 250
        var duratationx : CGFloat
        var duratationy : CGFloat
        var duratationwidth : CGFloat
        var duratationheight : CGFloat
        if fullScreen{
            duratationx = beforePosition.x-position.x
            duratationy = beforePosition.y-position.y
            duratationwidth = beforeSize.width-size.width
            duratationheight = beforeSize.height-size.height
            fullScreen = false
        }else{
            beforeSize = size
            beforePosition = position
            duratationx = 0-position.x
            duratationy = 0-position.y
            duratationwidth = windowsize.width-size.width
            duratationheight = windowsize.height-size.height
            fullScreen = true
        }
        withAnimation {
            let max_duratation = Int(max(duratationx, max(duratationy, max(duratationwidth, duratationheight))))
            let steps = min(abs(max_duratation), 100)
            if steps != 0{
                let stepDuration = (animationDuration / steps)
                (0..<steps).forEach { step in
                    let updateTimeInterval = DispatchTimeInterval.milliseconds(step * stepDuration)
                    let deadline = DispatchTime.now() + updateTimeInterval
                    DispatchQueue.main.asyncAfter(deadline: deadline) {
                        position = CGPoint(x: position.x+(duratationx/CGFloat(steps)), y: position.y+(duratationy/CGFloat(steps)))
                        size = CGSize(width: size.width+(duratationwidth/CGFloat(steps)), height: size.height+(duratationheight/CGFloat(steps)))
                    }
                }
            }
        }
    }
    
    func set_title(title: String){
        self.title = title
    }
    
    func get_title() -> String {
        return title
    }
    
    func close_window(){
        if closable{
            closeFunction(id)
        }else{
            print("[WindowError] Closing this window is not allowed.: ID \(id), title: '\(title)' Please change window's permission.")
        }
    }
    
    func change_size(width: CGFloat, height: CGFloat){
        if resizable{
            size = CGSize(width: width, height: height)
            current_size = size
        }else{
            print("[WindowError] Changing this window size: ID \(id), title: '\(title)' Please change window's permission.")
        }
    }
    
    func change_position(x: CGFloat, y: CGFloat){
        position = CGPoint(x: x, y: y)
    }
    
    func change_permission(key: String, state: Bool){
        switch(key){
            case "Close":
                closable = state
                break
            case "Minimum":
                minimizable = state
                break
            case "Resize":
                resizable = state
                break
            default:
                print("Key \(key) not found.")
                break
        }
    }
    
    func check_permission(key: String) -> Bool{
        switch(key){
            case "Close":
                return closable
            case "Minimum":
                return minimizable
            case "Resize":
                return resizable
            default:
                return false
        }
    }
    
    func addWindow_simple(view: AnyView, title: String) -> Int{
        return addWindow(view, title, CGSize(width: 300, height: 300), CGPoint(x: 200, y: 200), true, true, true)
    }
    
    func set_full_screen(){
        if !fullScreen && resizable{
            let animationDuration = 250
            let duratationx : CGFloat = -position.x
            let duratationy : CGFloat = -position.y
            let duratationwidth : CGFloat = windowsize.width-size.width
            let duratationheight : CGFloat = windowsize.height-size.height
            beforeSize = size
            beforePosition = position
            fullScreen = true
            withAnimation {
                let max_duratation = Int(max(duratationx, max(duratationy, max(duratationwidth, duratationheight))))
                let steps = min(abs(max_duratation), 100)
                if steps != 0{
                    let stepDuration = (animationDuration / steps)
                    (0..<steps).forEach { step in
                        let updateTimeInterval = DispatchTimeInterval.milliseconds(step * stepDuration)
                        let deadline = DispatchTime.now() + updateTimeInterval
                        DispatchQueue.main.asyncAfter(deadline: deadline) {
                            position = CGPoint(x: position.x+(duratationx/CGFloat(steps)), y: position.y+(duratationy/CGFloat(steps)))
                            size = CGSize(width: size.width+(duratationwidth/CGFloat(steps)), height: size.height+(duratationheight/CGFloat(steps)))
                        }
                    }
                }
            }
        }
    }
}


struct WindowView: View{
    let id : Int
    @State var title : String = "New Window"
    @State var view : AnyView
    @State var size : CGSize = CGSize(width: 300, height: 300)
    @State var position : CGPoint = CGPoint(x: 200, y: 200)
    @State var closable : Bool = true
    @State var minimizable : Bool = true
    @State var resizable : Bool = true
    @State var active : Bool = true
    @State var isHidden : Bool = false
    @State var closeFunction : (Int) -> Void
    @State var activateWindow : (Int) -> Void
    @State var addWindow : (AnyView, String, CGSize, CGPoint, Bool, Bool, Bool) -> Int
    @State private var fullScreen : Bool = false
    var body: some View{
        VStack{
            GeometryReader{ g in
                window(id: id, view: view, title: $title, size: $size, position: $position, closable: $closable, minimizable: $minimizable, resizable: $resizable, active: $active, isHidden: $isHidden, fullScreen: $fullScreen, closeFunction: closeFunction, activateWindow: activateWindow, addWindow: addWindow, windowsize: g.size)
                    .frame(width: size.width, height: size.height)
                    .position(CGPoint(x: position.x+size.width/2, y: position.y+size.height/2))
            }
        }
    }
    
    func activate(){
        active = true
    }
    
    func disactivate(){
        active = false
    }
}

struct invalid_controlbutton : View{
    @Binding var buttonSize : CGFloat
    var body: some View{
        Image(systemName: "circle.fill")
            .font(.system(size: buttonSize))
            .foregroundColor(Color.gray)
    }
}
