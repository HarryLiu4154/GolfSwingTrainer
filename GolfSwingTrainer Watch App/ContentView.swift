//
//  ContentView.swift
//  GolfSwingTrainer Watch App
//
//  Created by Harry Liu on 2024-09-10.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(String(localized: "Hello, world!"))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
