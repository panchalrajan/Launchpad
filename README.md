# 🚀 LaunchPad

A beautiful, modern macOS application launcher with glass morphism design, inspired by macOS Launchpad but with enhanced functionality and customization options. As you might know, Apple removed Launchpad in macOS 26. This app offers a true replacement with even more features and a fully customizable, persistent grid.

If you like this project and want to support further development, please consider:

<a href="https://www.buymeacoffee.com/Waikiki.com" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

## ✨ Features

### 🎨 **Modern, Adaptive Design**
- **Glass Morphism UI** – Translucent, blurred backgrounds for a modern look
- **Smooth Animations** – Fluid transitions and spring effects throughout
- **Justified Grid** – Icons and folders are always evenly distributed, filling all available space
- **Consistent Alignment** – Search results and grid pages always align perfectly
- **Responsive Layout** – Adapts to any screen size or aspect ratio

![LaunchPad Main Interface](Documentation/Launchpad-1.png)

### 🔍 **Powerful Search**
- **Instant Filtering** – Real-time, fuzzy search as you type
- **Vertical Scrolling** – Effortless navigation through results
- **Consistent Alignment** – Search and grid always start at the same position
- **No Results State** – Clean, helpful empty state

![Search Functionality](Documentation/Launchpad-2.png)

### 🗂️ **Folders & Drag & Drop**
- **Create Folders** – Drag one app onto another to instantly create a folder
- **Rename Folders** – Click folder name to edit (auto-focus for new folders)
- **Add/Remove Apps** – Drag apps in/out of folders, or use context menu
- **Rearrangeable Icons** – Drag and drop to customize app order
- **Visual Feedback** – Apps scale and fade during drag operations
- **Persistent Layout** – All changes are saved automatically
- **Smart Overflow** – Apps overflow to new pages as needed

![Folder](Documentation/Launchpad-4.png)
![Folders](Documentation/Launchpad-5.png)

### 🎮 **Multiple Navigation Methods**

#### ⌨️ **Keyboard Navigation**
- `←/→` Arrow keys – Navigate between pages
- `CMD + ,` – Open settings
- `ESC` – Close application

#### 🖱️ **Mouse Navigation**
- **Click Navigation** – Click page dots to jump to any page
- **Scroll Wheel** – Horizontal scrolling for page navigation
- **Smart Scrolling** – Vertical scrolling in search mode
- **Click inside folder detail** – Does not close Launchpad

#### 📱 **Touch & Gestures**
- **Tap to Launch** – Single tap to open applications
- **Drag to Rearrange** – Long press and drag to reorder
- **Swipe Navigation** – Gesture-based page switching

## ⚙️ **Comprehensive Settings**

LaunchPad offers deep customization to tailor your experience:

![Settings](Documentation/Launchpad-3.png)

### 🔧 **Accessing Settings**
- **Menu Bar**: `LaunchPad` → `Settings` (⌘,)

### 📐 **Grid & Layout Configuration**
- **Columns**: 4–12 per page
- **Rows**: 3–10 per page
- **Apps per Page**: Calculated automatically
- **Justified Grid**: Icons and folders always fill the grid evenly
- **Real-time Preview**: See changes instantly

### 🎨 **Icon & Animation Customization**
- **Icon Size**: Fine-tune from 20–200 px
- **Drop Animation Delay**: Adjustable for drag & drop
- **Visual Feedback**: Real-time display and smooth scaling

### 🧩 **Persistent & Adaptive**
- **All settings and layout are saved** – Your custom grid and folders are always restored
- **Consistent alignment** – Search and grid always start at the same position

## 🚀 Getting Started

### First Launch
1. The app scans `/Applications` and `/System/Applications`
2. Apps are sorted alphabetically
3. Use drag & drop to customize your layout and create folders
4. Click folder names to rename (auto-focus for new folders)
5. All changes are saved automatically
6. Launchpad quits if you activate another app from the dock

### Usage
- **Search**: Type to filter apps instantly
- **Navigate Pages**: Use arrow keys, click dots, or scroll
- **Launch Apps**: Click any app icon to open
- **Rearrange**: Drag apps to new positions
- **Create Folders**: Drag one app onto another
- **Rename Folders**: Click folder name (auto-focus for new folders)
- **Remove from Folder**: Use context menu or drag out
- **Quit Launchpad**: Activate another app or press ESC

## 🙏 Acknowledgments
- Based on LaunchBack project
- Inspired by macOS Launchpad
- Glass morphism design trends
- SwiftUI community examples
- macOS design guidelines
