
import SwiftUI
import UIKit
import WebKit

struct ContentView: View {
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                WindowDesktop {
                    Window("Debug Menu") {
                        TestView()
                    }
                    .windowSize(width: 400, height: 200)
                    .windowClosable(false)
                    .windowMinimizable(false)
                    .windowResizable(false)
                } background: {
                    Image("Desktop")
                        .resizable()
                        .scaledToFill()
                        .clipped()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
