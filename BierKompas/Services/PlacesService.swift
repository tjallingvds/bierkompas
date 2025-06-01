import Foundation
import CoreLocation

enum PlacesError: Error {
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
}

class PlacesService {
    // MARK: - Replace with your actual Google Places API key
    private let apiKey = "YOUR_GOOGLE_PLACES_API_KEY"
    
    func findNearbyTurkishPizzaStores(location: CLLocation) async throws -> [PizzaStore] {
        // In a real app, you would query the Google Places API here
        // For this demo, we'll return mock data
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Mock store locations around the user's location
        let userLat = location.coordinate.latitude
        let userLng = location.coordinate.longitude
        
        // Create some randomized locations around the user
        let stores = [
            createMockStore(
                id: "store1",
                name: "Istanbul Pizza",
                address: "123 Main Street",
                lat: userLat + 0.002,
                lng: userLng + 0.003,
                rating: 4.5,
                isOpen: true,
                userLocation: location
            ),
            createMockStore(
                id: "store2",
                name: "Turkish Delight",
                address: "456 Elm Avenue",
                lat: userLat - 0.001,
                lng: userLng + 0.002,
                rating: 4.2,
                isOpen: true,
                userLocation: location
            ),
            createMockStore(
                id: "store3",
                name: "Ankara Pide House",
                address: "789 Oak Boulevard",
                lat: userLat + 0.001,
                lng: userLng - 0.001,
                rating: 4.7,
                isOpen: false,
                userLocation: location
            ),
            createMockStore(
                id: "store4",
                name: "Anatolia Pizza",
                address: "321 Pine Road",
                lat: userLat - 0.002,
                lng: userLng - 0.003,
                rating: 3.9,
                isOpen: true,
                userLocation: location
            )
        ]
        
        // Sort by distance
        return stores.sorted { $0.distance ?? Double.infinity < $1.distance ?? Double.infinity }
    }
    
    private func createMockStore(id: String, name: String, address: String, lat: Double, lng: Double, rating: Double, isOpen: Bool, userLocation: CLLocation) -> PizzaStore {
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let storeLocation = CLLocation(latitude: lat, longitude: lng)
        let distance = userLocation.distance(from: storeLocation)
        
        return PizzaStore(
            id: id,
            name: name,
            address: address,
            coordinate: coordinate,
            rating: rating,
            isOpen: isOpen,
            distance: distance,
            bearing: nil // This will be calculated by the CompassViewModel
        )
    }
    
    // MARK: - Actual Google Places API Implementation (Commented out for demo)
    /*
    func findNearbyTurkishPizzaStores(location: CLLocation) async throws -> [PizzaStore] {
        // Build URL for the Google Places API
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json")!
        components.queryItems = [
            URLQueryItem(name: "location", value: "\(location.coordinate.latitude),\(location.coordinate.longitude)"),
            URLQueryItem(name: "radius", value: "1500"), // 1.5km radius
            URLQueryItem(name: "type", value: "restaurant"),
            URLQueryItem(name: "keyword", value: "turkish pizza"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = components.url else {
            throw PlacesError.invalidResponse
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw PlacesError.invalidResponse
            }
            
            // Parse the response data
            let decoder = JSONDecoder()
            let placesResponse = try decoder.decode(PlacesResponse.self, from: data)
            
            // Convert the response to PizzaStore objects
            return try placesResponse.results.map { result in
                guard let lat = result.geometry.location.lat,
                      let lng = result.geometry.location.lng else {
                    throw PlacesError.invalidResponse
                }
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                let storeLocation = CLLocation(latitude: lat, longitude: lng)
                let distance = location.distance(from: storeLocation)
                
                return PizzaStore(
                    id: result.place_id,
                    name: result.name,
                    address: result.vicinity,
                    coordinate: coordinate,
                    rating: result.rating,
                    isOpen: result.opening_hours?.open_now ?? false,
                    distance: distance,
                    bearing: nil // This will be calculated by the CompassViewModel
                )
            }
            .sorted { $0.distance ?? Double.infinity < $1.distance ?? Double.infinity }
            
        } catch {
            if let urlError = error as? URLError {
                throw PlacesError.networkError(urlError)
            } else {
                throw PlacesError.decodingError(error)
            }
        }
    }
    
    // Google Places API response models
    struct PlacesResponse: Decodable {
        let results: [PlaceResult]
    }
    
    struct PlaceResult: Decodable {
        let place_id: String
        let name: String
        let vicinity: String
        let geometry: Geometry
        let rating: Double?
        let opening_hours: OpeningHours?
    }
    
    struct Geometry: Decodable {
        let location: Location
    }
    
    struct Location: Decodable {
        let lat: Double?
        let lng: Double?
    }
    
    struct OpeningHours: Decodable {
        let open_now: Bool?
    }
    */
} 