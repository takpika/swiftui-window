//
//  demoApps.swift
//  swiftui-window
//
//  Created by takumi saito on 2024/01/31.
//

import SwiftUI
import MapKit

struct TestView: View{
    @Environment(\.titleSetKey) var set_title
    @Environment(\.windowIDGetKey) var id
    @Environment(\.closeKey) var close
    @Environment(\.window_AllAddKey) var addWindow
    @Environment(\.sizeSetKey) var set_size
    @Environment(\.permission_GetKey) var permission_get
    @Environment(\.permission_SetKey) var permission_set
    @Environment(\.positionGetKey) var position
    @Environment(\.sizeGetKey) var size
    @Environment(\.windowPosMode_GetKey) var windowMode
    @Environment(\.windowPosMode_SetKey) var setWindowMode
    @State var text = ""
    
    var body: some View{
        VStack{
            TextField("Title", text: $text)
            HStack{
                Text("Test App:")
                Button("Browser"){
                    print(addWindow!(AnyView(WebBrowser(address: "https://www.google.co.jp")), WebBrowser.config))
                }
                Button("Calc") {
                    addWindow!(AnyView(CalculatorApp()), CalculatorApp.config)
                }
                if #available(iOS 17.0, *) {
                    Button("Map") {
                        addWindow!(AnyView(MapApp()), MapApp.config)
                    }
                }
                Spacer()
            }
            HStack{
                Text("Resize:")
                Spacer()
                if (permission_get!("Resize")) {
                    Button("LH"){
                        setWindowMode!(WindowPosMode.leftHalf)
                    }
                    Button("RH"){
                        setWindowMode!(WindowPosMode.rightHalf)
                    }
                    Button("FS"){
                        setWindowMode!(WindowPosMode.fullScreen)
                    }
                    Button("DS"){
                        set_size!(400,200)
                    }
                }
                Button("Toggle"){
                    permission_set!("Resize", !permission_get!("Resize"))
                }
            }
            HStack{
                Text("Window ID: \(id!())")
                Spacer()
                Button("Set title"){
                    set_title!(text)
                }
            }
            Text("Size: w: \(size.width) h: \(size.height)")
            Text("Pos: x: \(position.x) y: \(position.y)")
            Text("Mode: \(windowMode.rawValue)")
        }
        .padding()
    }
}

struct TestView2: View{
    var body: some View{
        Text("Hello Window World!")
    }
}

struct TestView3: View{
    var body: some View{
        Image("me_icon")
            .resizable()
            .scaledToFit()
    }
}

struct NaviTest: View{
    var body: some View{
        NavigationView {
                    List(1..<20) { index in
                        NavigationLink(destination: Text("\(index)番目のView")) {
                            Text("\(index)行目")
                        }
                    }
                    .navigationTitle("Top View")
                }
    }
}

struct ModalTest: View {
    
    @State private var showingModal = false
    
    var body: some View {
        Button(action: {
            self.showingModal.toggle()
        }) {
            Text("Show Modal.")
        }.sheet(isPresented: $showingModal) {
            ModalView()
        }
    }
}

struct ModalView: View {
    var body: some View {
        Text("Modal View.")
    }
}

struct AnimationTest: View {
    @State private var flag = true
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
                .scaleEffect(flag ? 1.0 : 2.0)
                .animation(.default)
 
            VStack {
                Spacer()
                Button("Animate") {
                    self.flag.toggle()
                }
            }
        }
    }
}
