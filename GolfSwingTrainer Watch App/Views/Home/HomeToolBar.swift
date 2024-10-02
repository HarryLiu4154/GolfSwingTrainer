//
//  HomeToolBar.swift
//  GolfSwingTrainer Watch App
//
//  Created by David Romero on 2024-10-02.
//

import SwiftUI

struct HomeToolBar: View {
    
    var body: some View {
        NavigationStack{
            ScrollView (.horizontal){
                Text("")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            NavigationLink {
                                //
                            } label: {
                                Image(systemName:"gear")
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink {
                                //
                            } label: {
                                Image(systemName:"chart.bar")
                            }
                        }
                        ToolbarItemGroup(placement: .bottomBar) {
                            NavigationLink {
                                UserAccountView()
                            } label: {
                                Image(systemName:"person.crop.circle")
                            }
                            
                            NavigationLink {
                                //
                                AnalyticsView()
                            } label: {
                                Image(systemName:"figure.golf")
                            }
                            .controlSize(.large)
                            .background(.green, in: Capsule())
                            
                            NavigationLink {
                                //
                            } label: {
                                
                                Image(systemName:"cloud")
                            }
                        }
                    }
            }
            
        }.navigationTitle("Home")
    }
}

#Preview {
    HomeToolBar()
}
