# Grid Clock

A word-clock screen saver for macOS.

![Grid Clock Screenshot](GridClock.png)

## Compatibility

Version 0.1.0 renders the clock with AppKit and `ScreenSaverView`; it no longer
uses the legacy WebKit `WebView` runtime. This keeps the clock updating on
macOS 26, where WebView-based screen savers can be frozen by the screen saver
host.

The project deployment target is macOS 10.11. It has been tested on macOS
26.5.2.

## Install a release

Download [`Grid Clock 0.1.0`](https://github.com/chenglingli/grid-clock-screensaver/releases/download/0.1.0/Grid.Clock.0.1.0.saver.zip), then double-click it and choose **Install** (or **Replace** when updating an existing installation). Select **Grid Clock** in **System Settings → Wallpaper → Screen Saver**.

## Build and test locally

1. Open `Grid Clock.xcodeproj` in Xcode.
2. Select the **Grid Clock** scheme and **My Mac** destination.
3. Choose **Product → Clean Build Folder**, then **Product → Build**.
4. Choose **Product → Show Build Folder in Finder** and open `Products/Debug/Grid Clock.saver`.
5. Double-click the bundle, choose **Replace** if prompted, then preview it in System Settings.

macOS can cache an installed screen saver bundle. If an update appears not to
take effect, quit System Settings and restart the Mac before testing again.

## Development notes

The old `Webview/` directory remains in the repository as reference material,
but it is no longer included in the screen saver bundle or linked at runtime.

## Related

- [Epoch Flip Clock Screensaver](https://github.com/chrstphrknwtn/epoch-flip-clock-screensaver)
- [Word Clock Screensaver](https://github.com/chrstphrknwtn/word-clock-screensaver)
