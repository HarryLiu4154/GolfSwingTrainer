//
//  WeatherViewModel.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-19.
//

import Foundation
import WeatherKit
import CoreLocation

@MainActor
class WeatherViewModel: ObservableObject {
    private let weatherService = WeatherService()
        
    @Published var currentWeather: WeatherModel? // Holds the fetched weather data
    @Published var errorMessage: String?         // Holds any error messages

    func fetchWeather(for location: CLLocation?) async {
        guard let location = location else {
            errorMessage = "Unable to fetch location."
            return
        }
        
        do {
            let weather = try await weatherService.weather(for: location)
            let temperature = weather.currentWeather.temperature.value
            let condition = weather.currentWeather.condition.description
            
            currentWeather = WeatherModel(temperature: temperature, condition: condition)
        } catch {
            errorMessage = "Failed to fetch weather data: \(error.localizedDescription)"
        }
    }

}
