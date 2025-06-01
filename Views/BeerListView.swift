import SwiftUI

struct BeerListView: View {
    @ObservedObject var viewModel: BeerViewModel
    
    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView("Loading beers...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            } else if viewModel.beers.isEmpty {
                Text("No beers found.")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.beers) { beer in
                    NavigationLink(destination: BeerDetailView(beer: beer)) {
                        BeerRowView(beer: beer)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Beers")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.fetchBeers()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            if viewModel.beers.isEmpty {
                viewModel.fetchBeers()
            }
        }
    }
}

struct BeerRowView: View {
    let beer: Beer
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(beer.name)
                    .font(.headline)
                Text(beer.brewery)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(beer.style)
                        .font(.caption)
                    Spacer()
                    Text(beer.formattedABV)
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            if let rating = beer.rating {
                Spacer()
                HStack {
                    Text(String(format: "%.1f", rating))
                        .fontWeight(.bold)
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
        }
    }
} 