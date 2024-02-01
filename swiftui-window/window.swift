
import SwiftUI

struct ActionbarItem: Identifiable {
    let id = UUID().uuidString
    let view: AnyView

    init(_ view: AnyView) {
        self.view = view
    }
}

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
    @Binding var showLabel : Bool
    @Binding var showWindowBar : Bool
    @Binding var windowMode : WindowPosMode
    @Binding var previewWindowMode : WindowPosMode?
    @State var actionBar: [ActionbarItem] = []
    @State var closeFunction : (Int) -> Void
    @State var activateWindow : (Int) -> Void
    @State var addWindow : (AnyView, WindowConfig) -> Int
    let windowsize : CGSize
    
    @State private var current_size : CGSize = CGSize()
    @State private var ximage = "circle.fill"
    @State private var minusimage = "circle.fill"
    @State private var plusimage = "circle.fill"
    @State private var buttonSize : CGFloat = 20
    @State private var beforeSize : CGSize = CGSize()
    @State private var beforePosition : CGPoint = CGPoint()
    @State private var topWindowBarHeight : CGFloat = 40
    @State private var windowMoving: Bool = false
    @State private var windowMoveStartAbsPos: CGPoint = CGPoint.zero
    @State private var windowMovePos: CGPoint = CGPoint.zero
    @State private var manualScreenSize: CGSize? = nil
    @State private var previewPos : CGPoint? = nil
    
    var window_drag: some Gesture {
            DragGesture()
            .onChanged{ value in
                if (!windowMoving) {
                    windowMoveStartAbsPos.x = value.startLocation.x / size.width
                    windowMoveStartAbsPos.y = value.startLocation.y / size.height
                    windowMoving = true
                }
                if (windowMode != WindowPosMode.normal){
                    windowMode = WindowPosMode.normal
                    size = beforeSize
                }
                activateWindow(id)
                var finalPos = position
                finalPos.x = position.x + value.location.x - windowMoveStartAbsPos.x * size.width
                finalPos.y = position.y + value.location.y - windowMoveStartAbsPos.y * size.height
                let mousePos = CGPoint(x: position.x + value.location.x, y: position.y + value.location.y)
                if mousePos.y < 50 {
                    setPreviewMode(mode: WindowPosMode.fullScreen)
                } else if mousePos.x < 50 {
                    if (previewPos == nil) {
                        previewPos = mousePos
                        setPreviewMode(mode: WindowPosMode.leftHalf)
                    }
                    if (mousePos.y - previewPos!.y < -50 && mousePos.y <= windowsize.height / 2) {
                        previewPos!.y = windowsize.height / 2
                        setPreviewMode(mode: WindowPosMode.leftTopQuarter)
                    } else if (mousePos.y - previewPos!.y > 50 && mousePos.y >= windowsize.height / 2) {
                        previewPos!.y = windowsize.height / 2
                        setPreviewMode(mode: WindowPosMode.leftBottomQuarter)
                    } else {
                        setPreviewMode(mode: WindowPosMode.leftHalf)
                    }
                } else if mousePos.x > windowsize.width - 50 {
                    if (previewPos == nil) {
                        previewPos = mousePos
                        setPreviewMode(mode: WindowPosMode.rightHalf)
                    }
                    if (mousePos.y - previewPos!.y < -50 && mousePos.y < windowsize.height / 2 - 50) {
                        previewPos!.y = windowsize.height / 2
                        setPreviewMode(mode: WindowPosMode.rightTopQuarter)
                    } else if (mousePos.y - previewPos!.y > 50 && mousePos.y > windowsize.height / 2 + 50) {
                        previewPos!.y = windowsize.height / 2
                        setPreviewMode(mode: WindowPosMode.rightBottomQuarter)
                    } else {
                        setPreviewMode(mode: WindowPosMode.rightHalf)
                    }
                } else {
                    previewPos = nil
                    setPreviewMode(mode: nil)
                }
                position = finalPos
            }
            .onEnded {_ in 
                windowMoving = false
                if (previewWindowMode != nil) {
                    setWindowMode(mode: previewWindowMode!)
                }
                previewWindowMode = nil
            }
        }
    
    func setPreviewMode(mode: WindowPosMode?) {
        if (previewWindowMode != mode && resizable) {
            previewWindowMode = mode
        }
    }
    
    var window_resize: some Gesture {
        DragGesture()
            .onChanged{ value in
                activateWindow(id)
                windowMode = WindowPosMode.normal
                self.size = CGSize(width: size.width+value.translation.width, height: size.height+value.translation.height)
                if size.width < current_size.width{
                    size.width = current_size.width
                }
                if size.height < current_size.height{
                    size.height = current_size.height
                }
            }
    }
    
    func handleHover(isHovered: Bool) {
        ximage = isHovered ? "xmark.circle.fill" : "circle.fill"
        minusimage = isHovered ? "minus.circle.fill" : "circle.fill"
        plusimage = isHovered ? "plus.circle.fill" : "circle.fill"
    }
    
    func setWindowBarHeight(height: CGFloat) {
        topWindowBarHeight = height
    }
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                Rectangle()
                    .fill(Color("Background"))
                VStack(spacing: 0) {
                    if (showWindowBar) {
                        ZStack{
                            Rectangle()
                                .fill(active ? Color("WindowBar") : Color("InactiveWindowBar"))
                                .gesture(window_drag)
                                .onTapGesture(count: 2){
                                    activateWindow(id)
                                    if resizable{
                                        plus_button()
                                    }
                                }
                            HStack{
                                if closable || minimizable || resizable{
                                    HStack {
                                        if closable {
                                            ZStack{
                                                Circle()
                                                    .fill(Color.black)
                                                    .frame(width: buttonSize-1, height: buttonSize-1)
                                                Image(systemName: ximage)
                                                    .font(.system(size: buttonSize))
                                                    .foregroundColor(active ? .red : .gray)
                                            }
                                            .onTapGesture{
                                                closeFunction(id)
                                            }
                                        }else{
                                            invalid_controlbutton(buttonSize: $buttonSize)
                                        }
                                        if minimizable || resizable {
                                            if minimizable {
                                                ZStack{
                                                    Circle()
                                                        .fill(Color.black)
                                                        .frame(width: buttonSize-1, height: buttonSize-1)
                                                    Image(systemName: minusimage)
                                                        .font(.system(size: buttonSize))
                                                        .foregroundColor(active ? .yellow : .gray)
                                                }
                                            }else{
                                                invalid_controlbutton(buttonSize: $buttonSize)
                                            }
                                            if resizable {
                                                ZStack{
                                                    Circle()
                                                        .fill(Color.black)
                                                        .frame(width: buttonSize-1, height: buttonSize-1)
                                                    Image(systemName: plusimage)
                                                        .font(.system(size: buttonSize))
                                                        .foregroundColor(active ? .green : .gray)
                                                }
                                                .onTapGesture {
                                                    plus_button()
                                                }
                                            }else{
                                                invalid_controlbutton(buttonSize: $buttonSize)
                                            }
                                        }
                                    }
                                    .onHover{ isHovered in
                                        handleHover(isHovered: isHovered)
                                    }
                                }
                                ForEach(actionBar, id: \.id) { item in
                                    item.view
                                }
                                Spacer(minLength: 0)
                                if (showLabel) {
                                    Text(title)
                                    Spacer(minLength: 0)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: topWindowBarHeight)
                        .onTapGesture {
                            UIApplication.shared.closeKeyboard()
                        }
                    }
                    Spacer(minLength: 0)
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
                        .environment(\.windowPosMode_GetKey, windowMode)
                        .environment(\.windowPosMode_SetKey, setWindowMode)
                        .environment(\.actionBarClearKey, clearActionBar)
                        .environment(\.actionBarAddKey, addActionBar)
                        .environment(\.windowBarHeightGetKey, topWindowBarHeight)
                        .environment(\.windowBarHeightSetKey, setWindowBarHeight)
                    Spacer(minLength: 0)
                    if (showWindowBar) {
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
            }
            .cornerRadius(15)
            .onTapGesture {
                activateWindow(id)
            }
            .onAppear{
                current_size = geometry.size
            }
            .onChange(of: windowsize) { value in
                manualScreenSize = value
                setWindowMode(mode: windowMode)
                manualScreenSize = nil
            }
        }
    }
    
    func get_id() -> Int {
        return id
    }
    
    func moveWindow(destPos: CGPoint, destSize: CGSize) {
        let animationDuration = 250
        let duratationx = destPos.x-position.x
        let duratationy = destPos.y-position.y
        let duratationwidth = destSize.width-size.width
        let duratationheight = destSize.height-size.height
        withAnimation {
            let max_duratation = Int(max(abs(duratationx), max(abs(duratationy), max(abs(duratationwidth), abs(duratationheight)))))
            let steps = min(abs(max_duratation), 100)
            if steps != 0{
                let stepDuration = (animationDuration / steps)
                (0...steps).forEach { step in
                    let updateTimeInterval = DispatchTimeInterval.milliseconds(step * stepDuration)
                    let deadline = DispatchTime.now() + updateTimeInterval
                    DispatchQueue.main.asyncAfter(deadline: deadline) {
                        if (step != steps) {
                            position = CGPoint(x: position.x+(duratationx/CGFloat(steps)), y: position.y+(duratationy/CGFloat(steps)))
                            size = CGSize(width: size.width+(duratationwidth/CGFloat(steps)), height: size.height+(duratationheight/CGFloat(steps)))
                        } else {
                            position = destPos
                            size = destSize
                        }
                    }
                }
            }
        }
    }
    
    func plus_button(){
        activateWindow(id)
        let destPos : CGPoint = windowMode == WindowPosMode.fullScreen ? beforePosition : CGPoint.zero
        let destSize : CGSize = windowMode == WindowPosMode.fullScreen ? beforeSize : windowsize
        if windowMode == WindowPosMode.fullScreen {
            windowMode = WindowPosMode.normal
        }else{
            beforeSize = size
            beforePosition = position
            windowMode = WindowPosMode.fullScreen
        }
        moveWindow(destPos: destPos, destSize: destSize)
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
            windowMode = WindowPosMode.normal
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
                windowMode = WindowPosMode.normal
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
        return addWindow(view, WindowConfig(
            title: title,
            startPos: WindowPosMode.center
        ))
    }
    
    func setWindowMode(mode: WindowPosMode){
        if resizable && mode != WindowPosMode.normal {
            if (windowMode != mode) {
                windowMode = mode
                beforeSize = size
                beforePosition = position
            }
            let finalScreenSize = manualScreenSize ?? windowsize
            var destPos : CGPoint = position
            var destSize : CGSize = size
            switch (mode) {
            case WindowPosMode.center:
                destPos = CGPoint(x: finalScreenSize.width / 2 - size.width / 2, y: finalScreenSize.height / 2 - size.height / 2)
                break
            case WindowPosMode.leftHalf:
                destPos = CGPoint(x: 0, y: 0)
                destSize = CGSize(width: finalScreenSize.width / 2, height: finalScreenSize.height)
                break
            case WindowPosMode.rightHalf:
                destPos = CGPoint(x: finalScreenSize.width / 2, y: 0)
                destSize = CGSize(width: finalScreenSize.width / 2, height: finalScreenSize.height)
                break
            case WindowPosMode.leftTopQuarter:
                destPos = CGPoint(x: 0, y: 0)
                destSize = CGSize(width: finalScreenSize.width / 2, height: finalScreenSize.height / 2)
                break
            case WindowPosMode.leftBottomQuarter:
                destPos = CGPoint(x: 0, y: finalScreenSize.height / 2)
                destSize = CGSize(width: finalScreenSize.width / 2, height: finalScreenSize.height / 2)
                break
            case WindowPosMode.rightTopQuarter:
                destPos = CGPoint(x: finalScreenSize.width / 2, y: 0)
                destSize = CGSize(width: finalScreenSize.width / 2, height: finalScreenSize.height / 2)
                break
            case WindowPosMode.rightBottomQuarter:
                destPos = CGPoint(x: finalScreenSize.width / 2, y: finalScreenSize.height / 2)
                destSize = CGSize(width: finalScreenSize.width / 2, height: finalScreenSize.height / 2)
                break
            case WindowPosMode.fullScreen:
                destPos = CGPoint.zero
                destSize = finalScreenSize
                break
            default:
                break
            }
            moveWindow(destPos: destPos, destSize: destSize)
        }
    }
    
    func clearActionBar() {
        actionBar.removeAll()
    }
    
    func addActionBar(view: AnyView) -> String {
        let item = ActionbarItem(view)
        actionBar.append(item)
        return item.id
    }
}

