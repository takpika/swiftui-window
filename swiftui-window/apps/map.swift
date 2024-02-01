//
//  map.swift
//  swiftui-window
//
//  Created by takumi saito on 2024/02/01.
//

import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct MapApp: View {
    static let config = WindowConfig(
        title: "Map"
    )
    
    var body: some View {
        Map()
    }
}
