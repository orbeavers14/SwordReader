# Managing the Module Lifecycle

Inspect, install, remove, and refresh SWORD modules without hiding storage or
network policy inside the framework.

## Separate catalogs from live libraries

``SwordModuleCatalog`` is an immutable description of modules available in a
local SWORD repository. ``SwordLibrary`` owns live modules opened from an
installed SWORD root. Reading a catalog does not load its modules for use:

```swift
let sourceCatalog = try SwordModuleCatalog(directory: sourceURL)
let installedLibrary = try SwordLibrary(location: location)
```

Use catalog entries to present installation choices. Use live modules for
reading, rendering, navigation, and search.

## Configure installation explicitly

Create one ``SwordModuleLocation`` and share it between the installer and
library:

```swift
let location = try SwordModuleLocation.applicationSupport()
let configuration = SwordInstallerConfiguration(location: location)
let installer = SwordModuleInstaller(configuration: configuration)
let library = try SwordLibrary(location: location)
```

Repository descriptions are values stored in
``SwordInstallerConfiguration/repositories``. SwordKit never contacts a remote
repository merely because it appears in configuration.

## Install from a local catalog

The current installer API copies a selected module from a local repository:

```swift
try installer.install(moduleNamed: "KJV", from: sourceCatalog)
library.refresh()
```

Installation creates the destination and installer-private directories when
needed. Refresh explicitly after mutation so the library publishes a new module
snapshot.

## Remove and refresh

Removal operates on the configured destination:

```swift
try installer.remove(moduleNamed: "KJV")
library.refresh()
```

Previously retrieved verses and other immutable values remain valid. Existing
live module objects retain their original manager; replace application references
with modules from the refreshed library.

## Own restoration policy in the app

SwordKit does not decide when content should be redownloaded. Applications should
record stable module names and repository information needed to restore content,
especially on tvOS and watchOS where storage constraints are more significant.
