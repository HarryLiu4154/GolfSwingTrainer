//
//  SettingRowComponentView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-04.
//

import SwiftUI

struct SettingRowComponentView: View {
    let imageName: String
    let title: String
    let tintColor: Color
    
    var body: some View {
        HStack(spacing: 12){
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundStyle(tintColor)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.black)
        }
        
    }
}

#Preview {
    SettingRowComponentView(imageName: "gear", title: "Verison", tintColor: Color(.systemGray))
}
