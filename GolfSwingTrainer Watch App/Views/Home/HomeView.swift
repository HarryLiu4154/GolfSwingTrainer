//
//  HomeView.swift
//  GolfSwingTrainer Watch App
//
//  Created by David Romero on 2024-09-15.
//

import Foundation
import SwiftUI

/* https://developer.apple.com/documentation/watchos-apps/creating-an-intuitive-and-effective-ui-in-watchos-10 */
struct HomeView: View {
   
    var body: some View {
        NavigationStack {
            ZStack {
                // Horizontal Scrolling Views
                TabView {
                    ContentView()
                    AnalyticsView()
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
