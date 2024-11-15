//
//  HomeToolBar.swift
//  GolfSwingTrainer Watch App
//
//  Created by David Romero on 2024-10-02.
//  UI Reference -> https://developer.apple.com/documentation/watchos-apps/creating-an-intuitive-and-effective-ui-in-watchos-10
//  COPY-PASTED FROM PREVIOUS 'DAVID' BRANCH DUE TO CACHE ERROR

import SwiftUI

struct HomeToolBar: View {
    var body: some View {
        NavigationStack{
                    ScrollView (.horizontal){
                        Text(String(localized: ""))
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
                                        //UserAccountView()
                                    } label: {
                                        Image(systemName:"person.crop.circle")
                                    }
                                    
                                    NavigationLink {
                                        //
                                        GolfSessionView()
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
                    
        }.navigationTitle(String(localized: "Home"))
    }
}

#Preview {
    HomeToolBar()
}
