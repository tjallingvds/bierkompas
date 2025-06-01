# Turkish Pizza Compass

An iOS app that helps you find the closest Turkish pizza store and always points you in the right direction.

## Project Structure

This project follows the MVVM (Model-View-ViewModel) architecture pattern:

```
Project/
├── BierKompasApp.swift     # App entry point
├── ContentView.swift       # Main container view
├── Models/
│   └── PizzaStore.swift    # Turkish pizza store data model
├── ViewModels/
│   └── CompassViewModel.swift # View model for compass functionality
├── Views/
│   └── CompassView.swift   # Compass view pointing to nearest store
├── Services/
│   ├── LocationManager.swift # Handles location and heading updates
│   └── PlacesService.swift   # API service for finding pizza stores
├── Assets.xcassets         # App images and colors
├── Info.plist              # App configuration
└── Preview Content/        # SwiftUI preview assets
```

## Features

- Finds the closest open Turkish pizza store near your location
- Shows a compass that always points toward the store
- Displays store information including name, address, and rating
- Minimizes battery usage by checking location only when needed:
  - When app is first opened
  - When app is reopened
  - When user moves more than 200m from last known location

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.0+
- Device with Location Services and Compass (magnetometer)

## Privacy

The app requires:
- Location permissions (when in use)
- Internet connection to fetch nearby stores using the Google Places API

## Setup Instructions

1. Clone the repository
2. Open the project in Xcode
3. Build and run on a physical device for best compass experience

## Implementation Details

- Uses CoreLocation for user positioning and heading
- Uses Google Places API to find nearby Turkish pizza stores
- Calculates bearing between user and target store
- Updates compass direction in real-time as user changes direction
- Implements efficient location checking to preserve battery life 