//
//  ProgressionComponentView.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-10-01.
//

import SwiftUI

struct ProgressionComponentView: View {
    var title: String
    var chart: Image
    
    var body: some View {
        VStack{
            HStack{
                Text(title)
                Spacer()
            }
            chart
                .resizable()
                .scaledToFit()
        }
        .padding()
    }
}

#Preview {
    ProgressionComponentView(title: "Week", chart: Image("movement_graph"))
}
