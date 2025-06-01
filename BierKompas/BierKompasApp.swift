import SwiftUI
import CoreLocation

@main
struct BierKompasApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Request location permissions when app starts
                    _ = LocationManager()
                }
        }
    }
} 