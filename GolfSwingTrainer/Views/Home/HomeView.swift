//
//  HomeView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-14.
//

import SwiftUI
/*using this temporary home screen until team makes the refined one*/

struct HomeScreen: View {
    @State var showMenu = false
    var body: some View {
        let drag = DragGesture() //drag to close
            .onEnded{
                if $0.translation.width < -100{
                    withAnimation{
                        self.showMenu = false
                    }
                }
            }
        return NavigationStack{
            GeometryReader{ geometry in
                HomeView(showMenu: self.$showMenu).frame(width: geometry.size.width, height: geometry.size.height)
                    .offset(x: self.showMenu ?
                            geometry.size.width/2 : 0)
                    .disabled(self.showMenu ? true : false)
                if self.showMenu{
                    MenuView()
                        .frame(width: geometry.size.width/2)
                        .transition(.move(edge: .leading))
                }
            }
            .gesture(drag)
        }.navigationTitle("Side Menu")
            .toolbar{
                ToolbarItem(placement: .topBarLeading, content: {
                    Button(action: {
                        withAnimation {
                            self.showMenu.toggle()
                        }
                    }, label: {
                        Image(systemName: "line.horizontal.3").imageScale(.large)
                    })
                }
                            
                )
            }
    }
}
struct HomeView: View {
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    @EnvironmentObject var swingSessionViewModel: SwingSessionViewModel
    
    @Binding var showMenu: Bool
    
    var body: some View {
        NavigationStack{
            ScrollView{
                WeatherComponentView()
            }

            

        }.navigationTitle("Home")
            .refreshable {
                 
            }
    }
}

#Preview {
    let showMenu = false
    let coreDataService = CoreDataService()
    let firebaseService = FirebaseService()
    let userDataViewModel = UserDataViewModel(
        coreDataService: coreDataService,
        firebaseService: firebaseService
    )
    HomeView(showMenu: .constant(showMenu)).environmentObject(userDataViewModel)
}
