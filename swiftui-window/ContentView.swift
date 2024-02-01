
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