struct PreviewWindowView: View {
    @Binding var windowMode: WindowPosMode?
    @Binding var orgPos: CGPoint
    @Binding var orgSize: CGSize
    let screenSize: CGSize
    @State private var previewWindowPos : CGPoint = CGPoint.zero
    @State private var previewWindowSize : CGSize = CGSize.zero
    @State private var showWindowPreview : Bool = false
    
    func moveWindow(destPos: CGPoint, destSize: CGSize) {
        let animationDuration = 100
        let duratationx = destPos.x-previewWindowPos.x
        let duratationy = destPos.y-previewWindowPos.y
        let duratationwidth = destSize.width-previewWindowSize.width
        let duratationheight = destSize.height-previewWindowSize.height
        withAnimation {
            let max_duratation = Int(max(abs(duratationx), max(abs(duratationy), max(abs(duratationwidth), abs(duratationheight)))))
            let steps = min(abs(max_duratation), 100)
            if steps != 0{
                let stepDuration = (animationDuration / steps)
                (0...steps).forEach { step in
                    let updateTimeInterval = DispatchTimeInterval.milliseconds(step * stepDuration)
                    let deadline = DispatchTime.now() + updateTimeInterval
                    DispatchQueue.main.asyncAfter(deadline: deadline) {
                        if (step != steps) {
                            previewWindowPos = CGPoint(x: previewWindowPos.x+(duratationx/CGFloat(steps)), y: previewWindowPos.y+(duratationy/CGFloat(steps)))
                            previewWindowSize = CGSize(width: previewWindowSize.width+(duratationwidth/CGFloat(steps)), height: previewWindowSize.height+(duratationheight/CGFloat(steps)))
                        } else {
                            previewWindowPos = destPos
                            previewWindowSize = destSize
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        Rectangle()
            .fill(Color("Background"))
            .opacity(showWindowPreview ? 0.5 : 0)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("WindowBar"), lineWidth: 5)
                    .opacity(showWindowPreview ? 0.8 : 0)
            )
            .frame(width: previewWindowSize.width, height: previewWindowSize.height)
            .position(CGPoint(x: previewWindowPos.x+previewWindowSize.width/2, y: previewWindowPos.y+previewWindowSize.height/2))
            .onChange(of: windowMode) {value in
                if (value != nil && value != WindowPosMode.normal) {
                    if let value = value {
                        if (!showWindowPreview) {
                            previewWindowPos = orgPos
                            previewWindowSize = orgSize
                            showWindowPreview = true
                        }
                        var destPos = previewWindowPos
                        var destSize = previewWindowSize
                        switch (value) {
                        case WindowPosMode.center:
                            destPos = CGPoint(x: screenSize.width / 2 - previewWindowSize.width / 2, y: screenSize.height / 2 - previewWindowSize.height / 2)
                            break
                        case WindowPosMode.leftHalf:
                            destPos = CGPoint(x: 0, y: 0)
                            destSize = CGSize(width: screenSize.width / 2, height: screenSize.height)
                            break
                        case WindowPosMode.rightHalf:
                            destPos = CGPoint(x: screenSize.width / 2, y: 0)
                            destSize = CGSize(width: screenSize.width / 2, height: screenSize.height)
                            break
                        case WindowPosMode.leftTopQuarter:
                            destPos = CGPoint(x: 0, y: 0)
                            destSize = CGSize(width: screenSize.width / 2, height: screenSize.height / 2)
                            break
                        case WindowPosMode.leftBottomQuarter:
                            destPos = CGPoint(x: 0, y: screenSize.height / 2)
                            destSize = CGSize(width: screenSize.width / 2, height: screenSize.height / 2)
                            break
                        case WindowPosMode.rightTopQuarter:
                            destPos = CGPoint(x: screenSize.width / 2, y: 0)
                            destSize = CGSize(width: screenSize.width / 2, height: screenSize.height / 2)
                            break
                        case WindowPosMode.rightBottomQuarter:
                            destPos = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
                            destSize = CGSize(width: screenSize.width / 2, height: screenSize.height / 2)
                            break
                        case WindowPosMode.fullScreen:
                            destPos = CGPoint.zero
                            destSize = screenSize
                            break
                        default:
                            break
                        }
                        moveWindow(destPos: destPos, destSize: destSize)
                    }
                } else {
                    showWindowPreview = false
                }
            }
    }
}


struct WindowView: View{
    let id : Int
    @State var title : String = "New Window"
    @State var view : AnyView
    @State var size : CGSize = CGSize(width: 300, height: 300)
    @State var position : CGPoint = CGPoint(x: 0, y: 0)
    @State var closable : Bool = true
    @State var minimizable : Bool = true
    @State var resizable : Bool = true
    @State var active : Bool = true
    @State var isHidden : Bool = false
    @State var showLabel : Bool = true
    @State var showWindowBar : Bool = true
    @State var closeFunction : (Int) -> Void
    @State var activateWindow : (Int) -> Void
    @State var addWindow : (AnyView, WindowConfig) -> Int
    @Binding var activeWindowID: Int?
    let startPos : WindowPosMode
    @State private var windowMode : WindowPosMode = WindowPosMode.normal
    @State private var previewWindowMode : WindowPosMode?
    var body: some View{
        VStack(spacing: 0) {
            GeometryReader{ g in
                ZStack {
                    PreviewWindowView(windowMode: $previewWindowMode, orgPos: $position, orgSize: $size, screenSize: g.size)
                    window(id: id, view: view, title: $title, size: $size, position: $position, closable: $closable, minimizable: $minimizable, resizable: $resizable, active: $active, isHidden: $isHidden, showLabel: $showLabel, showWindowBar: $showWindowBar, windowMode: $windowMode, previewWindowMode: $previewWindowMode, closeFunction: closeFunction, activateWindow: activateWindow, addWindow: addWindow, windowsize: g.size)
                        .frame(width: size.width, height: size.height)
                        .position(CGPoint(x: position.x+size.width/2, y: position.y+size.height/2))
                        .onAppear() {
                            active = activeWindowID == id
                            size.width = size.width > g.size.width ? g.size.width : size.width
                            size.height = size.height > g.size.height ? g.size.height : size.height
                            switch (startPos) {
                            case WindowPosMode.center:
                                position = CGPoint(x: g.size.width / 2 - size.width / 2, y: g.size.height / 2 - size.height / 2)
                                break
                            case WindowPosMode.leftHalf:
                                position = CGPoint(x: 0, y: 0)
                                size = CGSize(width: g.size.width / 2, height: g.size.height)
                                break
                            case WindowPosMode.rightHalf:
                                position = CGPoint(x: g.size.width / 2, y: 0)
                                size = CGSize(width: g.size.width / 2, height: g.size.height)
                                break
                            case WindowPosMode.leftTopQuarter:
                                position = CGPoint(x: 0, y: 0)
                                size = CGSize(width: g.size.width / 2, height: g.size.height / 2)
                                break
                            case WindowPosMode.leftBottomQuarter:
                                position = CGPoint(x: 0, y: g.size.height / 2)
                                size = CGSize(width: g.size.width / 2, height: g.size.height / 2)
                                break
                            case WindowPosMode.rightTopQuarter:
                                position = CGPoint(x: g.size.width / 2, y: 0)
                                size = CGSize(width: g.size.width / 2, height: g.size.height / 2)
                                break
                            case WindowPosMode.rightBottomQuarter:
                                position = CGPoint(x: g.size.width / 2, y: g.size.height / 2)
                                size = CGSize(width: g.size.width / 2, height: g.size.height / 2)
                                break
                            case WindowPosMode.fullScreen:
                                position = CGPoint.zero
                                size = g.size
                                break
                            default: break
                            }
                        }
                        .onChange(of: activeWindowID) { value in
                            active = value == id
                        }
                        .shadow(radius: 5)
                }
            }
        }
    }
}

enum WindowPosMode: String {
    case normal = "normal"
    case center = "center"
    case leftHalf = "leftHalf"
    case rightHalf = "rightHalf"
    case leftTopQuarter = "leftTopQuarter"
    case leftBottomQuarter = "leftBottomQuarter"
    case rightTopQuarter = "rightTopQuarter"
    case rightBottomQuarter = "rightBottomQuarter"
    case fullScreen = "fullScreen"
}

struct WindowConfig {
    var title : String
    var size : CGSize = CGSize(width: 300, height: 300)
    var position : CGPoint = CGPoint.zero
    var closable : Bool = true
    var minimizable : Bool = true
    var resizable : Bool = true
    var showLabel : Bool = true
    var showWindowBar : Bool = true
    var startPos : WindowPosMode = WindowPosMode.normal
}

struct invalid_controlbutton : View{
    @Binding var buttonSize : CGFloat
    var body: some View{
        Image(systemName: "circle.fill")
            .font(.system(size: buttonSize))
            .foregroundColor(Color.gray)
    }
}
