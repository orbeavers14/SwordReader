# SwordReader 0.3.0 — Mac Development Preview

SwordReader 0.3.0 makes the reading workspace substantially more flexible and
reliable while keeping the app native to Apple platforms.

## Highlights

- Open multiple reading tabs, restore them per window, and drag tabs to reorder
  them.
- Switch each tab independently between installed Bibles, books,
  dictionaries, and devotionals from its context menu.
- Place adjacent tabs side by side, resize the panes, and safely return them to
  tabs without the previously reported split-view crash.
- Use native reader preferences for red-letter text, font family, font size,
  spacing, and verse-number display, including a live appearance preview.
- Manage installed modules from Settings.
- Start directly in the reading window on macOS; Settings is available from the
  standard application menu without a redundant sidebar destination.
- Default the module catalog language to the system language when available,
  fall back to English, and remember the user's selection.
- Review Apple-provided MetricKit crash diagnostics locally before choosing to
  open a prefilled GitHub issue or share the full diagnostic. Nothing is
  uploaded automatically.
- Hover over icon-only controls on macOS to see concise native help text.

## Requirements and installation

- macOS 14 or newer.
- The downloadable Mac app is a universal Apple silicon and Intel build.
- This development preview is unsigned and unnotarized. After moving it to
  Applications, Control-click the app and choose **Open**. If macOS still blocks
  it, use **System Settings → Privacy & Security → Open Anyway**.

SwordReader 0.3.0 uses SwordKit 0.6.0. Bible and reference modules retain their
own publisher-provided licenses.

## Integrity

SHA-256: `c4c13c1b59bd24d0cc7f2ad001ed8b5855a35481f64b413469a75cf6bf6eea41`
