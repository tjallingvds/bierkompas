import SwiftUI

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