import Foundation
import CoreLocation

struct PizzaStore: Identifiable {
    let id: String
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let rating: Double?
    let isOpen: Bool
    let distance: Double?
    var bearing: Double?
    
    var formattedDistance: String {
        guard let distance = distance else { return "Unknown distance" }
        
        // Format distance in either meters or kilometers
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            let kilometers = distance / 1000
            return String(format: "%.1f km", kilometers)
        }
    }
}

extension PizzaStore {
    // Sample data for preview
    static var sample: PizzaStore {
        PizzaStore(
            id: "sample123",
            name: "Turkish Delight Pizza",
            address: "123 Main Street, Anywhere",
            coordinate: CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041),
            rating: 4.5,
            isOpen: true,
            distance: 450,
            bearing: 45
        )
    }
} 