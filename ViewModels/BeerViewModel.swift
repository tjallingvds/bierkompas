import Foundation
import Combine

class BeerViewModel: ObservableObject {
    @Published var beers: [Beer] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        // For now, load sample data
        loadSampleData()
    }
    
    func loadSampleData() {
        self.beers = Beer.sampleBeers
    }
    
    // In a real app, you would add methods to fetch data from an API
    func fetchBeers() {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isLoading = false
            self?.beers = Beer.sampleBeers
        }
    }
} 