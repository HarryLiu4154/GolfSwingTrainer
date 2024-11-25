//
//  ProgressView.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-10-01.
//

import SwiftUI

struct ProgressView: View {
    private let timeframes = [String(localized: "Day"), String(localized: "Week"), String(localized: "Month"), String(localized: "Year")]
    
    var body: some View {
        VStack{
            Text(String(localized: "Your Progress"))
                .font(.title)
            NavigationLink{
                SessionView()
            }label: {
                Text(String(localized: "Session"))
            }
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
