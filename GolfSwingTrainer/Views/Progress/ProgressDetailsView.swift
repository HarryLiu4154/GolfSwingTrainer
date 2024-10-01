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
                    Text("Swing")
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
                    Text("Distance")
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
                    Text("Stance")
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
                    Text("Swing Metadata")
                case .Distance:
                    Text("Distance Metadata")
                case .Stance:
                    Text("Stance Metadata")
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
    ProgressDetailsView(timeframe: "Day")
}
