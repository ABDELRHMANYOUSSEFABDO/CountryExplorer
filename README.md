# CountryExplorer - System Design Document

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Tech Stack](#tech-stack)
4. [Project Structure](#project-structure)
5. [Core Components](#core-components)
6. [Data Flow](#data-flow)
7. [Key Features](#key-features)
8. [Design Patterns](#design-patterns)
9. [Testing Strategy](#testing-strategy)
10. [Configuration & Environment](#configuration--environment)
11. [API Integration](#api-integration)
12. [Caching Strategy](#caching-strategy)
13. [Error Handling](#error-handling)
14. [Future Enhancements](#future-enhancements)

---

## Overview

**CountryExplorer** is a native iOS application built with SwiftUI that enables users to explore countries worldwide, view detailed information about each country, search and filter countries, and maintain a list of selected favorite countries. The app follows Clean Architecture principles with a strong emphasis on separation of concerns, testability, and maintainability.

### Primary Objectives
- Provide comprehensive country information from the REST Countries API
- Support offline-first functionality with CoreData persistence
- Deliver a smooth and intuitive user experience
- Implement location-based auto-selection on first launch
- Enable fast search and filtering capabilities

---

## Architecture

The application follows **Clean Architecture** principles, organized into distinct layers with clear boundaries and dependencies:

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  (SwiftUI Views, ViewModels, Navigation, UI Components)     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       Domain Layer                           │
│     (Entities, Use Cases, Repository Protocols, Services)   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        Data Layer                            │
│  (Repositories, Network, DTOs, Mappers, Local Data Sources) │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        Core Layer                            │
│   (Network Client, Storage, Cache, DI, Logging, Config)     │
└─────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

#### 1. **Presentation Layer**
- **Views**: SwiftUI views that define the UI
- **ViewModels**: MVVM pattern, managing view state and business logic orchestration
- **Navigation**: Coordinator pattern for managing app flow
- **Components**: Reusable UI components and design system
- **Dependencies**: Domain Layer (Use Cases)

#### 2. **Domain Layer**
- **Entities**: Core business models (Country, Currency, Language)
- **Use Cases**: Application-specific business rules
- **Repository Protocols**: Abstractions for data access
- **Services**: Domain services (search, cache invalidation, first launch)
- **Dependencies**: None (pure Swift, no external dependencies)

#### 3. **Data Layer**
- **Repositories**: Concrete implementations of repository protocols
- **DTOs**: Data Transfer Objects for API responses
- **Mappers**: Transform DTOs to Domain entities
- **Data Sources**: Network and local data source implementations
- **Dependencies**: Core Layer

#### 4. **Core Layer**
- **Network**: HTTP client, error handling, data mapping
- **Storage**: CoreData stack and entity management
- **Cache**: Memory and disk caching system
- **Configuration**: Environment and API configuration
- **Logging**: Centralized logging system
- **Dependency Injection**: DI container for managing dependencies
- **Dependencies**: Foundation, CoreData, CoreLocation

---

## Tech Stack

### Frameworks & Libraries
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for async operations
- **CoreData**: Local persistence and offline support
- **CoreLocation**: Location services for auto-country detection
- **URLSession**: Native HTTP client
- **XCTest**: Unit and UI testing

### API
- **REST Countries API**: [https://restcountries.com](https://restcountries.com)
- **Flagcdn**: [https://flagcdn.com](https://flagcdn.com) for flag images

### Development Tools
- **Xcode**: IDE
- **Swift Package Manager**: Dependency management (future)
- **Git**: Version control

---

## Project Structure

```
CountryExplorer/
├── Core/
│   ├── Cache/
│   │   └── CacheManager.swift              # Memory & disk caching
│   ├── Configuration/
│   │   ├── APIConfiguration.swift          # API settings
│   │   ├── AppEnvironment.swift            # Environment configuration
│   │   └── BuildConfiguration.swift        # Build-specific config
│   ├── DependencyInjection/
│   │   └── DIContainer.swift               # DI container
│   ├── ErrorHandling/
│   │   ├── ApplicationError.swift          # App-level errors
│   │   ├── ErrorHandler.swift              # Error handling logic
│   │   └── ErrorRecovery.swift             # Recovery strategies
│   ├── Location/
│   │   └── LocationService.swift           # Location management
│   ├── Logging/
│   │   └── Logger.swift                    # Centralized logging
│   ├── Network/
│   │   ├── Client/
│   │   │   ├── NetworkClientProtocol.swift
│   │   │   └── URLSessionNetworkClient.swift
│   │   ├── Error/
│   │   │   └── NetworkError.swift
│   │   └── Mapping/
│   │       ├── DataMapperProtocol.swift
│   │       └── JSONDataMapper.swift
│   └── Storage/
│       └── CoreData/
│           ├── CoreDataStack.swift         # CoreData setup
│           ├── CountryExplorer.xcdatamodeld
│           └── Entities/                   # CoreData entities
│
├── Domain/
│   ├── Entities/
│   │   └── Country.swift                   # Domain models
│   ├── Repositories/
│   │   └── CountryRepositoryProtocol.swift # Repository interface
│   ├── Services/
│   │   ├── CacheInvalidationService.swift
│   │   ├── CountrySearchService.swift
│   │   └── FirstLaunchManager.swift
│   └── UseCases/
│       ├── FetchAllCountriesUseCase.swift
│       ├── GetCountryByLocationUseCase.swift
│       ├── ManageSelectedCountriesUseCase.swift
│       └── SearchCountriesUseCase.swift
│
├── Data/
│   ├── DataSources/
│   │   └── Local/
│   │       └── CountryLocalDataSource.swift
│   ├── DTOs/
│   │   ├── CountryDTO.swift
│   │   ├── CurrencyDTO.swift
│   │   └── LanguageDTO.swift
│   ├── Mapping/
│   │   └── CountryResponseMapper.swift
│   ├── Network/
│   │   ├── Endpoints/
│   │   │   └── CountryEndpoint.swift
│   │   └── Manager/
│   │       └── NetworkManager.swift
│   └── Repositories/
│       ├── Factory/
│       │   └── RepositoryFactory.swift
│       └── Implementations/
│           └── CountryRepository.swift
│
└── Presentation/
    ├── App/
    │   ├── CountryExplorerApp.swift        # App entry point
    │   ├── ContentView.swift               # Root view
    │   └── UseCaseFactory.swift
    ├── Common/
    │   ├── Components/                     # Reusable UI components
    │   ├── DesignSystem/
    │   │   └── AppTheme.swift
    │   ├── Extensions/
    │   │   └── ViewExtensions.swift
    │   ├── SplashScreen/
    │   └── ViewState.swift                 # Generic view state
    ├── Navigation/
    │   └── CountryFlowCoordinator.swift    # Navigation coordinator
    └── Scenes/
        ├── CountryDetails/
        │   ├── CountryDetailsView.swift
        │   ├── CountryDetailsViewModel.swift
        │   └── Components/
        ├── CountryList/
        │   ├── CountryListView.swift
        │   ├── CountryListViewModel.swift
        │   └── Components/
        └── SelectedCountries/
            ├── SelectedCountriesView.swift
            └── SelectedCountriesViewModel.swift
```

---

## Core Components

### 1. Dependency Injection Container

The `DIContainer` manages all dependencies and provides factory methods for creating objects:

```swift
// Core Services
- makeLocationService() -> LocationServiceProtocol
- makeCoreDataStack() -> CoreDataStack

// Data Layer
- makeNetworkManager() -> NetworkManagerProtocol
- makeLocalDataSource() -> CountryLocalDataSource
- makeCountryRepository() -> CountryRepositoryProtocol

// Use Cases
- makeFetchAllCountriesUseCase() -> FetchAllCountriesUseCaseProtocol
- makeSearchCountriesUseCase() -> SearchCountriesUseCaseProtocol
- makeManageSelectedCountriesUseCase() -> ManageSelectedCountriesUseCaseProtocol
- makeGetCountryByLocationUseCase() -> GetCountryByLocationUseCaseProtocol

// Services
- makeFirstLaunchManager() -> FirstLaunchManagerProtocol
```

**Benefits:**
- Single source of truth for dependencies
- Easy mocking for tests
- Loose coupling between layers
- Simplified testing with `MockDIContainer`

### 2. Repository Pattern

The `CountryRepository` implements the Repository pattern to abstract data sources:

**Features:**
- Unified interface for data access
- Automatic fallback from cache → local → network
- Data synchronization between sources
- Offline-first approach

**Data Source Priority:**
```
Cache (Memory/Disk) → CoreData (Local) → Network API
```

### 3. Use Cases

Each use case encapsulates a single business operation:

1. **FetchAllCountriesUseCase**: Fetches all countries with caching
2. **SearchCountriesUseCase**: Searches countries by name, code, or capital
3. **ManageSelectedCountriesUseCase**: Add/remove/fetch selected countries
4. **GetCountryByLocationUseCase**: Gets user's country by GPS coordinates

**Benefits:**
- Single Responsibility Principle
- Testable business logic
- Reusable across different screens
- Clear separation of concerns

### 4. Network Layer

**Components:**
- **NetworkClientProtocol**: Abstract HTTP client
- **URLSessionNetworkClient**: URLSession implementation
- **NetworkManager**: High-level network operations
- **DataMapper**: JSON to DTO transformation
- **ResponseMapper**: DTO to Domain entity transformation

**Features:**
- Protocol-based design for testability
- Automatic retry logic
- Error mapping and handling
- Request/response logging
- Configurable timeouts

### 5. Cache System

**Two-tier caching strategy:**

#### Memory Cache
- NSCache-based
- Fast access
- Limited capacity (50 MB)
- Auto-eviction on memory warnings

#### Disk Cache
- File-based persistence
- Larger capacity (200 MB)
- Survives app restarts
- Automatic expiration cleanup

**Cache Expiration Policies:**
- `.never`: No expiration
- `.seconds(TimeInterval)`: Seconds-based
- `.minutes(Int)`: Minutes-based
- `.hours(Int)`: Hours-based
- `.days(Int)`: Days-based
- `.date(Date)`: Specific expiration date

### 6. CoreData Stack

**Features:**
- Singleton pattern
- Background context for write operations
- Main context for UI operations
- Automatic merge from background saves
- Entity-based persistence

**Entities:**
- CountryEntity
- CurrencyEntity
- LanguageEntity
- Selected country associations

### 7. Error Handling

**Structured error hierarchy:**

```swift
ApplicationError
├── NetworkError
│   ├── noInternetConnection
│   ├── timeout
│   ├── invalidResponse
│   └── serverError
├── DataError
│   ├── notFound
│   ├── invalidData
│   └── mappingFailed
├── StorageError
│   ├── saveFailed
│   ├── fetchFailed
│   └── deleteFailed
└── LocationError
    ├── permissionDenied
    └── locationUnavailable
```

**Error Recovery Strategies:**
- Automatic retry with exponential backoff
- Fallback to cached data
- User-friendly error messages
- Logging for debugging

---

## Data Flow

### Fetching Countries

```
┌─────────────┐
│   View      │
└──────┬──────┘
       │ User Action
       ▼
┌─────────────┐
│  ViewModel  │
└──────┬──────┘
       │ Call Use Case
       ▼
┌─────────────────────┐
│  FetchCountriesUC   │
└──────┬──────────────┘
       │ Request Data
       ▼
┌──────────────────┐
│   Repository     │
└──────┬───────────┘
       │
       ├─── Check Cache ────────┐
       │                         │
       ├─── Query CoreData ──────┤
       │                         │
       └─── Fetch from API ──────┤
                                 │
                                 ▼
                         ┌───────────────┐
                         │  Data Sources │
                         └───────┬───────┘
                                 │
                                 ▼
                         ┌───────────────┐
                         │   Mappers     │
                         └───────┬───────┘
                                 │
                                 ▼
                         ┌───────────────┐
                         │    Domain     │
                         │   Entities    │
                         └───────┬───────┘
                                 │
                                 ▼
                         ┌───────────────┐
                         │  ViewModel    │
                         └───────┬───────┘
                                 │
                                 ▼
                         ┌───────────────┐
                         │     View      │
                         └───────────────┘
```

### First Launch Flow

```
App Launch
    │
    ▼
Check First Launch
    │
    ├─── Not First Launch ──→ Show Country List
    │
    └─── First Launch
            │
            ▼
    Request Location Permission
            │
            ├─── Denied ──→ Use Default (Egypt)
            │
            └─── Granted
                    │
                    ▼
            Get Coordinates
                    │
                    ▼
            Fetch Country by Location
                    │
                    ▼
            Auto-Select User's Country
                    │
                    ▼
            Save to Selected Countries
                    │
                    ▼
            Show Country List (with selected)
```

---

## Key Features

### 1. Country List
- Display all countries in a scrollable list
- Show country flag, name, capital, and currency
- Pull-to-refresh for data updates
- Loading states and error handling
- Empty state management

### 2. Country Search & Filter
- Real-time search as user types
- Search by: name, capital, code, region
- Debounced search for performance
- Clear search functionality
- Search result count

### 3. Country Details
- Comprehensive country information
- Flag display with caching
- Population, currencies, languages
- Timezones and bordering countries
- Add/remove from selected countries
- Share functionality

### 4. Selected Countries
- Persistent favorites list
- Quick access to selected countries
- Remove from selection
- View details
- Badge count on tab bar

### 5. Location-Based Auto-Selection
- GPS-based country detection
- Automatic selection on first launch
- Permission handling
- Fallback to default country
- Privacy-conscious implementation

### 6. Offline Support
- CoreData persistence
- Works without internet
- Automatic sync when online
- Cached data access
- Stale data indicators

### 7. Performance Optimization
- Image caching
- Data caching (memory + disk)
- Lazy loading
- Background data processing
- Efficient search algorithms

---

## Design Patterns

### 1. **Clean Architecture**
- Clear separation of layers
- Dependency inversion
- Framework independence
- Testable business logic

### 2. **MVVM (Model-View-ViewModel)**
- Declarative UI with SwiftUI
- Reactive updates with Combine
- View logic separation
- Testable view models

### 3. **Repository Pattern**
- Abstract data sources
- Single source of truth
- Data access centralization
- Flexible data source swapping

### 4. **Dependency Injection**
- Constructor injection
- Protocol-based dependencies
- Testability
- Loose coupling

### 5. **Coordinator Pattern**
- Navigation management
- Deep linking support
- Flow coordination
- View decoupling

### 6. **Factory Pattern**
- Object creation abstraction
- Repository factory
- Use case factory
- Centralized creation logic

### 7. **Strategy Pattern**
- Error recovery strategies
- Cache expiration policies
- Data source selection
- Flexible algorithms

### 8. **Observer Pattern**
- Combine publishers
- State observation
- Event-driven updates
- Reactive programming

---

## Testing Strategy

### Unit Tests
**Coverage**: Core, Data, Domain layers

**Test Categories:**
1. **Use Case Tests**: Business logic validation
2. **Repository Tests**: Data access and caching
3. **Network Tests**: API integration and mapping
4. **Service Tests**: Domain services functionality
5. **Mapper Tests**: DTO to Entity transformation
6. **Error Handling Tests**: Error scenarios and recovery

**Mocking Strategy:**
- Protocol-based mocks for all dependencies
- Mock DI container for isolated testing
- Test doubles for external dependencies

**Example Test Files:**
```
- CountryUseCasesTests.swift
- CountryRepositoryTests.swift
- NetworkManagerTests.swift
- ResponseMapperTests.swift
- CountrySearchServiceTests.swift
- CacheInvalidationServiceTests.swift
- ErrorHandlerTests.swift
```

### ViewModel Tests
**Coverage**: Presentation layer

**Test Focus:**
- State transitions
- User interaction handling
- Use case orchestration
- Error state management

**Example Test Files:**
```
- CountryListViewModelTests.swift
- CountryDetailsViewModelTests.swift
- SelectedCountriesViewModelTests.swift
```

### UI Tests
**Coverage**: End-to-end flows

**Test Scenarios:**
- Navigation flows
- Search functionality
- Country selection/deselection
- First launch experience
- Offline behavior

### Test Doubles

**Mock Objects:**
```
- MockNetworkClient
- MockNetworkManager
- MockCountryRepository
- MockCountryLocalDataSource
- MockDataMapper
```

---

## Configuration & Environment

### Build Configurations
1. **Debug**: Development environment
   - Verbose logging
   - 30-second timeout
   - Debug symbols included

2. **Production**: Release environment
   - Minimal logging
   - 15-second timeout
   - Optimized builds

### Configuration Files
```
Config/
├── Debug.xcconfig           # Debug settings
├── Production.xcconfig      # Production settings
└── Secrets.xcconfig.example # API keys template
```

### Environment Variables
- `API_BASE_URL`: REST Countries API base URL
- `API_VERSION`: API version
- Build-specific timeouts and configurations

### Info.plist Configuration
- API base URL (can override default)
- API version
- Location usage description
- App version and build number

---

## API Integration

### REST Countries API

**Base URL**: `https://restcountries.com`

**Endpoints Used:**

1. **Get All Countries**
   ```
   GET /v2/all
   ```
   Returns all countries with full information.

2. **Get Country by Code**
   ```
   GET /v2/alpha/{code}
   ```
   Returns a single country by ISO alpha code.

**Response Format:**
```json
{
  "name": "Egypt",
  "capital": "Cairo",
  "alpha2Code": "EG",
  "alpha3Code": "EGY",
  "region": "Africa",
  "population": 102334404,
  "currencies": [
    {
      "code": "EGP",
      "name": "Egyptian pound",
      "symbol": "£"
    }
  ],
  "languages": [
    {
      "iso639_1": "ar",
      "name": "Arabic",
      "nativeName": "العربية"
    }
  ],
  "flag": "https://flagcdn.com/eg.svg",
  "timezones": ["UTC+02:00"],
  "borders": ["ISR", "LBY", "SDN"]
}
```

### Flagcdn Integration

**Flag Images**: `https://flagcdn.com/w320/{alpha2code}.png`

**Features:**
- High-quality PNG flags
- Automatic caching
- Fallback handling
- Async loading

---

## Caching Strategy

### Data Caching

**Cache Layers:**
1. **Memory Cache** (L1)
   - NSCache-based
   - 50 MB limit
   - Fast access
   - Automatic eviction

2. **Disk Cache** (L2)
   - File system storage
   - 200 MB limit
   - Persistent
   - Background cleanup

3. **CoreData** (L3)
   - Persistent storage
   - Offline support
   - Structured data
   - Query capabilities

### Cache Invalidation

**Triggers:**
- Manual pull-to-refresh
- Time-based expiration
- App version change
- Memory warnings
- Background cleanup

**Policies:**
- Countries data: 24 hours
- Images: 7 days
- Search results: 1 hour
- Selected countries: Never (persistent)

### Cache Keys
```swift
"countries.all"              // All countries
"country.{code}"             // Single country
"countries.selected"         // Selected countries
"search.{query}"             // Search results
```

---

## Error Handling

### Error Types

#### Network Errors
- No internet connection
- Request timeout
- Invalid response
- Server errors (5xx)
- Client errors (4xx)

#### Data Errors
- Not found
- Invalid data format
- Mapping failures
- Decoding errors

#### Storage Errors
- Save failures
- Fetch failures
- Delete failures
- CoreData conflicts

#### Location Errors
- Permission denied
- Location unavailable
- Timeout

### Error Recovery

**Strategies:**
1. **Retry**: Automatic retry with exponential backoff
2. **Fallback**: Use cached or local data
3. **Default**: Use default values
4. **User Action**: Prompt user for action
5. **Log & Continue**: Log error and continue

### User Feedback

**Error Presentation:**
- Inline error messages
- Alert dialogs for critical errors
- Toast notifications
- Retry buttons
- Helpful error descriptions

---

## Future Enhancements

### Short Term
- [ ] Filter by region/subregion
- [ ] Sort options (name, population, area)
- [ ] Comparison mode (compare 2+ countries)
- [ ] Dark mode support
- [ ] Localization (multiple languages)

### Medium Term
- [ ] Maps integration (show country on map)
- [ ] Historical data and statistics
- [ ] Export selected countries
- [ ] Share country information
- [ ] Widget support

### Long Term
- [ ] Real-time currency conversion
- [ ] Travel planning features
- [ ] Country news feed
- [ ] Social features (share lists)
- [ ] AR country exploration
- [ ] iPad optimization

### Technical Improvements
- [ ] Swift Concurrency (async/await)
- [ ] Modularization with SPM
- [ ] GraphQL API integration
- [ ] SwiftUI animations and transitions
- [ ] Accessibility improvements
- [ ] Performance monitoring
- [ ] Analytics integration
- [ ] Crash reporting

---

## Development Setup

### Prerequisites
- Xcode 15.0+
- iOS 16.0+
- Swift 5.9+
- macOS Ventura or later

### Installation
1. Clone the repository
   ```bash
   git clone https://github.com/ABDELRHMANYOUSSEFABDO/CountryExplorer.git
   ```

2. Open the project
   ```bash
   cd CountryExplorer
   open CountryExplorer.xcodeproj
   ```

3. Configure secrets (if needed)
   ```bash
   cp Config/Secrets.xcconfig.example Config/Secrets.xcconfig
   # Edit Secrets.xcconfig with your API keys
   ```

4. Build and run
   - Select target device/simulator
   - Press Cmd+R to build and run

### Running Tests
```bash
# Unit tests
Cmd+U in Xcode

# Or via command line
xcodebuild test -scheme CountryExplorer -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Architecture Decisions

### Why Clean Architecture?
- **Separation of Concerns**: Each layer has a clear responsibility
- **Testability**: Business logic is independent of frameworks
- **Flexibility**: Easy to swap implementations
- **Maintainability**: Changes are localized to specific layers
- **Scalability**: Easy to add new features

### Why SwiftUI?
- **Modern**: Apple's recommended UI framework
- **Declarative**: Easier to reason about UI state
- **Performance**: Optimized rendering
- **Integration**: Works seamlessly with Combine
- **Future-proof**: Apple's strategic direction

### Why CoreData?
- **Native**: First-party framework with excellent support
- **Performance**: Optimized for iOS
- **Features**: Relationships, queries, migrations
- **Integration**: Works well with SwiftUI
- **Reliability**: Battle-tested and mature

### Why Protocol-Oriented Design?
- **Testability**: Easy to create mocks
- **Flexibility**: Multiple implementations
- **Dependency Inversion**: Depend on abstractions
- **Compile-time Safety**: Type-safe protocols
- **Swift Philosophy**: Aligns with Swift's strengths

---

## Performance Considerations

### Optimization Techniques
1. **Lazy Loading**: Load data only when needed
2. **Image Caching**: Reduce network requests
3. **Data Caching**: Multi-tier cache strategy
4. **Background Processing**: Heavy operations off main thread
5. **Efficient Search**: Optimized search algorithms
6. **Memory Management**: Proper cleanup and lifecycle handling

### Monitoring
- Instruments for profiling
- Memory graph debugging
- Network activity monitoring
- CoreData performance tracking

---

## Security Considerations

### Data Protection
- No sensitive user data collected
- API keys in configuration files (gitignored)
- Secure HTTPS communication
- No authentication required

### Privacy
- Location permission explanation
- Minimal location data usage
- No tracking or analytics (yet)
- No personal data storage

---

## Contributing

### Code Style
- Follow Swift API Design Guidelines
- Use SwiftLint (future)
- Meaningful naming conventions
- Comprehensive documentation

### Pull Request Process
1. Create feature branch from development
2. Implement changes with tests
3. Ensure all tests pass
4. Update documentation
5. Submit PR to master with clear description

---

**Developer**: Abdelrahman Youssef  
**Date**: November 14, 2025  
**Last Updated**: November 15, 2025
