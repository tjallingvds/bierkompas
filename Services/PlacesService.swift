import Foundation
import CoreLocation

class PlacesService {
    private let apiKey = "AIzaSyAce7QS6xl1C0bBlZ_tOpLLx_aS6-1Vpcg"
    private let session = URLSession.shared
    
    func findNearbyTurkishPizzaStores(location: CLLocation) async throws -> [PizzaStore] {
        let baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "location", value: "\(location.coordinate.latitude),\(location.coordinate.longitude)"),
            URLQueryItem(name: "radius", value: "5000"), // 5km radius
            URLQueryItem(name: "type", value: "restaurant"),
            URLQueryItem(name: "keyword", value: "turkish pizza"),
            URLQueryItem(name: "opennow", value: "true"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        let url = components.url!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "PlacesService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        let decoder = JSONDecoder()
        let placesResponse = try decoder.decode(PlacesResponse.self, from: data)
        
        let stores = placesResponse.results.map { result -> PizzaStore in
            let coordinate = CLLocationCoordinate2D(
                latitude: result.geometry.location.lat,
                longitude: result.geometry.location.lng
            )
            
            // Calculate distance
            let storeLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let distance = location.distance(from: storeLocation)
            
            return PizzaStore(
                id: result.placeId,
                name: result.name,
                address: result.vicinity,
                isOpen: result.openingHours?.openNow ?? false,
                rating: result.rating,
                coordinate: coordinate,
                distance: distance
            )
        }
        
        // Sort by distance
        return stores.sorted { $0.distance ?? Double.infinity < $1.distance ?? Double.infinity }
    }
}

// MARK: - API Response Models
struct PlacesResponse: Codable {
    let results: [PlaceResult]
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case results, status
    }
}

struct PlaceResult: Codable {
    let geometry: Geometry
    let name: String
    let placeId: String
    let vicinity: String
    let rating: Double?
    let openingHours: OpeningHours?
    
    enum CodingKeys: String, CodingKey {
        case geometry, name, vicinity, rating
        case placeId = "place_id"
        case openingHours = "opening_hours"
    }
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

struct OpeningHours: Codable {
    let openNow: Bool
    
    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
    }
} 