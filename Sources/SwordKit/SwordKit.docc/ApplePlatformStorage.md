# Managing Modules on Apple Platforms

Keep SWORD modules in app-owned storage and adapt installation and restoration
to each platform's lifecycle.

## Use Application Support

``SwordModuleLocation/applicationSupport(applicationIdentifier:)`` resolves
separate module and installer directories beneath the user's Application Support
directory. It uses the host bundle identifier by default:

```swift
let location = try SwordModuleLocation.applicationSupport()
let library = try SwordLibrary(location: location)
let configuration = SwordInstallerConfiguration(location: location)
```

Use the same location for reading and installation so a library refresh discovers
newly installed content.

## Supply explicit containers

Applications can provide explicit file URLs for app groups, shared containers,
or platform-specific storage policies:

```swift
let location = try SwordModuleLocation(
    modulesDirectory: modulesURL,
    installerDirectory: installerURL
)
```

SwordKit validates local file URLs but does not choose entitlements or create an
app group.

## Plan for platform storage behavior

- Keep durable iOS, iPadOS, macOS, and visionOS modules in Application Support.
- Treat tvOS content as restorable because the system may purge local data.
- Keep watchOS module sets compact and prefer content selected and delivered by
  the paired iPhone.
- Configure remote repositories explicitly; SwordKit never performs an implicit
  network download.

The native XCFramework contains the SWORD engine only. Bible modules, notes,
highlights, and other application data remain separate host-owned content.
