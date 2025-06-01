import SwiftUI
import CoreLocation

struct CompassView: View {
    @ObservedObject var viewModel: CompassViewModel
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            if viewModel.isLoading {
                VStack {
                    ProgressView("Finding Turkish pizza...")
                        .padding()
                }
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                        .padding()
                    
                    Text(errorMessage)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button(action: viewModel.refresh) {
                        Label("Try Again", systemImage: "arrow.clockwise")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }
                .padding()
            } else {
                VStack(spacing: 20) {
                    // Store info
                    if let store = viewModel.closestStore {
                        StoreInfoView(store: store)
                            .padding()
                    }
                    
                    // Compass
                    CompassRoseView(userHeading: viewModel.userHeading, relativeHeading: viewModel.relativeHeading)
                        .frame(width: 250, height: 250)
                        .padding()
                    
                    // Distance info
                    if let store = viewModel.closestStore, let distance = store.distance {
                        VStack {
                            Text("Distance: \(store.formattedDistance)")
                                .font(.title2)
                                .fontWeight(.medium)
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // Refresh button
                    Button(action: viewModel.refresh) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.bottom)
                }
            }
        }
        .navigationTitle("Turkish Pizza Compass")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StoreInfoView: View {
    let store: PizzaStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(store.name)
                .font(.title)
                .fontWeight(.bold)
            
            Text(store.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                if let rating = store.rating {
                    HStack(spacing: 4) {
                        Text(String(format: "%.1f", rating))
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                }
                
                Spacer()
                
                if store.isOpen {
                    Text("Open Now")
                        .foregroundColor(.green)
                } else {
                    Text("Closed")
                        .foregroundColor(.red)
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CompassRoseView: View {
    let userHeading: Double
    let relativeHeading: Double
    
    var body: some View {
        ZStack {
            // Compass rose
            Circle()
                .stroke(Color(.systemGray4), lineWidth: 3)
                .background(Circle().fill(Color(.systemGray6)))
            
            // North indicator
            GeometryReader { geometry in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(center.x, center.y) - 15
                
                // Cardinal directions
                ForEach(0..<4) { i in
                    let angle = Double(i) * 90.0
                    let rotation = Angle(degrees: angle - userHeading)
                    let position = CGPoint(
                        x: center.x + CGFloat(cos(rotation.radians)) * (radius - 25),
                        y: center.y + CGFloat(sin(rotation.radians)) * (radius - 25)
                    )
                    
                    let label: String
                    switch i {
                    case 0: label = "N"
                    case 1: label = "E"
                    case 2: label = "S"
                    case 3: label = "W"
                    default: label = ""
                    }
                    
                    Text(label)
                        .font(.system(size: 18, weight: .bold))
                        .position(position)
                }
                
                // Heading marker (direction user is facing)
                Path { path in
                    path.move(to: CGPoint(x: center.x, y: center.y - radius))
                    path.addLine(to: CGPoint(x: center.x - 10, y: center.y - radius + 20))
                    path.addLine(to: CGPoint(x: center.x + 10, y: center.y - radius + 20))
                    path.closeSubpath()
                }
                .fill(Color.blue)
                
                // Store direction arrow
                Path { path in
                    let arrowRotation = Angle(degrees: relativeHeading)
                    let arrowLength = radius - 10
                    
                    // Starting point (center)
                    path.move(to: center)
                    
                    // Draw line to edge
                    let endPoint = CGPoint(
                        x: center.x + CGFloat(cos(arrowRotation.radians)) * arrowLength,
                        y: center.y + CGFloat(sin(arrowRotation.radians)) * arrowLength
                    )
                    path.addLine(to: endPoint)
                    
                    // Arrow head
                    let headLength: CGFloat = 20
                    let arrowAngle1 = arrowRotation + Angle(degrees: 150)
                    let arrowAngle2 = arrowRotation + Angle(degrees: 210)
                    
                    let arrowPoint1 = CGPoint(
                        x: endPoint.x + CGFloat(cos(arrowAngle1.radians)) * headLength,
                        y: endPoint.y + CGFloat(sin(arrowAngle1.radians)) * headLength
                    )
                    
                    let arrowPoint2 = CGPoint(
                        x: endPoint.x + CGFloat(cos(arrowAngle2.radians)) * headLength,
                        y: endPoint.y + CGFloat(sin(arrowAngle2.radians)) * headLength
                    )
                    
                    path.move(to: endPoint)
                    path.addLine(to: arrowPoint1)
                    path.move(to: endPoint)
                    path.addLine(to: arrowPoint2)
                }
                .stroke(Color.red, lineWidth: 3)
            }
            
            // Center dot
            Circle()
                .fill(Color.blue)
                .frame(width: 10, height: 10)
            
            // "Pizza" emoji in center
            Text("🍕")
                .font(.system(size: 24))
        }
    }
} 