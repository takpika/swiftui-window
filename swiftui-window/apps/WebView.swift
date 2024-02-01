import SwiftUI
import WebKit
import Combine

public class SUIWebBrowserObject: WKWebView, WKNavigationDelegate, ObservableObject {
   private var observers: [NSKeyValueObservation?] = []
   
   private func subscriber<Value>(for keyPath: KeyPath<SUIWebBrowserObject, Value>) -> NSKeyValueObservation {
       observe(keyPath, options: [.prior]) { object, change in
           if change.isPrior {
               self.objectWillChange.send()
           }
       }
   }
   
   private func setupObservers() {
       observers = [
           subscriber(for: \.title),
           subscriber(for: \.url),
           subscriber(for: \.isLoading),
           subscriber(for: \.estimatedProgress),
           subscriber(for: \.hasOnlySecureContent),
           subscriber(for: \.serverTrust),
           subscriber(for: \.canGoBack),
           subscriber(for: \.canGoForward)
       ]
   }
   
   public override init(frame: CGRect = .zero, configuration: WKWebViewConfiguration = WKWebViewConfiguration()) {
       if #available(iOS 17.0, *) {
           configuration.allowsInlinePredictions = true
       }
       configuration.allowsInlineMediaPlayback = true
       configuration.allowsAirPlayForMediaPlayback = true
       configuration.allowsPictureInPictureMediaPlayback = true
       configuration.applicationNameForUserAgent = "Version/17.2 Safari/605.1.15"
       super.init(
        frame: frame,
        configuration: configuration
       )
       navigationDelegate = self
       self.allowsBackForwardNavigationGestures = true
       setupObservers()
   }
   
   public required init?(coder: NSCoder) {
       super.init(coder: coder)
       navigationDelegate = self
       setupObservers()
   }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy(rawValue: WKNavigationActionPolicy.allow.rawValue + 2)!)
    }
}

public struct SUIWebBrowserView: UIViewRepresentable {
   public typealias UIViewType = UIView
   
   private var browserObject: SUIWebBrowserObject
   
   public init(browserObject: SUIWebBrowserObject) {
       self.browserObject = browserObject
   }
   
   public func makeUIView(context: Self.Context) -> Self.UIViewType {
       browserObject
   }
   
   public func updateUIView(_ uiView: Self.UIViewType, context: Self.Context) {
       //
   }
}

struct WebBrowserBackButton: View {
    @ObservedObject var browser: SUIWebBrowserObject
    
    func ItemImage(systemName: String) -> some View {
        Image(systemName: systemName)
            .imageScale(.large).aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
    }
    
    var body: some View {
        Button(action: {
            self.browser.goBack()
        }) {
            ItemImage(systemName: "chevron.left")
        }.disabled(!browser.canGoBack)
    }
}

struct WebBrowserForwardButton: View {
    @ObservedObject var browser: SUIWebBrowserObject
    
    func ItemImage(systemName: String) -> some View {
        Image(systemName: systemName)
            .imageScale(.large).aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
    }
    
    var body: some View {
        Button(action: {
            self.browser.goForward()
        }) {
            ItemImage(systemName: "chevron.right")
        }.disabled(!browser.canGoForward)
    }
}

struct WebBrowserReloadButton: View {
    @ObservedObject var browser: SUIWebBrowserObject
    
    func ItemImage(systemName: String) -> some View {
        Image(systemName: systemName)
            .imageScale(.medium).aspectRatio(contentMode: .fit)
    }
    
    var body: some View {
        Button(action: {
            if self.browser.isLoading {
                self.browser.stopLoading()
            } else {
                self.browser.reload()
            }
        }) {
            ItemImage(systemName: browser.isLoading
                ? "xmark"
                : "arrow.clockwise"
            )
        }
    }
}

struct WebBrowserTextFieldButton: View {
    @ObservedObject var browser: SUIWebBrowserObject
    @Binding var urlText: String
    @Binding var isEditing: Bool
    
    var body: some View {
        if (isEditing) {
            Button(action: {
                urlText = ""
            }) {
                Image(systemName: "xmark.square.fill")
                    .imageScale(.medium).aspectRatio(contentMode: .fit)
            }
            .padding(.horizontal)
            .foregroundStyle(Color("Text"))
        } else {
            WebBrowserReloadButton(browser: browser)
                .foregroundStyle(Color("Text"))
                .padding(.horizontal)
        }
    }
}

struct WebBrowserLoadingProgress: View {
    @ObservedObject var browser: SUIWebBrowserObject
    
    var body: some View {
        VStack {
            Spacer()
            if (browser.isLoading) {
                ProgressView(value: browser.estimatedProgress)
            }
        }
    }
}

struct WebBrowser: View {
    @ObservedObject var browser = SUIWebBrowserObject()
    @Environment(\.titleSetKey) var set_title
    @Environment(\.actionBarAddKey) var add_actionBar
    @Environment(\.actionBarClearKey) var clear_actionBar
    @Environment(\.windowBarHeightSetKey) var changeWindowBarHeight
    
    @State private var urlText : String = ""
    @State private var loadingProgress : Double = 0.0
    @State private var isEditing : Bool = false
    
    static let config = WindowConfig(
        title: "Browser Test",
        size: CGSize(width: 800, height: 600),
        showLabel: false,
        startPos: WindowPosMode.center
    )
   
   init(address: String) {
       guard let a = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
       guard let u = URL(string: a) else { return }
       browser.load(URLRequest(url: u))
   }
   
   var body: some View {
       SUIWebBrowserView(browserObject: browser)
           .onAppear() {
               changeWindowBarHeight!(60)
               clear_actionBar!()
               add_actionBar!(AnyView(GeometryReader{ geo in
                   HStack {
                      WebBrowserBackButton(browser: browser)
                      WebBrowserForwardButton(browser: browser)
                      Spacer(minLength: 0)
                      ZStack {
                          Rectangle()
                              .fill(Color("Background"))
                          HStack {
                              TextField(
                                "", text: $urlText,
                                onEditingChanged: {edit in
                                    isEditing = edit
                                },
                                onCommit: {
                                    print(urlText)
                                }
                              )
                                  .padding(.horizontal)
                              Spacer(minLength: 0)
                              WebBrowserTextFieldButton(browser: browser, urlText: $urlText, isEditing: $isEditing)
                          }
                          WebBrowserLoadingProgress(browser: browser)
                      }
                        .cornerRadius(5)
                        .frame(width: geo.size.width / 2)
                        .padding(.all, 8)
                      Spacer(minLength: 0)
                  }
                   .frame(width: geo.size.width)
               }))
               urlText = browser.url?.absoluteString ?? ""
           }
           .onChange(of: browser.title, perform: { value in
               set_title!("Browser Test - \(browser.title ?? "")")
           })
           .onChange(of: browser.url, perform: { value in
               urlText = value?.absoluteString ?? ""
           })
           .onChange(of: browser.estimatedProgress) { value in
               loadingProgress = value
           }
   }
}
