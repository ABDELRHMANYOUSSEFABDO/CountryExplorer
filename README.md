# Country Explorer iOS App

A modern iOS application built with SwiftUI that allows users to explore countries, view their details, and maintain a favorites list.

## Features

### Core Features
- 🌍 **Country Search**: Search for any country by name or capital city
- 📍 **GPS Location**: Automatically adds your current country based on GPS location
- ⭐ **Favorites Management**: Add up to 5 countries to your favorites list
- 🗑️ **Remove Countries**: Easily remove countries from favorites
- 💾 **Offline Support**: Data is cached locally for offline usage
- 🎨 **Beautiful UI**: Modern, user-friendly interface with smooth animations

### Technical Features
- Built with **SwiftUI** (iOS 15+)
- **MVVM Architecture** with Combine framework
- RESTful API integration with **REST Countries API**
- Local storage using **UserDefaults**
- **CoreLocation** for GPS functionality
- Comprehensive **Unit Tests**
- Protocol-oriented design for testability

## Screenshots

### Main View
- Displays up to 5 favorite countries
- Beautiful gradient background
- Country cards with flags, names, and capitals
- Add button to search for new countries

### Search View
- Search bar with real-time filtering
- List of all countries with flags
- Add/Remove functionality
- Shows remaining slots indicator

### Detail View
- Large flag display
- Capital city information
- Currency details (name, code, symbol)
- Smooth animations and transitions

## Architecture

### Project Structure
```
CountryExplorer/
├── Models/
│   └── Country.swift           # Data models
├── Views/
│   ├── CountryListView.swift   # Main favorites screen
│   ├── CountrySearchView.swift # Search and add countries
│   └── CountryDetailView.swift # Country details
├── ViewModels/
│   └── CountryListViewModel.swift # Business logic
├── Services/
│   ├── NetworkService.swift    # API integration
│   ├── StorageService.swift    # Local storage
│   └── LocationService.swift   # GPS functionality
└── CountryExplorerApp.swift    # App entry point
```

### Design Patterns
- **MVVM**: Clear separation of concerns
- **Protocol-Oriented**: Services use protocols for testability
- **Dependency Injection**: ViewModels receive dependencies
- **Combine**: Reactive programming for async operations

## API Integration

Uses the [REST Countries API](https://restcountries.com/v2/all) to fetch country data:
- Country name
- Capital city
- Currency information
- Flag images
- Geographic coordinates

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository:
```bash
git clone [repository-url]
cd CountryExplorerApp
```

2. Open the project in Xcode:
```bash
open CountryExplorer.xcodeproj
```

3. Build and run the project (⌘ + R)

## Testing

The project includes comprehensive unit tests covering:
- ✅ Network service operations
- ✅ Storage service functionality
- ✅ ViewModel business logic
- ✅ Country model validation
- ✅ Add/Remove operations
- ✅ Maximum favorites limit
- ✅ Search functionality

Run tests in Xcode: `⌘ + U`

### Test Coverage
- `NetworkServiceTests.swift`: API integration tests
- `StorageServiceTests.swift`: Local storage tests
- `CountryListViewModelTests.swift`: ViewModel logic tests
- `CountryModelTests.swift`: Model validation tests

## Key Functionalities

### 1. Auto-add Country Based on Location
- Requests location permission on first launch
- Automatically adds user's country to favorites
- Falls back to Egypt (default) if location denied

### 2. Search and Add Countries
- Real-time search by country name or capital
- Visual feedback for already-added countries
- Maximum 5 countries limit enforcement
- Smooth animations when adding/removing

### 3. Country Details
- Tap any country to view detailed information
- Display capital city
- Show currency name, code, and symbol
- Beautiful flag visualization

### 4. Offline Support
- All fetched countries are cached locally
- Favorites persist between app launches
- Works without internet after first load

### 5. Error Handling
- Network error handling with user feedback
- Graceful fallbacks for missing data
- Clear error messages

## Code Quality

### Best Practices
- ✅ No Storyboards or XIB files (pure code)
- ✅ Protocol-oriented design
- ✅ Comprehensive documentation
- ✅ Clean code with clear naming
- ✅ Separation of concerns
- ✅ Testable architecture
- ✅ Mock services for testing

### SwiftUI Features Used
- `@StateObject` and `@ObservedObject`
- `AsyncImage` for network images
- Custom view modifiers
- Gradient backgrounds
- Smooth animations with `.spring()`
- Sheet presentations
- NavigationView

## Location Permissions

The app requests "When In Use" location permission to detect the user's country automatically. This is optional - if denied, the app will use Egypt as the default country.

Permission message: "We need your location to automatically add your country to the favorites list"

## Offline Mode

- **First Launch**: Requires internet to fetch country data
- **Subsequent Uses**: Works offline with cached data
- **Favorites**: Persisted locally, always available offline

## Future Enhancements

Possible improvements:
- CoreData integration for advanced storage
- Search history
- Country comparison feature
- Population and area information
- Maps integration
- Share functionality
- Dark mode support
- Localization

## Author

Created as part of an iOS coding assessment challenge.

## License

This project is available for educational and assessment purposes.
