/// ContentView.swift
/// Simple-Weather-App
///
/// Created by Artan Bajqinca on 2024-01-26.
///

import Foundation
import SwiftUI
import CoreLocationUI
import CoreLocation
import Observation

var weatherViewModel = WeatherViewModel()

/// The main view of the Simple Weather App, displaying the current weather and forecast.

struct ContentView: View {
    
    var body: some View {
        ZStack {
            Background()
            weatherStack
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    var weatherStack: some View {

        VStack(spacing: 0) {
            locationName()
            weatherIcon()
            currentWeather()
            weeklyWeather()
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
