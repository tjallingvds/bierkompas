import SwiftUI

struct BeerDetailView: View {
    let beer: Beer
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(beer.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(beer.brewery)
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let rating = beer.rating {
                        VStack {
                            Text(String(format: "%.1f", rating))
                                .font(.title)
                                .fontWeight(.bold)
                            
                            HStack {
                                ForEach(0..<5) { index in
                                    Image(systemName: index < Int(rating) ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                
                // Beer image placeholder
                if let _ = beer.imageURL {
                    // In a real app, you would load the image from the URL
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(16/9, contentMode: .fit)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(16/9, contentMode: .fit)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                
                // Beer details
                Group {
                    DetailRow(label: "Style", value: beer.style)
                    DetailRow(label: "ABV", value: beer.formattedABV)
                }
                .padding(.vertical, 4)
                
                // Description
                if let description = beer.description {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        
                        Text(description)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 4)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Beer Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.headline)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.body)
            
            Spacer()
        }
    }
} 