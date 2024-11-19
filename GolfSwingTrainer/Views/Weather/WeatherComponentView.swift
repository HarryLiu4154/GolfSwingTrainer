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
        VStack(spacing: 10) {
            // Show weather data
            if let weather = weatherViewModel.currentWeather {
                HStack {
                    Image(systemName: "thermometer.medium")
                        .foregroundColor(.blue)
                    Text("\(String(format: "%.1f", weather.temperature))°C")
                        .font(.headline)
                    Text(weather.condition)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            } else if let error = weatherViewModel.errorMessage {
                Image(systemName: "thermometer.medium.slash")
                    .foregroundColor(.blue)
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            } else {
                //
            }
        }
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
