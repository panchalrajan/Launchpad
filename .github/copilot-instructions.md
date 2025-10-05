# LaunchPad - Copilot Context

## Project Overview

LaunchPad is a modern macOS application launcher built with SwiftUI that serves as a replacement for Apple's deprecated Launchpad. It provides a beautiful, customizable interface for organizing and launching applications with advanced features like folders, search, and drag-and-drop functionality.

## Architecture & Key Features

### 🎨 **Design Philosophy**
- **Glass Morphism UI**: Translucent, blurred backgrounds using `NSVisualEffectView`
- **Smooth Animations**: Fluid transitions with spring effects throughout
- **Justified Grid**: Icons and folders evenly distributed, filling all available space
- **Responsive Layout**: Adapts to any screen size and aspect ratio
- **Dark/Light Mode**: Automatic theme adaptation using SwiftUI's `colorScheme`

### 🏗️ **Architecture Pattern**
- **MVVM**: Model-View-ViewModel architecture using SwiftUI's `@StateObject` and `@ObservableObject`
- **Singleton Managers**: Centralized state management with `SettingsManager` and `AppManager`
- **Reactive UI**: SwiftUI bindings for real-time updates across views
- **Persistent Storage**: UserDefaults for settings and layout persistence

## Core Components

### 📱 **Main Application Structure**
```
LaunchpadApp (App Entry Point)
├── WindowAccessor (Window Configuration)
├── PagedGridView (Main Container)
├── SettingsView (Settings Overlay)
└── VisualEffectView (Background)
```

### 🧠 **Managers**

#### `AppManager` (Singleton)
- **Primary Role**: Application discovery, layout management, and persistence
- **Key Methods**:
  - `loadGridItems(appsPerPage:)`: Discovers apps and loads saved layout
  - `saveGridItems()`: Persists current layout to UserDefaults
  - `recalculatePages(appsPerPage:)`: Redistributes items across pages
  - `importLayout(appsPerPage:)` / `exportLayout()`: JSON-based layout backup
  - `clearGridItems(appsPerPage:)`: Resets to default alphabetical order

#### `SettingsManager` (Singleton)
- **Primary Role**: User preferences and configuration management
- **Settings Include**:
  - Grid dimensions (columns: 4-12, rows: 3-10)
  - Icon size (20-200px)
  - Animation delays and scroll thresholds
  - Folder layout configuration

### 📊 **Data Models**

#### `AppGridItem` (Enum)
```swift
enum AppGridItem: Identifiable, Equatable {
    case app(AppInfo)
    case folder(Folder)
}
```
- **Unified Interface**: Handles both applications and folders consistently
- **Serialization**: JSON export/import with `serialize()` method
- **Page Management**: Each item tracks its page location

#### `AppInfo` (Struct)
- **Properties**: `id`, `name`, `icon` (NSImage), `path`, `page`
- **Icon Processing**: Flattened for consistency using `flattenedForConsistency()`
- **Localization**: Uses `kMDItemDisplayName` for proper app names

#### `Folder` (Struct)
- **Properties**: `id`, `name`, `page`, `apps: [AppInfo]`
- **Preview**: Shows up to 9 apps in 3x3 grid preview
- **Dynamic Management**: Apps can be added/removed via drag-and-drop

#### `LaunchpadSettings` (Codable Struct)
- **Grid Configuration**: columns, rows, iconSize, dropDelay
- **Folder Settings**: folderColumns, folderRows
- **Interaction Settings**: scrollDebounceInterval, scrollActivationThreshold
- **Feature Flags**: showDock, transparency
- **Validation**: Enforces min/max bounds for all numeric settings

### 🎛️ **View Components**

#### Main Views
- **`PagedGridView`**: Primary container with horizontal page navigation
- **`SinglePageView`**: Individual page with LazyVGrid layout
- **`SearchResultsView`**: Vertical scrolling search results
- **`FolderDetailView`**: Modal folder content editor
- **`SettingsView`**: Tabbed settings interface (Layout + Features + Actions)

#### UI Components
- **`GridItemView`**: Unified renderer for apps and folders
- **`AppIconView`**: Application icon with name label
- **`FolderIconView`**: 3x3 grid preview of folder contents
- **`FolderNameView`**: Editable folder name header in folder detail view
- **`PageIndicatorView`**: Clickable page dots navigation
- **`SearchBarView`**: Top search input with glass morphism styling

