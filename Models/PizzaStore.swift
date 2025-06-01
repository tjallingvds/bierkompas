import Foundation
import CoreLocation

struct PizzaStore: Identifiable, Codable {
    var id: String
    var name: String
    var address: String
    var isOpen: Bool
    var rating: Double?
    var coordinate: CLLocationCoordinate2D
    var distance: Double?
    var bearing: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, name, address, isOpen, rating
        case lat, lng
    }
    
    init(id: String, name: String, address: String, isOpen: Bool, rating: Double?, coordinate: CLLocationCoordinate2D, distance: Double? = nil, bearing: Double? = nil) {
        self.id = id
        self.name = name
        self.address = address
        self.isOpen = isOpen
        self.rating = rating
        self.coordinate = coordinate
        self.distance = distance
        self.bearing = bearing
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decode(String.self, forKey: .address)
        isOpen = try container.decode(Bool.self, forKey: .isOpen)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        
        let lat = try container.decode(Double.self, forKey: .lat)
        let lng = try container.decode(Double.self, forKey: .lng)
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(isOpen, forKey: .isOpen)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encode(coordinate.latitude, forKey: .lat)
        try container.encode(coordinate.longitude, forKey: .lng)
    }
    
    var formattedDistance: String {
        guard let distance = distance else { return "Unknown" }
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
    
    static var sampleStore: PizzaStore {
        PizzaStore(
            id: "sample1",
            name: "Best Turkish Pizza",
            address: "123 Main St, Amsterdam",
            isOpen: true,
            rating: 4.5,
            coordinate: CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041),
            distance: 750,
            bearing: 45.0
        )
    }
} 