//
//  TabView.swift
//  Mouse Don't Sleep!
//
//  Created by Tk on 2025/5/21.
//

import SwiftUI

struct Tabs: View {
    var body: some View{
        TabView {
            // 第一个标签页 General
            ContentView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("General")
                }
            // 第二个标签页 Donate
            DonateView()
                .tabItem {
                    Image(systemName:"dollarsign")
                    Text("Donate")
                }
        }
    }
}
#Preview {
    Tabs()
}
