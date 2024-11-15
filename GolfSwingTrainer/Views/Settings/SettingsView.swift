//
//  SettingsView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-14.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    var body: some View {
        NavigationStack{
            Form{
                Section(header: Text(String(localized: "Display")), footer: Text(String(localized: "Adjust your screen"))){
                    Toggle(isOn: $viewModel.darkModeEnabled,
                           label: {
                        Text(String(localized: "Dark Mode"))
                    })
                    
                }
                Section(header: Text(String(localized: "Your Information")), footer: Text(String(localized: "Edit your information"))){
                    NavigationLink("Your attributes", destination: SettingsAttributesView())
                    
                }
            }.navigationTitle("Settings")
                .preferredColorScheme(viewModel.darkModeEnabled ? .dark : .light) 
        }
    }
}

#Preview {
    SettingsView().environmentObject(SettingsViewModel())
}
