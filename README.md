# LaunchBack
A free and open-source re-implementation of the "classic" macOS Launchpad.

<img width="1440" alt="LaunchBack UI" src="https://github.com/user-attachments/assets/1282da0a-730d-454e-9541-09cea0a1c23a" />

_As I'm sure everyone's heard by now, as of the newest release of macOS 26 (Beta 1), Apple has removed the fullscreen Launchpad grid application in favor of an integrated Spotlight app drawer. Fortunately, there are ways to bring it back as of Beta 1 with terminal commands and apps on various online sources, but seeing as those will likely be patched or rendered unusable in the future... I've started making my own for everyone._

**LaunchBack (or "LaunchpadGlass", as the icon shows in this demo per my original name concept as “Launchpad but Liquid Glass”) is just that – a free and open source clone of Launchpad written in Swift with the newest Xcode 16, meant to be a fully–featured drop-in replacement for the original going forward in the style of apps like OpenShell and others for the Windows Start Menu. It is entirely independent of all Spotlight and Launchpad (or now "Apps" as it is called in Tahoe Beta 1) code and dependencies, so even if both of those were entirely ripped out of macOS (highly unlikely but just making a point), this app would still be 100% functional!**

https://github.com/user-attachments/assets/3154a711-82d1-440c-ab2b-2827f7a734d9

As of release version 1.0, there is still much work to be done. As such, the following is a list of things to potentially explore in future releases:
* Add a Settings pane with the following (non-exhaustive) options:
  * Manual sorting: Rather than sorting within the Launchpad itself, since items are automatically displayed left to right and top to bottom, apps could be manually sorted in a vertical list pane of sorts.
    * Folder support, if possible, would be added with/after manual sorting.
 * Right-click options: Similar to the menu when right-clicking an app on macOS within Finder or long-pressing an app on iOS, I _may_ implement some form of this feature for LaunchBack to reveal an item's location in Finder and more.
  * Custom application directories: In the video demo, only system-wide apps are shown in LaunchBack, whereas Launchpad shows system and user apps, web apps, etc. I plan to allow any user-selected folders to be added, though the initial release only shows system-wide applications. If implemented, this may also come with manual app hiding.
  * Customizable hotkey support to open LaunchBack: Setting either a two or three-key shortcut to open the app, comment down below which you'd prefer.
  * Grid size customization (possibly, though doubtful at least for now since getting the grid in the first place was a serious challenge)
* Sparkle update support for apps like Latest (and possibly Homebrew support)
* (Potentially) A vertical app drawer option like on most Android app drawers, or as a separate release. Believe me, a vertical version of this is WAY easier to make, and I actually made one by accident at the start.

Until then... enjoy LaunchBack!
