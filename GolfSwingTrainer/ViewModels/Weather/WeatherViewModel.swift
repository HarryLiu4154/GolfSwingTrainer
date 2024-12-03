//
//  WeatherViewModel.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-19.
//

import Foundation
import WeatherKit
import CoreLocation
import UserNotifications

@MainActor
class WeatherViewModel: ObservableObject {
    private let weatherService = WeatherService()
    private var previousWindDirection: String? // Tracks previous wind direction (Notifications)
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

            // Extract current wind direction
            let windDirection = Self.directionFrom(degrees: weather.currentWeather.wind.direction.value)

            let oldDirection = previousWindDirection
            previousWindDirection = windDirection
            
            // Compare new direction with the previous one (Notifications)
            print("Previous Wind Direction: \(previousWindDirection ?? "None")")
            print("New Wind Direction: \(windDirection)")
            // Compare and trigger notification
            if let oldDirection = oldDirection, oldDirection != windDirection {
                print("Wind direction changed: \(oldDirection) -> \(windDirection)")
                sendWindDirectionNotification(newDirection: windDirection)
            } else {
                print("No wind direction change.")
            }
            //Retrieve old wind condition
            self.previousWindDirection = currentWeather?.windDirection
            
            // Update the model with additional wind direction
            currentWeather = WeatherModel(
                temperature: weather.currentWeather.temperature.value,
                condition: weather.currentWeather.condition.description,
                feelsLike: weather.currentWeather.apparentTemperature.value,
                windSpeed: weather.currentWeather.wind.speed.value,
                windDirection: windDirection,
                humidity: weather.currentWeather.humidity * 100, // Convert to percentage
                //precipitationProbability: weather.currentWeather.precipitationChance * 100,
                uvIndex: weather.currentWeather.uvIndex.value,
                symbolName: weather.currentWeather.symbolName
            )
        } catch {
            errorMessage = "Failed to fetch weather data: \(error.localizedDescription)"
        }
    }
    
    ///Triggers Notification once wind direction changes
    private func sendWindDirectionNotification(newDirection: String) {
        // Push Notification
        let content = UNMutableNotificationContent()
        content.title = "Wind Direction Update"
        content.body = "The wind direction has changed to \(newDirection)."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("Notification scheduled successfully")
            }
        }

        // In-App Notification
        NotificationCenter.default.post(name: Notification.Name("WindDirectionChanged"), object: nil, userInfo: [
            "title": "Wind Direction Update",
            "message": "The wind direction has changed to \(newDirection)."
        ])
    }


    /// Helper function to convert wind direction in degrees to compass directions
    private static func directionFrom(degrees: Double) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"]
        let index = Int((degrees / 45.0).rounded()) % 8
        return directions[index]
    }

}
