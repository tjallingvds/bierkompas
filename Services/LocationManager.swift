import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private var lastLocationCheck: CLLocation?
    private let distanceThreshold: Double = 200 // meters
    
    @Published var userLocation: CLLocation?
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var heading: CLHeading?
    @Published var shouldUpdateLocation = true
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func startUpdatingHeading() {
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }
    
    func stopUpdatingHeading() {
        locationManager.stopUpdatingHeading()
    }
    
    func calculateBearing(to destination: CLLocationCoordinate2D) -> Double? {
        guard let userLocation = userLocation else { return nil }
        
        let lat1 = userLocation.coordinate.latitude.radians
        let lon1 = userLocation.coordinate.longitude.radians
        
        let lat2 = destination.latitude.radians
        let lon2 = destination.longitude.radians
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        // Convert to degrees
        var degreesBearing = radiansBearing.degrees
        // Normalize to 0-360
        degreesBearing = (degreesBearing + 360).truncatingRemainder(dividingBy: 360)
        
        return degreesBearing
    }
    
    func shouldCheckLocation() -> Bool {
        guard let lastLocationCheck = lastLocationCheck, let currentLocation = userLocation else {
            // If we don't have both locations, we should check
            return true
        }
        
        // Check if we've moved more than the threshold
        let distance = currentLocation.distance(from: lastLocationCheck)
        return distance > distanceThreshold
    }
    
    func updateLastCheckedLocation() {
        lastLocationCheck = userLocation
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
    }
}

extension Double {
    var radians: Double { return self * .pi / 180 }
    var degrees: Double { return self * 180 / .pi }
} 