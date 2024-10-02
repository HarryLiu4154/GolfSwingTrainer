//
//  HomeView.swift
//  GolfSwingTrainer Watch App
//
//  Created by David Romero on 2024-09-15.
//

import Foundation
import SwiftUI


struct HomeView: View {
    var body: some View {
        NavigationStack{
        
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
    }
        .padding()
    }
}

#Preview {
    HomeView()
}
