import Foundation
import CoreLocation
import Combine

@MainActor
class CompassViewModel: ObservableObject {
    private let locationManager = LocationManager()
    private let placesService = PlacesService()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var closestStore: PizzaStore?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userHeading: Double = 0
    @Published var targetBearing: Double?
    @Published var relativeHeading: Double = 0
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Listen for user location updates
        locationManager.$userLocation
            .compactMap { $0 }
            .filter { [weak self] _ in
                self?.locationManager.shouldCheckLocation() ?? true
            }
            .sink { [weak self] location in
                self?.checkForStores(at: location)
            }
            .store(in: &cancellables)
        
        // Listen for heading updates
        locationManager.$heading
            .compactMap { $0 }
            .sink { [weak self] heading in
                self?.userHeading = heading.trueHeading
                self?.updateRelativeHeading()
            }
            .store(in: &cancellables)
        
        // Listen for location status
        locationManager.$locationStatus
            .compactMap { $0 }
            .sink { [weak self] status in
                if status == .denied || status == .restricted {
                    self?.errorMessage = "Location access denied. Please enable location services in Settings."
                }
            }
            .store(in: &cancellables)
    }
    
    func updateRelativeHeading() {
        guard let targetBearing = targetBearing else { return }
        
        // Calculate relative heading (direction to point)
        var relativeAngle = targetBearing - userHeading
        
        // Normalize to -180...180
        while relativeAngle < -180 {
            relativeAngle += 360
        }
        while relativeAngle > 180 {
            relativeAngle -= 360
        }
        
        self.relativeHeading = relativeAngle
    }
    
    func refresh() {
        guard let location = locationManager.userLocation else {
            errorMessage = "Cannot determine your location"
            return
        }
        
        checkForStores(at: location)
    }
    
    private func checkForStores(at location: CLLocation) {
        Task {
            do {
                isLoading = true
                errorMessage = nil
                
                let stores = try await placesService.findNearbyTurkishPizzaStores(location: location)
                
                if let closest = stores.first {
                    // Calculate bearing to the store
                    if let bearing = locationManager.calculateBearing(to: closest.coordinate) {
                        var store = closest
                        store.bearing = bearing
                        closestStore = store
                        targetBearing = bearing
                        updateRelativeHeading()
                    } else {
                        closestStore = closest
                    }
                    
                    // Mark that we've checked at this location
                    locationManager.updateLastCheckedLocation()
                } else {
                    errorMessage = "No Turkish pizza stores found nearby"
                }
                
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = "Error finding stores: \(error.localizedDescription)"
            }
        }
    }
} 