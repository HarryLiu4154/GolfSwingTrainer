//
//  ProgressView.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-10-01.
//

import SwiftUI

struct ProgressView: View {
    private let timeframes = ["Day", "Week", "Month", "Year"]
    
    var body: some View {
        VStack{
            Text("Your Progress")
                .font(.title)
            ScrollView{
                Spacer()
                ForEach(timeframes, id: \.self){timeframe in
                    NavigationLink{
                        ProgressDetailsView(timeframe: timeframe)
                    }label:{
                        ProgressionComponentView(title: timeframe, chart: Image("movement_graph"))
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ProgressView()
}