#### Settings Components
- **`LayoutSettings`**: Grid dimensions and icon size configuration
- **`FeaturesSettings`**: Feature flags and interaction settings (dock, transparency, animations)
- **`ActionsSettings`**: Layout import/export and app management actions
- **`SettingsSlider`**: Reusable slider control with min/max labels
- **`SettingsNumberField`**: Numeric input with stepper control
- **`SettingsToggle`**: Toggle switch for boolean settings

#### Specialized Components
- **`DropZoneView`**: Left/right page navigation drop targets
- **`PageDropZonesView`**: Container for navigation drop zones
- **`EmptySearchView`**: No results state for search
- **`VisualEffectView`**: NSVisualEffectView wrapper for glass morphism

### 🎯 **Drag & Drop System**

#### Drop Delegates
- **`ItemDropDelegate`**: Handles app-to-app and app-to-folder drops, page overflow management
- **`FolderDropDelegate`**: Manages app reordering within folders
- **`RemoveDropDelegate`**: Removes apps from folders when dragged outside
- **`PageDropDelegate`**: Moves items to end of target page

#### Drag & Drop Features
- **Folder Creation**: Drag one app onto another to create folders
- **App Reordering**: Drag to rearrange apps within pages/folders
- **Cross-Page Movement**: Drop zones for page navigation during drag
- **Visual Feedback**: Scale and opacity changes during drag operations
- **Animation Delays**: Configurable delays for smooth drop animations

### 🔍 **Search System**

#### Search Implementation
- **Real-time Filtering**: Updates as user types using SwiftUI bindings
- **Fuzzy Matching**: Case-insensitive substring matching
- **Multi-source Search**: Searches both app names and folder contents
- **Folder Awareness**: Shows folder apps when folder name matches
- **Consistent Layout**: Search results use same grid layout as main pages

#### Search Components
- **`SearchField`**: NSSearchField wrapper with proper focus management
- **`SearchBarView`**: Styled search container with glass morphism
- **`SearchResultsView`**: Results display with vertical scrolling
- **`EmptySearchView`**: Clean no-results state

### ⚙️ **Settings System**

#### Layout Settings
- **Grid Dimensions**: Real-time preview of column/row changes
- **Icon Sizing**: Slider control with immediate visual feedback
- **Transparency**: Adjustable UI transparency from 0% to 200%
- **Folder Configuration**: Separate settings for folder grid layout

#### Features Settings
- **Show Dock**: Toggle macOS Dock visibility when Launchpad is active
- **Animation Timing**: Drop delay and scroll sensitivity controls
- **Scroll Settings**: Debounce interval and activation threshold for page navigation

#### Actions Settings
- **Layout Management**: Export/import layout as JSON
- **Reset Options**: Clear all customizations, return to alphabetical order
- **Application Control**: Force quit Launchpad application
- **Confirmation Dialogs**: Destructive actions require user confirmation

### 🌐 **Localization**

#### Supported Languages
- **English** (`en.lproj`)
- **Hungarian** (`hu.lproj`)

#### Localization System
- **`LocalizationHelper.swift`**: Centralized L10n struct with all strings
- **String Extension**: `.localized` property for easy translation
- **Debug Support**: Localization debugging in development builds

### 🎮 **Input & Navigation**

#### Keyboard Support
- **Arrow Keys**: Left/right for page navigation
- **CMD+,**: Open settings
- **ESC**: Exit application

#### Mouse & Trackpad
- **Click Navigation**: Page dots for direct page jumping
- **Horizontal Scrolling**: Page navigation with debouncing
- **Tap to Launch**: Single click/tap to open apps
- **Drag Support**: Full drag-and-drop across all elements

#### Touch & Gestures (if applicable)
- **Swipe Navigation**: Gesture-based page switching
- **Long Press**: Initiate drag operations

### 🔧 **Utilities**

#### Helper Classes
- **`AppLauncher`**: Handles app launching and Launchpad exit
- **`DropAnimationHelper`**: Manages delayed animations during drops
- **`GridLayoutUtility`**: Creates SwiftUI GridItem configurations
- **`ImageFlatten`**: NSImage extension for consistent icon rendering
- **`LaunchPadConstants`**: Centralized constants for animations, layout, timing, and UI

#### Layout System
- **`LayoutMetrics`**: Calculates responsive grid dimensions
- **Dynamic Sizing**: Adapts to screen size and user preferences
- **Justified Layout**: Ensures even distribution of grid items

