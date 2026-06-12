# SwiftUIWindow

SwiftUI でデスクトップ風のウィンドウシステムを作るための iOS 向けライブラリです。

このリポジトリには Swift Package と、動作確認用の Xcode デモアプリが含まれています。

## 必要環境

- iOS 15.0+
- Swift 5.9+
- Xcode 15+

## Swift Package Manager

Xcode から追加する場合:

1. `File > Add Package Dependencies...`
2. このリポジトリの URL を入力
3. `SwiftUIWindow` をアプリターゲットへ追加

`Package.swift` から使う場合:

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

## 使い方

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

## ウィンドウ設定

`Window` に View Modifier を付けて設定します。

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

## ウィンドウ内から操作する

ウィンドウ内の View では Environment から操作 API を取得できます。

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

## 外部から操作する

必要な場合だけ `WindowDesktopController` を `WindowDesktop` に渡すと、デスクトップの外側にある View からウィンドウを追加、前面化、閉じる操作ができます。

```swift
struct ContentView: View {
    @StateObject private var desktopController = WindowDesktopController()

    var body: some View {
        VStack {
            Button("Open Notes") {
                desktopController.addWindow(config: WindowConfig(title: "Notes", startPos: .center)) {
                    Text("Hello Window")
                        .padding()
                }
            }

            WindowDesktop(controller: desktopController) {
                Window("Inspector") {
                    Text("Inspector")
                }
            } background: {
                Color.black
            }
        }
    }
}
```

`windowIDs` と `activeWindowID` は `@Published` なので、外部 UI から現在の状態を監視できます。

## デモアプリ

`swiftui-window.xcodeproj` にはデモアプリが含まれています。ブラウザ、電卓、Map、Metal 表示デモをウィンドウとして開けます。
