///
///  WeatherData.swift
///  Simple-Weather-App
///
///  Created by Artan Bajqinca on 2024-01-26.
///

import Foundation
import SwiftUI
import Observation

/// Represents the overall weather data fetched from the API, including both current and daily forecasts.

struct WeatherData: Decodable, Encodable{
    var longitude: Float
    var latitude: Float
    var current: CurrentWeather
    var daily: DailyWeather
}

/// Contains the current weather conditions including temperature, weather code, wind speed, and precipitation.

struct CurrentWeather: Decodable, Encodable {
    var temperature_2m: Float
    var weather_code: Int
    var wind_speed_10m: Float
    var precipitation: Float
}

/// Holds the forecasted daily weather data, including maximum and minimum temperatures, weather codes, and corresponding dates.

struct DailyWeather: Decodable, Encodable {
    var temperature_2m_max: [Float]
    var temperature_2m_min: [Float]
    var weather_code: [Int]
    var time: [String]
}