### 📁 **File Structure**
```
Launchpad/
├── LaunchpadApp.swift              # App entry point
├── Managers/
│   ├── AppManager.swift           # App discovery & layout
│   └── SettingsManager.swift      # User preferences
├── Models/
│   ├── AppGridItem.swift          # Unified app/folder model
│   ├── AppInfo.swift              # Application data
│   ├── Folder.swift               # Folder container
│   ├── LaunchpadSettings.swift    # Configuration model
│   └── LayoutMetrics.swift        # Grid calculations
├── Components/
│   ├── PagedGridView.swift        # Main container
│   ├── SinglePageView.swift       # Individual page
│   ├── GridItemView.swift         # Unified item renderer
│   ├── AppIconView.swift          # App icon display
│   ├── PageIndicatorView.swift    # Page navigation dots
│   ├── VisualEffectView.swift     # Glass morphism
│   ├── WindowAccessor.swift       # Window configuration
│   ├── Search/
│   │   ├── SearchBarView.swift
│   │   ├── SearchField.swift
│   │   ├── SearchResultsView.swift
│   │   └── EmptySearchView.swift
│   ├── Folders/
│   │   ├── FolderDetailView.swift
│   │   ├── FolderIconView.swift
│   │   └── FolderNameView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── LayoutSettings.swift
│   │   ├── FeaturesSettings.swift
│   │   ├── ActionsSettings.swift
│   │   ├── SettingsSlider.swift
│   │   ├── SettingsNumberField.swift
│   │   └── SettingsToggle.swift
│   └── DropZones/
│       ├── DropZoneView.swift
│       └── PageDropZonesView.swift
├── Delegates/
│   ├── ItemDropDelegate.swift     # App/folder drop handling
│   ├── FolderDropDelegate.swift   # Folder reordering
│   ├── RemoveDropDelegate.swift   # Remove from folder
│   └── PageDropDelegate.swift     # Page-level drops
├── Utilities/
│   ├── AppLauncher.swift          # App launching
│   ├── DropAnimationHelper.swift  # Animation timing
│   ├── GridLayoutUtility.swift    # Grid helpers
│   ├── ImageFlatten.swift         # Icon processing
│   ├── LaunchPadConstants.swift   # App-wide constants
│   ├── LocalizationHelper.swift   # L10n system
│   └── AppGridItemExtensions.swift # Serialization
└── Localization/
    ├── en.lproj/Localizable.strings
    └── hu.lproj/Localizable.strings
```

### 🧪 **Testing**

#### Test Structure
- **`AppManagerTests.swift`**: Core functionality tests
- **`AppManagerDiscoveryTests.swift`**: App discovery tests
- **`AppManagerPersistenceTests.swift`**: Data persistence tests
- **`AppManagerImportExportTests.swift`**: Layout backup tests

## Development Guidelines

### 🎨 **UI Patterns**
- Use `@StateObject` for manager singletons
- Prefer `@Binding` for child view data flow
- Implement proper `@Environment` usage for theme detection
- Follow SwiftUI animation best practices with spring curves

### 🔄 **State Management**
- Centralize app state in managers
- Use published properties for reactive updates
- Implement proper error handling in async operations
- Maintain data consistency across view updates

### 🎯 **Performance**
- Use `LazyVGrid` for large collections
- Implement proper image caching for app icons
- Optimize drag-and-drop with minimal state updates
- Use `GeometryReader` efficiently for responsive layouts

### 🧪 **Testing Strategy**
- Mock app discovery for consistent testing
- Test serialization/deserialization roundtrips
- Validate settings bounds and validation
- Test drag-and-drop state transitions

## Common Patterns

### Data Flow
1. **App Discovery**: `AppManager.discoverApps()` → file system scan
2. **Layout Loading**: `loadLayoutFromUserDefaults()` → merge with discovered apps
3. **Page Calculation**: `groupItemsByPage()` → distribute items across pages
4. **UI Update**: SwiftUI bindings trigger view updates
5. **Persistence**: Changes automatically saved via `didSet` observers

### Drag & Drop Flow
1. **Drag Start**: `onDrag` creates `NSItemProvider` with item ID
2. **Drop Target**: Delegate methods handle drop validation
3. **Animation**: `DropAnimationHelper` manages delayed movements
4. **State Update**: Modify data models, trigger UI refresh
5. **Persistence**: Changes automatically saved

### Settings Flow
1. **Load**: `SettingsManager` loads from UserDefaults on init
2. **Update**: UI controls modify published settings
3. **Validation**: Settings struct enforces bounds
4. **Apply**: Manager methods recalculate layout if needed
5. **Save**: Automatic persistence via `didSet`

This context provides comprehensive understanding of LaunchPad's architecture, components, and development patterns for effective AI assistance.