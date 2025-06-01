import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private var lastCheckedLocation: CLLocation?
    private let minimumCheckDistance: CLLocationDistance = 50 // meters
    
    @Published var userLocation: CLLocation?
    @Published var heading: CLHeading?
    @Published var locationStatus: CLAuthorizationStatus?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func shouldCheckLocation() -> Bool {
        guard let currentLocation = userLocation,
              let lastChecked = lastCheckedLocation else {
            return true // If we haven't checked before, we should check
        }
        
        // Only check for stores if we've moved more than minimumCheckDistance
        return currentLocation.distance(from: lastChecked) > minimumCheckDistance
    }
    
    func updateLastCheckedLocation() {
        lastCheckedLocation = userLocation
    }
    
    func calculateBearing(to coordinate: CLLocationCoordinate2D) -> Double? {
        guard let fromLocation = userLocation else { return nil }
        
        let fromLat = fromLocation.coordinate.latitude.toRadians()
        let fromLong = fromLocation.coordinate.longitude.toRadians()
        let toLat = coordinate.latitude.toRadians()
        let toLong = coordinate.longitude.toRadians()
        
        let dLong = toLong - fromLong
        
        let y = sin(dLong) * cos(toLat)
        let x = cos(fromLat) * sin(toLat) - sin(fromLat) * cos(toLat) * cos(dLong)
        var radiansBearing = atan2(y, x)
        
        // Convert to degrees
        var degreesBearing = radiansBearing.toDegrees()
        
        // Normalize to 0-360
        while degreesBearing < 0 {
            degreesBearing += 360
        }
        
        return degreesBearing
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
}

extension Double {
    func toRadians() -> Double {
        return self * .pi / 180
    }
    
    func toDegrees() -> Double {
        return self * 180 / .pi
    }
} 