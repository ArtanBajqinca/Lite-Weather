///
///  WeatherWidget.swift
///  WeatherWidget
///
///  Created by Artan Bajqinca on 2024-02-06.
///


import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(temperature: "Loading...")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let temperature = fetchCurrentTemperature()
        completion(SimpleEntry(temperature: temperature))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let temperature = fetchCurrentTemperature()
        let entry = SimpleEntry(temperature: temperature)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
        completion(timeline)
    }
    
    private func fetchCurrentTemperature() -> String {
        let sharedDefaults = UserDefaults(suiteName: "group.artan")
        guard let data = sharedDefaults?.data(forKey: "WeatherData"),
              let weatherData = try? JSONDecoder().decode(WeatherData.self, from: data) else {
            return "N/A"
        }
        return "\(weatherData.current.temperature_2m)°"
    }
}

struct SimpleEntry: TimelineEntry {
    let date = Date()
    let temperature: String
}

struct WeatherWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Current Temperature")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(entry.temperature)
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.white)
        }
        .padding()
        .frame(width: 1000, height: 1000)
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.5)]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(15)
    }
}

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Current Temperature")
        .description("Displays the current temperature.")
        .supportedFamilies([.systemMedium])
    }
}
