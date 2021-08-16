
import SwiftUI
import UIKit
import WebKit

struct ContentView: View {
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                window_system()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TestView: View{
    @Environment(\.titleSetKey) var set_title
    @Environment(\.windowIDGetKey) var id
    @Environment(\.closeKey) var close
    @Environment(\.window_AllAddKey) var addWindow
    @Environment(\.sizeSetKey) var set_size
    @Environment(\.permission_SetKey) var permission_set
    @Environment(\.positionGetKey) var position
    @Environment(\.sizeGetKey) var size
    @Environment(\.fullScreen_GetKey) var isfullScreen
    @Environment(\.fullScreen_SetKey) var setfullScreen
    @State var text = ""
    
    var body: some View{
        VStack{
            TextField("Title", text: $text)
            HStack{
                Text("Test App:")
                Button("Navi"){
                    print(addWindow!(AnyView(NaviTest()), "Navigation Test", CGSize(width: 300, height: 300), CGPoint(x: 100, y: 100), true, true, true))
                }
                Button("Modal"){
                    print(addWindow!(AnyView(ModalTest()), "Modal Test", CGSize(width: 300, height: 300), CGPoint(x: 100, y: 100), true, true, true))
                }
                Button("Animation"){
                    print(addWindow!(AnyView(AnimationTest()), "Modal Test", CGSize(width: 500, height: 500), CGPoint(x: 100, y: 100), true, true, true))
                }
                Button("Browser"){
                    print(addWindow!(AnyView(WebBrowser(address: "https://www.google.co.jp")), "Browser Test", CGSize(width: 300, height: 300), CGPoint(x: 100, y: 100), true, true, true))
                }
                Spacer()
            }
            HStack{
                Text("Resize:")
                Spacer()
                Button("F-S"){
                    setfullScreen!()
                }
                Button("350x200"){
                    set_size!(350,200)
                }
                Button("ON"){
                    permission_set!("Resize", true)
                }
                Button("OFF"){
                    permission_set!("Resize", false)
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
            Text("FullScreen: \(String(isfullScreen))")
        }
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
