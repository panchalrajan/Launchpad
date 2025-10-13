# Old macOS Launchpad Import Feature

## Overview

This feature allows users to import their existing app layout from the native macOS Launchpad database into this custom Launchpad replacement. This saves users from having to manually reorganize all their apps after switching.

## Implementation Details

### Database Location

The old macOS Launchpad stores its data in an SQLite database at:
```
/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db
```

The path is dynamically determined using the `getconf DARWIN_USER_DIR` command, which returns the user's cache directory.

### Database Schema

The Launchpad database contains several key tables:

1. **apps**: Contains application information
   - `item_id`: Foreign key to items table
   - `title`: Application name
   - `path`: File system path to the .app bundle

2. **items**: Contains positioning and hierarchy information
   - `rowid`: Primary key
   - `parent_id`: References another item (for folders/pages)
   - `ordering`: Position within parent

3. **groups**: Contains folder information
   - `item_id`: Foreign key to items table
   - `title`: Folder name

### Components

#### LaunchpadDatabaseReader.swift

A utility class that handles reading from the old Launchpad database:

- `getOldLaunchpadDatabasePath()`: Determines the database path dynamically
- `oldLaunchpadDatabaseExists()`: Checks if the database file exists
- `readOldLaunchpadLayout()`: Reads app positions and pages
- `readOldLaunchpadFolders()`: Reads folder structures

#### AppManager Extension

Added `importFromOldLaunchpad(appsPerPage:)` method that:

1. Checks if old database exists
2. Reads layout and folder data
3. Merges with currently discovered apps
4. Preserves folder structures
5. Maintains page organization
6. Adds any new apps not in old layout

### User Interface

Added a new button in the Actions Settings panel:

- **Button**: "Import from Old Launchpad"
- **Icon**: arrow.down.doc (SF Symbol)
- **Color**: Purple theme
- **Location**: Settings → Actions → Layout Management

### Localization

Added strings in both English and Hungarian:

- `import_from_old_launchpad`: Button label
- `import_success`: Success dialog title
- `import_success_message`: Success message
- `import_failed`: Failure dialog title
- `import_failed_message`: Failure explanation

### Error Handling

The implementation handles several edge cases:

1. **Database Not Found**: Returns `false` and shows user-friendly error message
2. **Invalid Database**: SQLite errors handled gracefully
3. **Missing Apps**: Apps in old layout but not currently installed are skipped
4. **Empty Database**: Handled without crashing
5. **Permission Issues**: File access errors caught and reported

### Testing

Created comprehensive test suite in `LaunchpadDatabaseReaderTests.swift`:

- Path detection tests
- Database existence checks
- Layout reading validation
- Folder structure validation
- Integration tests with AppManager
- Performance tests
- Edge case handling

### Data Migration Flow

```
Old Launchpad DB → SQLite Reader → Layout Parser → AppManager → New Layout
                                                              ↓
                                                      User Defaults Storage
```

### Compatibility

- **Requires**: Old macOS Launchpad database (pre-macOS 26)
- **Works with**: macOS 15.6 and later
- **Backward Compatible**: Does not modify old database
- **Safe**: Read-only access to old database

## Usage

1. User opens Settings (CMD + ,)
2. Navigates to Actions tab
3. Clicks "Import from Old Launchpad" button
4. System reads old database
5. Layout is imported and displayed
6. Success/failure alert shown

## Benefits

- **Zero Manual Work**: Users don't need to reorganize apps
- **Preserves Customization**: All folder structures maintained
- **Safe Operation**: Read-only, no data loss risk
- **User Feedback**: Clear success/failure messages
- **Fallback Behavior**: Gracefully handles missing database

## Future Enhancements

Potential improvements:

1. Automatic import on first launch
2. Import preview before applying
3. Selective import (choose which pages/folders)
4. Import from backup locations
5. Export in old Launchpad format

## Credits

Feature requested by @gasmask-g in issue #XX
Database path information provided by community
Implementation by GitHub Copilot
