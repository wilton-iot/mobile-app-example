//
//  ContentView.swift
//  ios
//
//  Created by Alexey Liverty on 5/8/20.
//  Copyright © 2020 alex. All rights reserved.
//

import SwiftUI
import WebKit

class ViewContext: ObservableObject {
    @Published var webViewShow = false
    var webViewUrl = ""
    var webView: WKWebView? = nil
}

struct AppWebView : UIViewRepresentable {
    @EnvironmentObject var vc: ViewContext
    
    func makeUIView(context: Context) -> WKWebView  {
        if nil == vc.webView {
            vc.webView = WKWebView()
        }
        return vc.webView!
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<AppWebView>) {
        let url = URL(string: vc.webViewUrl) ?? URL(string: "INVALID_URL")!
        let req = URLRequest(url: url)
        uiView.load(req)
    }
}

struct ContentView: View {
    @EnvironmentObject var vc: ViewContext
    
    var body: some View {
        Group() {
            if vc.webViewShow {
                AppWebView()
            } else {
                Text("...")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
