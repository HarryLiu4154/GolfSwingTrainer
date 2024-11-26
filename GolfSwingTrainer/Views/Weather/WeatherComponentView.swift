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
            if let weather = weatherViewModel.currentWeather {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Condition: \(weather.condition)")
                    Text("Temperature: \(String(format: "%.1f", weather.temperature))°C")
                        .font(.headline)
                    Text("Feels Like: \(String(format: "%.1f", weather.feelsLike))°C")
                    
                    Text("Wind: \(String(format: "%.1f", weather.windSpeed)) km/h")
                    Text("Wind Direction: \(weather.windDirection)")
                    Text("Humidity: \(String(format: "%.0f", weather.humidity))%")
                    /*Text("Precipitation: \(String(format: "%.0f", weather.precipitationProbability))%")*/
                    Text("UV Index: \(weather.uvIndex)")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            } else if let error = weatherViewModel.errorMessage {
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
