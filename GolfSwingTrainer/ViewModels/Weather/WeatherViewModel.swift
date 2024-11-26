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
            // Fetch weather data
            let weather = try await weatherService.weather(for: location)

            // Extract wind direction
            let windDirection = Self.directionFrom(degrees: weather.currentWeather.wind.direction.value)

            // Update the model with additional wind direction
            currentWeather = WeatherModel(
                temperature: weather.currentWeather.temperature.value,
                condition: weather.currentWeather.condition.description,
                feelsLike: weather.currentWeather.apparentTemperature.value,
                windSpeed: weather.currentWeather.wind.speed.value,
                windDirection: windDirection,
                humidity: weather.currentWeather.humidity * 100, // Convert to percentage
                //precipitationProbability: weather.currentWeather.precipitationChance * 100,
                uvIndex: weather.currentWeather.uvIndex.value
            )
        } catch {
            errorMessage = "Failed to fetch weather data: \(error.localizedDescription)"
        }
    }

    // Helper function to convert wind direction in degrees to compass directions
    private static func directionFrom(degrees: Double) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"]
        let index = Int((degrees / 45.0).rounded()) % 8
        return directions[index]
    }

}
