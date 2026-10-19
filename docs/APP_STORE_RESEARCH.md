# How other Mac App Store window managers work

Investigated on 2026-10-19 using primary public sources, snApp source inspection, the installed macOS scripting dictionary, and this fork's source. No Apple inquiry, app purchase, third-party app execution, or Shortcut installation was performed.

## Finding

Two precedents exist: older apps retained under historical sandbox exemptions, and newer sandboxed apps that delegate window operations to Apple Shortcuts. The second is a concrete candidate for this fork. The earlier categorical assessment that this product cannot reach the Store was too broad; it applies to the current direct-Accessibility architecture.

This research informed the [implemented Spectacle backend](SHORTCUTS_BACKEND.md). It is not a guarantee of App Review approval or of runtime parity; the implementation document records the outstanding live tests.

## Concrete examples

| App | Evidence | Relevance |
| --- | --- | --- |
| Moom Classic / Moom 4 | The [developer's FAQ](https://manytricks.com/osticket/kb/faq.php?id=137) explains that the older Store app retains its historical exemption, while Moom 4 is distributed directly because its Accessibility operations cannot run in the sandbox. | An old listing does not supply an exemption for a new fork. |
| snApp | Its [Store listing](https://apps.apple.com/us/app/window-management-snapp/id6449620109?mt=12) dates version 1.0 to May 2023 and identifies the companion Snap Shortcut. The [public repository](https://github.com/OmChachad/snApp) contains sandbox entitlements and ScriptingBridge invocation code. | Strongest inspectable implementation reference. Inspected commit: `91b2aca88312349647c73a1a6b3d45ee55713cc8`. |
| 941 Tiles | Its [Store listing](https://apps.apple.com/us/app/941-tiles/id6758425339?mt=12) explicitly describes sandboxing and Shortcuts-based movement. Version 1.3 advertises keyboard snapping, display transfers, and undo. Its [author describes the implementation](https://blakecrosley.com/blog/window-manager-mac-app-store-sandbox). | A second recent precedent with features closer to Spectacle. Feature and performance claims were not independently tested. |

Align also has a [Store listing](https://apps.apple.com/us/app/align-organize-app-windows/id6480428845?mt=12), and the 941 Tiles author names it as a Shortcuts precedent. We did not inspect Align's code or installed binary; the recommendation does not depend on that assertion.

## What snApp actually does

The inspected [entitlements file](https://github.com/OmChachad/snApp/blob/91b2aca88312349647c73a1a6b3d45ee55713cc8/snApp/snApp.entitlements) enables App Sandbox and Apple Events, with a specific scripting target:

```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.automation.apple-events</key>
<true/>
<key>com.apple.security.scripting-targets</key>
<dict>
    <key>com.apple.shortcuts.events</key>
    <array>
        <string>com.apple.shortcuts.run</string>
    </array>
</dict>
```

Its [ShortcutsHandler.swift](https://github.com/OmChachad/snApp/blob/91b2aca88312349647c73a1a6b3d45ee55713cc8/snApp/Helpers/ShortcutsHandler.swift) connects to `com.apple.shortcuts.events`, locates the user's `Snap` Shortcut, and passes the chosen layout to `run(withInput:)` on a background queue. Its onboarding offers installation of the companion Shortcut. The Xcode project supplies `NSAppleEventsUsageDescription`.

This does not grant the sandboxed app direct AX access. It lets the app ask Shortcuts to perform an operation through Shortcuts' own actions and permissions. The inspected source does not prove that the distributed binary is identical to that commit.

The reference code has limitations we should not copy: shell-based installation checks, no useful propagation of execution errors, and local version tracking that updates when an installation URL is opened. Our implementation should verify installation and protocol compatibility, expose failures, and serialize actions.

## Apple's documented interface

Apple's [WWDC21: Meet Shortcuts for macOS](https://developer.apple.com/videos/play/wwdc2021/10232/?time=1549) demonstrates ScriptingBridge for Swift and Objective-C, and explicitly identifies `com.apple.security.scripting-targets` with `com.apple.shortcuts.run` for sandboxed callers. The session also discusses window actions and distributing companion Shortcuts from an app.

Apple's [entitlement reference](https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/EntitlementKeyReference/Chapters/EnablingAppSandbox.html) explains targeted scripting access. Local inspection of `/System/Applications/Shortcuts.app/Contents/Resources/Shortcuts.sdef` on macOS 27.0.1 confirmed the `com.apple.shortcuts.run` access group on the run command and shortcut enumeration. The command accepts input and returns a result; its description identifies Shortcuts Events for background execution.

Prefer this documented access group. The 941 Tiles article shows a temporary Apple Events exception, but snApp and Apple's interface provide a narrower starting point without that exception. No special Apple support request is needed to experiment with it. Ordinary App Review and user-granted permissions still apply.

## Proposed Spectacle architecture

```text
Menu item / global keyboard shortcut
  -> Store action controller
  -> target-window and frame calculation
  -> ScriptingBridge: Shortcuts Events
  -> user-installed companion Shortcut
  -> Find Windows / Resize Window / Move Window
  -> completion and updated history
```

Use a separate Store build configuration with explicit backend selection. Preserve the existing Apple Silicon work. Share menu commands and geometry logic where practical; avoid choosing the backend only by inspecting an environment variable.

This requires more than replacing one AX setter:

| Existing component | Necessary adaptation |
| --- | --- |
| `SpectacleAppDelegate` | Store commands must not obtain `frontmostWindowElement` or gate startup on AX trust. Introduce Shortcuts setup and permission/error states. |
| `SpectacleWindowPositionCalculator` / JavaScript geometry | Reuse layout calculations after defining a stable frame and coordinate contract. |
| `SpectacleScreenDetector` | Accept a window snapshot/frame without requiring `SpectacleAccessibilityElement`. |
| `SpectacleWindowMover` | The current interface accepts an AX element and returns `void`. A Store interface needs target identity, asynchronous completion, and an explicit error/result. |
| `SpectacleHistoryItem` / position manager | History retains AX elements and records a target before movement completes. Store history must use a revalidated identity and record successful results. |
| Shortcut registration | Retain global command behavior where supported; test it in the actual sandboxed build, including fast repeated actions. |

For the prototype, prefer a minimal command payload and standard Shortcuts window actions. For full parity, investigate a versioned frame payload and returning actual applied bounds. The 941 Tiles author describes JSON frame payloads and window ordering; ordering is a hypothesis to test, not a stable window identity guarantee.

## Prototype acceptance criteria

1. Confirm sandbox entitlements on the built app. Exercise the Store backend with no direct cross-app AX calls or fallback to the existing mover.
2. Let the user install a companion Shortcut and approve system prompts. Verify missing, renamed, incompatible, and deleted Shortcuts; denied/revoked permissions; and execution errors/timeouts.
3. Move the intended frontmost window to left half, right half, and maximize. Test Finder, Safari, Terminal, and an Electron app, including multiple windows of one app and focus changes during execution.
4. Measure cold and warm end-to-end latency. Test repeated keyboard commands and ensure delayed work cannot move a newly focused, unintended window. Do not copy a competitor's timing as our own result.
5. Verify multiple displays, negative screen origins, scaling, Dock/menu-bar exclusions, minimum window sizes, Spaces, fullscreen/minimized windows, and dialogs. Document unsupported cases precisely.
6. Add center, quarters, thirds and cycling, resize, display transfer, and undo/redo with reliable identity and completion handling. Do not claim feature parity before testing it.

The one-time companion Shortcut setup is a visible product requirement. Ongoing dependency on Shortcuts, possible additional latency, and macOS changes are the principal tradeoffs. snApp's March 2025 release notes mention a Shortcut update fixing selection of the wrong app, making focus correctness a concrete test priority.

The current fork targets macOS 12. Shortcuts debuted there, but that does not prove our complete workflow works on every supported version. snApp currently lists macOS 13+, and 941 Tiles macOS 26+. Determine this fork's minimum version by testing its own workflow.

## Delivery status

Research and the revised plan are complete. The sandboxed Spectacle backend and unsigned companion source are implemented, with 120 passing local tests and universal builds. Local native Shortcuts actions moved and resized an isolated test window; they exposed a sequencing issue addressed by protocol 2 and settled-frame checks. Apple validation returned 500/502/504 errors. Generated-companion import, full integration, latency measurements, and remaining manual acceptance tests are outstanding. See [implementation status](SHORTCUTS_BACKEND.md) and [readiness](APP_STORE_READINESS.md).

After the prototype, complete Store identity, signing/provisioning, settings migration, login-item modernization, metadata, privacy disclosures, credits, and review instructions. Contacting Apple support is not an outstanding task.
