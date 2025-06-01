import Foundation

struct Beer: Identifiable, Codable {
    var id = UUID()
    var name: String
    var brewery: String
    var style: String
    var abv: Double
    var rating: Double?
    var description: String?
    var imageURL: String?
    
    var formattedABV: String {
        return String(format: "%.1f%%", abv)
    }
}

extension Beer {
    static var sampleBeers: [Beer] = [
        Beer(name: "Sample Beer", brewery: "Sample Brewery", style: "IPA", abv: 5.5, rating: 4.2, description: "A delicious sample beer for testing purposes."),
        Beer(name: "Another Beer", brewery: "Cool Brewery", style: "Stout", abv: 7.2, rating: 4.7, description: "A rich, dark sample beer for testing.")
    ]
} 