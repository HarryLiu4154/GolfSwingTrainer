//
//  HomeView.swift
//  GolfSwingTrainer Watch App
//
//  Created by David Romero on 2024-10-02.
//  

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                TabView {
                    //TODO: Determine quick view's
                    ContentView()
                    
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Horizontal swiping without dots
                
            }
            
            HomeToolBar()
            
        }
    }
}

#Preview {
    HomeView()
}
