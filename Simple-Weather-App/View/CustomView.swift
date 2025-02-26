///
///  WeatherView.swift
///  Simple-Weather-App
///
///  Created by Artan Bajqinca on 2024-01-26.
///

import Foundation
import SwiftUI
import Observation

/// The background view of the app

struct Background: View {
    var body: some View {
        ZStack {
            Color.blue.opacity(0.9)
                .edgesIgnoringSafeArea(.all)
            
            Image("bg").scaleEffect(1.1)
            
            Image("buildings-bg")
                .aspectRatio(contentMode: .fit)
                .scaleEffect(0.3)
                .offset(x: -170, y: 270)
        }
        .frame(width: 100, height: 100)
    }
}

/// Displays the current location's city and country name.

struct locationName: View {

    var body: some View {
        
        ZStack {
            if let weatherCode = weatherViewModel.currentWeatherCode {
            } else {
                Text("Locating...")
                    .font(.custom("Avenir", size: 30).weight(.black))
                    .foregroundColor(.white)
                    .padding(.top, 50)
            }
        }
        
        HStack {
            Text(weatherViewModel.locationService.cityName?.uppercased() ?? "")
                .font(.custom("Avenir", size: 20).weight(.black))
                .foregroundColor(.white)
            
            Text(weatherViewModel.locationService.countryName?.uppercased() ?? "")
                .font(.custom("Avenir", size: 20).weight(.semibold))
                .foregroundColor(.white)
        }

        .padding(.top, 40)
        .onAppear() {
            weatherViewModel.locationService.requestLocation()
        }
        .onChange(of: weatherViewModel.locationService.location) { _, newValue in
            guard let location = newValue else { return }
            Task {
                await weatherViewModel.updateWeather(for: location)
            }
        }
    }
}

/// Displays the current weather icon based on the weather condition.

struct weatherIcon: View {
    
    var body: some View {
        
        Group {
            if let weatherCode = weatherViewModel.currentWeatherCode {
                Image(weatherCode.bigIcon)
            }
        }
        .frame(height: 140)
        .scaleEffect(0.3)
        .padding(.top, 30)
    }
}

/// A view component displaying a weather condition with an icon and text description.

struct WeatherConditionView: View {
    var iconName: String
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .fontWeight(.ultraLight)
            
            Text(text)
                .font(.custom("Avenir", size: 14))
                .foregroundColor(.white)
                .fontWeight(.thin)
                .frame(maxWidth: 120, alignment: .leading)
        }
    }
}

/// Displays the current temperature and additional weather conditions.

struct currentWeather: View {

    var body: some View {
        
        HStack {
            if let weatherCode = weatherViewModel.currentWeatherCode {
                Text(String(format: "%.0f°", weatherViewModel.weatherData?.current.temperature_2m ?? 0))
                    .font(.custom("Helvetica Neue", size: 120).weight(.thin))
                    .foregroundColor(.white)
                
                weatherConditions()
            }
        }.padding(.leading, 70)
    }
}

/// Additional weather conditions like wind speed and precipitation.

struct weatherConditions: View {
    
    var body: some View {
        
        VStack(spacing: 5) {
            if let weatherCode = weatherViewModel.currentWeatherCode {
                WeatherConditionView(iconName: weatherCode.smallIcon, text: weatherCode.weatherDesc)
                
                WeatherConditionView(iconName: "wind", text: String(format: "%.0f m/s", weatherViewModel.weatherData?.current.wind_speed_10m ?? 0))
                
                WeatherConditionView(iconName: "umbrella", text: String(format: "%.0f %%", weatherViewModel.weatherData?.current.precipitation ?? 0))
            }
        }
    }
}

/// Displays the forecast for the next few days.

struct weeklyWeather: View {
    
    var body: some View {
        
        HStack {
            let times = weatherViewModel.weatherData?.daily.time.dropFirst().prefix(5) ?? []
            let count = times.count
            ForEach(0..<count, id: \.self) { index in
                let adjustedIndex = index + 1
                if let dateString = weatherViewModel.weatherData?.daily.time[adjustedIndex],
                   let dayName = weatherViewModel.getDayName(from: dateString),
                   let maxTemp = weatherViewModel.weatherData?.daily.temperature_2m_max[adjustedIndex],
                   let minTemp = weatherViewModel.weatherData?.daily.temperature_2m_min[adjustedIndex] {
                    let weatherCode = WeatherCode(rawValue: weatherViewModel.weatherData?.daily.weather_code[adjustedIndex] ?? 0)
                    let iconName = weatherCode?.smallIcon ?? "cloud"
                    
                    WeeklyWeatherView(
                        day: dayName,
                        iconName: iconName,
                        highTemp: String(format: "%.0f°", maxTemp),
                        lowTemp: String(format: "%.0f°", minTemp)
                    )
                }
            }.padding(.top, 15)
        }

    }
}

/// A view component displaying daily weather information including day, weather condition icon, and temperatures.

struct WeeklyWeatherView: View {
    var day: String
    var iconName: String
    var highTemp: String
    var lowTemp: String
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 45, height: 100)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 1)
                )
            VStack(spacing: 0) {
                Text(day)
                    .font(.custom("Avenir", size: 14))
                    .foregroundColor(.white)
                    .fontWeight(.ultraLight)
                    .padding(.top, 5)
                    .padding(.bottom, 0)
                
                Spacer()
                
                ZStack {
                    Image(systemName: iconName)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .fontWeight(.ultraLight)
                        .offset(y: -37)
                    
                    Spacer()
                    
                    VStack {
                        Text(highTemp)
                            .font(.custom("Avenir", size: 14))
                            .foregroundColor(.white)
                            .fontWeight(.ultraLight)
                            .padding(.bottom, -10)
                        
                        Text(lowTemp)
                            .font(.custom("Avenir", size: 14))
                            .foregroundColor(Color(#colorLiteral(red: 0.6817840338, green: 0.6817839742, blue: 0.6817840338, alpha: 1)))
                            .fontWeight(.ultraLight)
                            .padding(.bottom, 5)
                    }
                }
            }.frame(height: 100)
//                .background(.blue)
        }.padding(1)
    }
}


#Preview {
    VStack {
        WeeklyWeatherView(day: "mån", iconName: "cloud.rain", highTemp: "0°", lowTemp: "0°")
    }.background(.blue)

}
