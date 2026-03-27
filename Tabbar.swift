//
//  Tabbar.swift
//  Smart Salon
//
//  Created by AD-LAB on 05/12/25.
//

import SwiftUI

struct Tabbar: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor.systemGray2
    }

    var body: some View {
        TabView {
            
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            MySalonView()
                .tabItem {
                    Image(systemName: "circle.fill")
                    Text("My Saloon")
                }
            ProfilePage()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.blue)
    }
}

