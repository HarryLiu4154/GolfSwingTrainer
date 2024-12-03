//
//  WeatherComponentView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-19.
//

import SwiftUI
import CoreLocation

struct WeatherComponentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherViewModel = WeatherViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            if let weather = weatherViewModel.currentWeather {
                VStack(alignment: .leading, spacing: 15) {
                    HStack(spacing: 15) {
                        if let symbolName = weather.symbolName {
                            Image(systemName: symbolName).resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                        Text(weather.condition)
                            .font(.title)
                            .bold()
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("🌡️ Temperature:")
                                .bold()
                            Text("\(String(format: "%.1f", weather.temperature))°C")
                        }
                        HStack {
                            Text("🌬️ Wind:")
                                .bold()
                            Text("\(String(format: "%.1f", weather.windSpeed)) km/h (\(weather.windDirection))")
                        }
                        HStack {
                            Text("💧 Humidity:")
                                .bold()
                            Text("\(String(format: "%.0f", weather.humidity))%")
                        }
                        HStack {
                            Text("☀️ UV Index:")
                                .bold()
                            Text("\(weather.uvIndex)")
                        }
                    }
                }
                .padding()
                .background(
                    LinearGradient(colors: [Color.blue.opacity(0.2), Color.white], startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(15)
                .shadow(radius: 5)
            } else if let error = weatherViewModel.errorMessage {
                VStack {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        locationManager.requestLocation()
                    }
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(8)
                }
            } else {
                Text("Fetching Weather...") //loading
            }
        }
        .padding()
        .onAppear {
            locationManager.requestLocation()
        }
        .onReceive(locationManager.$location) { location in
            Task {
                await weatherViewModel.fetchWeather(for: location)
            }
        }
    }
}

#Preview {
    WeatherComponentView().environmentObject(LocationManager()).environmentObject(WeatherViewModel())
}
