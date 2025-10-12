# UI Changes for Old Launchpad Import Feature

## Visual Description

### Settings Panel - Actions Tab

The new "Import from Old Launchpad" button has been added to the **Actions** tab in the Settings panel (accessible via CMD + ,).

### Button Layout

```
┌─────────────────────────────────────────────────┐
│  Layout Management                               │
│                                                  │
│  ┌──────────────────────────────────────────┐  │
│  │  📤  Export Layout                       │  │  (Blue)
│  └──────────────────────────────────────────┘  │
│                                                  │
│  ┌──────────────────────────────────────────┐  │
│  │  📥  Import Layout                       │  │  (Green)
│  └──────────────────────────────────────────┘  │
│                                                  │
│  ┌──────────────────────────────────────────┐  │
│  │  📄  Import from Old Launchpad    ⭐NEW  │  │  (Purple)
│  └──────────────────────────────────────────┘  │
│                                                  │
│  ┌──────────────────────────────────────────┐  │
│  │  🗑️  Clear All Apps                      │  │  (Red)
│  └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

### Button Specifications

**New Button Details:**
- **Label**: "Import from Old Launchpad"
- **Icon**: `arrow.down.doc` (SF Symbol)
- **Color**: Purple background (opacity 0.1), purple text
- **Position**: Between "Import Layout" and "Clear All Apps"
- **Style**: Rounded corners (8px), padding (16px horizontal, 10px vertical)

### Alert Dialogs

#### Success Dialog
```
┌─────────────────────────────────────────┐
│  Import Successful                       │
│                                          │
│  Successfully imported layout from old   │
│  macOS Launchpad.                        │
│                                          │
│              [ OK ]                      │
└─────────────────────────────────────────┘
```

#### Failure Dialog
```
┌─────────────────────────────────────────┐
│  Import Failed                           │
│                                          │
│  Could not find or read the old         │
│  Launchpad database. Make sure you      │
│  have used the old Launchpad before.    │
│                                          │
│              [ OK ]                      │
└─────────────────────────────────────────┘
```

### User Flow

1. User opens Settings (CMD + ,)
   ```
   Settings Window Opens
   ↓
   ```

2. User navigates to "Actions" tab
   ```
   Actions Tab Selected
   ↓
   ```

3. User sees new purple button "Import from Old Launchpad"
   ```
   Button Visible in Layout Management Section
   ↓
   ```

4. User clicks button
   ```
   Import Process Begins
   ↓
   Database Check → Read Data → Process Layout
   ↓
   ```

5. User sees result
   ```
   Success Alert ✓  OR  Failure Alert ✗
   ↓
   ```

6. If successful, app layout updates immediately
   ```
   Pages Reorganized → Folders Created → Apps Positioned
   ```

### Color Scheme

The button follows the existing color scheme in ActionsSettings:

- **Export Layout**: Blue (#0066FF with 0.1 opacity)
- **Import Layout**: Green (#00FF00 with 0.1 opacity)
- **Import from Old Launchpad**: **Purple (#800080 with 0.1 opacity)** ⭐ NEW
- **Clear All Apps**: Red (#FF0000 with 0.1 opacity)
- **Force Quit**: Orange (#FFA500 with 0.1 opacity)

### Icon Reference

SF Symbol used: `arrow.down.doc`
```
    ↓
  ┌───┐
  │   │
  │   │
  └───┘
```
This icon suggests "downloading/importing from a document/database".

### Localization

The button text is localized in both supported languages:

- **English**: "Import from Old Launchpad"
- **Hungarian**: "Importálás Régi Launchpad-ből"

### Accessibility

- Button uses standard SwiftUI accessibility features
- SF Symbol provides visual context
- Alert dialogs use clear, descriptive text
- Color contrast meets accessibility standards

### Animation

- Button uses standard SwiftUI button animation on press
- Alert appears with system fade-in animation
- Layout changes animate smoothly after successful import

### Context in Full Settings View

```
┌─────────────────────────────────────────────────────────┐
│  Launchpad Settings                          ⚙️          │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  [ Layout ]  [ Features ]  [ Actions ]                  │
│                              ▔▔▔▔▔▔▔                     │
│                                                          │
│  Layout Management                                       │
│  ┌────────────────────────────────────────────────┐    │
│  │  📤  Export Layout                             │    │
│  └────────────────────────────────────────────────┘    │
│  ┌────────────────────────────────────────────────┐    │
│  │  📥  Import Layout                             │    │
│  └────────────────────────────────────────────────┘    │
│  ┌────────────────────────────────────────────────┐    │
│  │  📄  Import from Old Launchpad          ⭐NEW  │    │
│  └────────────────────────────────────────────────┘    │
│  ┌────────────────────────────────────────────────┐    │
│  │  🗑️  Clear All Apps                            │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
│  Application Control                                     │
│  ┌────────────────────────────────────────────────┐    │
│  │  ⚡  Force Quit                                │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Implementation Notes

The button integrates seamlessly with existing UI components:

1. **Consistent Styling**: Matches other action buttons in layout and appearance
2. **Proper Spacing**: 12px vertical spacing between buttons
3. **Responsive**: Adapts to window width
4. **Theme Support**: Works with both light and dark modes
5. **SwiftUI Native**: Uses standard SwiftUI components for consistency

## Testing the UI

To test the UI changes:

1. Build and run the application
2. Press CMD + , to open settings
3. Click on the "Actions" tab
4. Verify the new purple button appears between "Import Layout" and "Clear All Apps"
5. Click the button to test the import functionality
6. Verify appropriate success/failure alert appears

## Expected User Experience

- **Clear Visual Hierarchy**: Button positioned logically in import/export section
- **Intuitive Icon**: Document with arrow suggests importing from a file/database
- **Distinctive Color**: Purple makes it stand out as a new feature
- **Immediate Feedback**: Alert dialog confirms success or explains failure
- **No Confusion**: Button disabled when database not found would be future enhancement
