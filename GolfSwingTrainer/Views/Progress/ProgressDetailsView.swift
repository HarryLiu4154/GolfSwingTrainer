//
//  ProgressDetailsView.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-10-01.
//

import SwiftUI

struct ProgressDetailsView: View {
    var timeframe: String
    
    @State private var progressType: ProgressType = .Swing
    
    var body: some View {
        VStack{
            ProgressionComponentView(title: timeframe, chart: Image("movement_graph"))
            HStack{
                Spacer()
                Button(action:{
                    self.progressType = .Swing
                }, label: {
                    Text(String(localized: "Swing"))
                        .font(.title2)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .background(.blue)
                        .clipShape(Circle())
                })
                Spacer()
                Button(action:{
                    self.progressType = .Distance
                }, label: {
                    Text(String(localized: "Distance"))
                        .font(.title2)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .background(.blue)
                        .clipShape(Circle())
                })
                Spacer()
                Button(action:{
                    self.progressType = .Stance
                }, label: {
                    Text(String(localized: "Stance"))
                        .font(.title2)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .background(.blue)
                        .clipShape(Circle())
                })
                Spacer()
            }
            
            VStack{
                switch self.progressType {
                case .Swing:
                    Text(String(localized: "Swing Metadata"))
                case .Distance:
                    Text(String(localized: "Distance Metadata"))
                case .Stance:
                    Text(String(localized: "Stance Metadata"))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.9, green: 0.9, blue: 0.9))
            Spacer()
        }
    }
    
    enum ProgressType{
        case Swing, Distance, Stance
    }
}

#Preview {
    ProgressDetailsView(timeframe: String(localized: "Day"))
}
