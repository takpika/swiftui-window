# SwiftUIWindow

SwiftUIWindow is an iOS library for building desktop-style window interfaces in SwiftUI.

This repository contains a Swift Package and an Xcode demo app.

## Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 15+

## Swift Package Manager

In Xcode:

1. Open `File > Add Package Dependencies...`
2. Enter this repository URL
3. Add `SwiftUIWindow` to your app target

In `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/takpika/swiftui-window.git", from: "0.1.0")
]
```

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "SwiftUIWindow", package: "swiftui-window")
    ]
)
```

## Usage

```swift
import SwiftUI
import SwiftUIWindow

struct ContentView: View {
    var body: some View {
        WindowDesktop {
            Window("Notes") {
                Text("Hello Window")
                    .padding()
            }
            .windowSize(width: 420, height: 280)
            .windowStartPosition(.center)
        } background: {
            Color.black
        }
    }
}
```

## Window Configuration

Configure windows with view modifiers.

```swift
Window("Inspector") {
    InspectorView()
}
.windowSize(width: 360, height: 520)
.windowPosition(CGPoint(x: 40, y: 40))
.windowClosable(true)
.windowMinimizable(false)
.windowResizable(true)
.windowShowsTitle(true)
.windowShowsBar(true)
.windowStartPosition(.rightHalf)
```

## Window Actions

Views inside a window can use environment values to update the current window.

```swift
struct ToolView: View {
    @Environment(\.titleSetKey) private var setTitle
    @Environment(\.closeKey) private var close

    var body: some View {
        VStack {
            Button("Rename") {
                setTitle?("Renamed")
            }

            Button("Close") {
                close?()
            }
        }
    }
}
```

## Demo App

The `swiftui-window.xcodeproj` demo app includes browser, calculator, map, and Metal demo windows.
