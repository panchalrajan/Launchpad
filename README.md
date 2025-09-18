# 🚀 LaunchPad

A beautiful, modern macOS application launcher with glass morphism design, inspired by macOS Launchpad but with enhanced functionality and customization options.

<a href="https://www.buymeacoffee.com/Waikiki.com" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

## ✨ Features

### 🎨 **Beautiful Design**
- **Glass Morphism UI** - Modern translucent interface with backdrop blur
- **Smooth Animations** - Fluid transitions and spring animations throughout
- **Adaptive Layout** - Responsive design that adapts to different screen sizes
- **Visual Feedback** - Hover states, scaling effects, and interactive elements

### 🔍 **Smart Search**
- **Real-time Search** - Instant filtering as you type
- **Fuzzy Matching** - Find apps even with partial names
- **Vertical Scrolling** - Smooth scrolling through search results
- **No Results State** - Clean empty state with helpful messaging

### 📱 **Drag & Drop**
- **Rearrangeable Icons** - Drag and drop to customize app order
- **Visual Feedback** - Apps scale and fade during drag operations
- **Persistent Order** - Your custom arrangement is automatically saved
- **Smart Positioning** - Smooth animations when dropping apps

### 📊 **Persistent Storage**
- **UserDefaults Storage** - Lightweight storage for app arrangements
- **Core Data Option** - Advanced database storage available
- **Automatic Backup** - Order is preserved between app launches
- **New App Handling** - Newly installed apps are automatically added

### 🎮 **Multiple Navigation Methods**

#### ⌨️ **Keyboard Navigation**
- `←/→` Arrow keys - Navigate between pages
- `ESC` - Close application
- Smart context awareness (doesn't interfere with search)

#### 🖱️ **Mouse Navigation**
- **Click Navigation** - Click page dots to jump to any page
- **Arrow Buttons** - Previous/Next buttons with visual states
- **Scroll Wheel** - Horizontal scrolling for page navigation
- **Smart Scrolling** - Vertical scrolling in search mode

#### 📱 **Touch & Gestures**
- **Tap to Launch** - Single tap to open applications
- **Drag to Rearrange** - Long press and drag to reorder
- **Swipe Navigation** - Gesture-based page switching

### 🔧 **Advanced Features**
- **Auto-focus Search** - Search field automatically focused on launch
- **Page Indicators** - Visual dots showing current page and total pages
- **Boundary Detection** - Smart navigation that respects page limits
- **Background Processing** - Non-blocking app discovery and loading

### First Launch
1. The app will automatically scan `/Applications` and `/System/Applications`
2. Apps are initially sorted alphabetically
3. Use drag & drop to customize your layout
4. Your arrangement is automatically saved

## 🎯 Usage

### Basic Navigation
- **Search**: Type to filter apps instantly
- **Navigate Pages**: Use arrow keys, click dots, or scroll
- **Launch Apps**: Click any app icon to open
- **Rearrange**: Drag apps to new positions

### Keyboard Shortcuts
| Key | Action |
|-----|--------|
| `←` | Previous page |
| `→` | Next page |
| `ESC` | Close application |
| `⌘⇧R` | Reset app order to default |

### Advanced Features
- **Persistent Layout**: Your custom arrangement is saved automatically
- **New App Detection**: Newly installed apps appear at the end
- **Search History**: Search field remembers focus state
- **Visual Feedback**: All interactions provide smooth visual feedback

## 🙏 Acknowledgments

- Inspired by macOS Launchpad
- Glass morphism design trends
- SwiftUI community examples
- macOS design guidelines
