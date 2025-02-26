/// WeatherViewModel.swift
/// Simple-Weather-App
///
/// Created by Artan Bajqinca on 2024-01-26.
///

import Foundation
import SwiftUI
import CoreLocationUI
import CoreLocation
import Observation

/// Manages fetching and updating weather data.

@Observable
class WeatherViewModel {
    
    var locationManager = CLLocationManager()
    var locationService = LocationManager()
    
    var weatherData: WeatherData?
    var isLoading = false
    
    
    /// This function fetches weather data for specified coordinates
    
    func findWeather(latitude: Double, longitude: Double) async throws {
        guard let url = makeWeatherURL(latitude: latitude, longitude: longitude) else { return }
        isLoading = true
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
            
            // for sharing data with widget
            if let sharedDefaults = UserDefaults(suiteName: "group.artan") {
                if let encoded = try? JSONEncoder().encode(weatherData) {
                    sharedDefaults.set(encoded, forKey: "WeatherData")
                }
            }
            
            isLoading = false
        } catch {
            print("Error fetching weather data: \(error)")
            isLoading = false
        }
    }

    
    /// This function updates the weather information based on the user'
    
    func updateWeather(for location: CLLocation) async {
        do {
            try await findWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        } catch {
            print("Error while fetching weather: \(error.localizedDescription)")
        }
    }
    
    /// Helper function to construct the URL for the weather API request

    func makeWeatherURL(latitude: Double, longitude: Double) -> URL? {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,precipitation,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min&wind_speed_unit=ms"
        return URL(string: urlString)
    }
    
    /// Determines the current weather condition based on the weather code.
    
    var currentWeatherCode: WeatherCode? {
        guard let weatherCodeValue = weatherData?.current.weather_code else { return nil }
        return WeatherCode(rawValue: weatherCodeValue)
    }
    
    /// Converts a date string into a weekday name.
    /// - Parameter dateString: The date string to convert.
    /// - Returns: A string representing the day of the week.
    
    func getDayName(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = dateFormatter.date(from: dateString) else { return nil }
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: date).capitalized
    }
    
}

enum WeatherCode: Int {
    case clearSky = 0
    case mainlyClear = 1
    case partlyCloudy = 2
    case overcast = 3
    case fog = 45
    case depositingRimeFog = 48
    case drizzleLight = 51
    case drizzleModerate = 53
    case drizzleDense = 55
    case freezingDrizzleLight = 56
    case freezingDrizzleDense = 57
    case rainSlight = 61
    case rainModerate = 63
    case rainHeavy = 65
    case freezingRainLight = 66
    case freezingRainHeavy = 67
    case snowSlight = 71
    case snowModerate = 73
    case snowHeavy = 75
    case snowGrains = 77
    case rainShowersSlight = 80
    case rainShowersModerate = 81
    case rainShowersViolent = 82
    case snowShowersSlight = 85
    case snowShowersHeavy = 86
    case thunderstormSlightOrModerate = 95
    case thunderstormWithSlightHail = 96
    case thunderstormWithHeavyHail = 99

    var bigIcon: String {
        switch self {
        case .clearSky:
            return "sunny"
        case .mainlyClear, .partlyCloudy:
            return "sunnyCloud"
        case .overcast, .fog, .depositingRimeFog:
            return "veryCloudy"
        case .drizzleLight, .drizzleModerate, .drizzleDense, .rainSlight, .rainModerate, .rainHeavy, .freezingDrizzleLight, .freezingDrizzleDense, .freezingRainLight, .freezingRainHeavy:
            return "rainy"
        case .snowSlight, .snowModerate, .snowHeavy, .snowGrains, .snowShowersSlight, .snowShowersHeavy:
            return "snowing"
        case .rainShowersSlight, .rainShowersModerate, .rainShowersViolent:
            return "veryRainy"
        case .thunderstormSlightOrModerate, .thunderstormWithSlightHail, .thunderstormWithHeavyHail:
            return "thunder"
        }
    }

    var smallIcon: String {
        switch self {
        case .clearSky:
            return "sun.max"
        case .mainlyClear, .partlyCloudy:
            return "cloud.sun"
        case .overcast, .fog, .depositingRimeFog:
            return "cloud"
        case .drizzleLight, .drizzleModerate, .drizzleDense, .rainSlight, .rainModerate, .rainHeavy, .freezingDrizzleLight, .freezingDrizzleDense, .freezingRainLight, .freezingRainHeavy:
            return "cloud.drizzle"
        case .snowSlight, .snowModerate, .snowHeavy, .snowGrains, .snowShowersSlight, .snowShowersHeavy:
            return "cloud.snow"
        case .rainShowersSlight, .rainShowersModerate, .rainShowersViolent:
            return "cloud.rain"
        case .thunderstormSlightOrModerate, .thunderstormWithSlightHail, .thunderstormWithHeavyHail:
            return "cloud.bolt.rain"
        }
    }

    var weatherDesc: String {
        switch self {
        case .clearSky:
            return "Sunny"
        case .mainlyClear:
            return "Mostly Clear"
        case .partlyCloudy:
            return "Partly Cloudy"
        case .overcast:
            return "Overcast"
        case .fog, .depositingRimeFog:
            return "Foggy"
        case .drizzleLight:
            return "Light Drizzle"
        case .drizzleModerate:
            return "Moderate Drizzle"
        case .drizzleDense:
            return "Dense Drizzle"
        case .freezingDrizzleLight, .freezingDrizzleDense:
            return "Freezing Drizzle"
        case .rainSlight:
            return "Light Rain"
        case .rainModerate:
            return "Moderate Rain"
        case .rainHeavy:
            return "Heavy Rain"
        case .freezingRainLight, .freezingRainHeavy:
            return "Freezing Rain"
        case .snowSlight:
            return "Light Snow"
        case .snowModerate:
            return "Moderate Snow"
        case .snowHeavy:
            return "Heavy Snow"
        case .snowGrains:
            return "Snow Grains"
        case .rainShowersSlight:
            return "Light Rain Showers"
        case .rainShowersModerate:
            return "Moderate Rain Showers"
        case .rainShowersViolent:
            return "Violent Rain Showers"
        case .snowShowersSlight, .snowShowersHeavy:
            return "Snow Showers"
        case .thunderstormSlightOrModerate:
            return "Thunderstorm"
        case .thunderstormWithSlightHail:
            return "Thunderstorm with Hail"
        case .thunderstormWithHeavyHail:
            return "Severe Thunderstorm with Heavy Hail"
        }
    }
}
