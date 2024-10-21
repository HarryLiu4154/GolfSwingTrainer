//
//  BottomNavigation.swift
//  GolfSwingTrainer
//
//  Created by Harry Liu on 2024-09-30.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case Home = "house"
    case Tracker = "chart.bar"
    case Friends = "person.2"
    case Settings = "gearshape"
    
    var tabName: String {
        switch self {
            case .Home: return "Home"
            case .Tracker: return "Tracker"
            case .Friends: return "Friends"
            case .Settings: return "Settings"
        }
    }
}

struct CustomBottomNavigation: View {
    @State var selectedTab: Tab = .Home
    
    @Binding var index: Int
    
    var body: some View {
        ZStack {
            Button(action: {
                
            }) {
                Image(systemName: "figure.golf")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            .padding(20)
            .background(Color.green)
            .clipShape(Circle())
            .shadow(color: .gray, radius: 5, x: 0, y: 5)
            .offset(y: -30)
            
            HStack {
                Button(action: {
                    self.index = 0
                }) {
                    Image(systemName: self.index == 0 ? Tab.Home.rawValue + ".fill" : Tab.Home.rawValue)
                }
                .font(.system(size: 20))
                .foregroundColor(Color.white)
                
                Spacer(minLength: 0)
                
                Button(action: {
                    self.index = 1
                }) {
                    Image(systemName: self.index == 1 ? Tab.Tracker.rawValue + ".fill" : Tab.Tracker.rawValue)
                }
                .font(.system(size: 20))
                .foregroundColor(Color.white)
                .offset(x: -22)
                
                Spacer(minLength: 0)
                
                Button(action: {
                    self.index = 2
                }) {
                    Image(systemName: self.index == 2 ? Tab.Friends.rawValue + ".fill" : Tab.Friends.rawValue)
                }
                .font(.system(size: 20))
                .foregroundColor(Color.white)
                .offset(x: 22)
                
                Spacer(minLength: 0)
                
                Button(action: {
                    self.index = 3
                }) {
                    Image(systemName: self.index == 3 ? Tab.Settings.rawValue + ".fill" : Tab.Settings.rawValue)
                }
                .font(.system(size: 20))
                .foregroundColor(Color.white)
            }
            .padding(.horizontal, 35)
            .padding(.vertical, 35)
            .padding(.top, 35)
            .background(Color("Background"))
            .clipShape(CurveShape())
        }
    }
    
    func TabButton(tab: Tab) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedTab = tab
            }
        }, label: {
            VStack(spacing: 0) {
                Image(systemName: selectedTab == tab ? tab.rawValue + ".fill" : tab.rawValue)
            }
        })
    }
    
}

struct CurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: 0, y: 35))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 35))
            
            path.addArc(center: CGPoint(x: rect.width / 2, y: 35), radius: 42, startAngle: .zero, endAngle: .init(degrees: 180), clockwise: false)
        }
    }
}

struct temp: View {
    @State var selectedTab: Tab = .Home
    
    @Namespace var animation
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Image(systemName: selectedTab.tabName) }
            TrackerView()
                .tabItem { Image(systemName: selectedTab.tabName) }
        }
        .overlay(
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    TabButton(tab: tab)
                }
            }
        )
    }
    
    func TabButton(tab: Tab) -> some View {
        GeometryReader { proxy in
            Button(action: {
                withAnimation(.spring()) {
                    selectedTab = tab
                }
            }, label: {
                VStack(spacing: 0) {
                    Image(systemName: selectedTab == tab ? tab.rawValue + ".fill" : tab.rawValue)
                }
            })
        }
    }
}

#Preview {
    ContentView()
//    CustomBottomNavigation(index:)
}
