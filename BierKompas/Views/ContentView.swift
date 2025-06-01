import SwiftUI

struct ContentView: View {
    @StateObject private var compassViewModel = CompassViewModel()
    
    var body: some View {
        NavigationView {
            CompassView(viewModel: compassViewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 