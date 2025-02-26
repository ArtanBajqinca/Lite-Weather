///
///  LocationManager.swift
///  Simple-Weather-App
///
///  Created by Artan Bajqinca on 2024-01-29.
///

import Foundation
import CoreLocation
import SwiftUI

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    
    /// Private Properties
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    /// Public Properties
    
    var location: CLLocation?
    var countryName: String?
    var cityName: String?
    var address: CLPlacemark?
    
    /// Initialization
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    /// Configuration

    func requestLocation() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.requestLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if locationManager.authorizationStatus != .denied {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        reverseGeocodeLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error.localizedDescription)")
    }
    
    /// Fetches the address for the given location.

    private func reverseGeocodeLocation(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self, error == nil, let placemark = placemarks?.last else {
                print("Geocoding Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self.updateLocationDetails(with: placemark)
        }
    }
    
    private func updateLocationDetails(with placemark: CLPlacemark) {
        address = placemark
        cityName = placemark.locality ?? "Unknown"
        countryName = placemark.country ?? "Unknown"
        print("Location Updated: City: \(cityName ?? "Unknown"), Country: \(countryName ?? "Unknown")")
    }
}
