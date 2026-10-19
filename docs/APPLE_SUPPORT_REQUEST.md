# Apple support request — draft, not sent

Suggested destination: [Apple code-level support](https://developer.apple.com/contact/request/code-level-support/). Use the developer account/team that would publish the app. Do not include passwords, signing keys, or other credentials.

## Subject

Supported Mac App Store architecture for cross-application window positioning using AXUIElement

## Message

Hello Apple Developer Support,

I am evaluating a new Mac App Store submission for a maintained fork of the MIT-licensed Spectacle window manager. Mac App Store distribution is a requirement for this project. Before implementing the distribution configuration, I would like to confirm whether there is a supported way to retain its core window-management functionality.

The app is a menu-bar utility. In response to a user-selected global shortcut or menu action, it moves or resizes the frontmost application's window. The relevant calls are:

1. `AXUIElementCreateApplication` to access the frontmost application.
2. `AXUIElementCopyAttributeValue` to obtain its focused window and current position/size.
3. `AXUIElementSetAttributeValue` with `kAXPositionAttribute` and `kAXSizeAttribute` to position and resize that window.

The current implementation checks Accessibility authorization using `AXIsProcessTrustedWithOptions`. It is not sandboxed. We understand that user-granted Accessibility permission does not override App Sandbox restrictions.

We have reviewed:

- App Review Guideline 2.4.5(i), requiring Mac App Store apps to be appropriately sandboxed: https://developer.apple.com/app-store/review/guidelines/#hardware-compatibility
- The section listing assistive use of Accessibility APIs as incompatible with App Sandbox: https://developer.apple.com/documentation/security/protecting-user-data-with-app-sandbox
- The DTS clarification that `com.apple.security.accessibility` is not a supported entitlement for enabling these APIs: https://developer.apple.com/forums/thread/799000

Our primary question is: **Is there a supported public API or application architecture that allows a newly submitted, sandboxed Mac App Store app to move and resize arbitrary other applications' windows following an explicit user action?** If so, could you point us to the relevant documentation and any required, officially supported capabilities?

If no such sandbox-compatible implementation exists, is there an official exception/request process available to a new app for this specific functionality, or should we consider this product behavior incompatible with a new Mac App Store submission? If this part belongs with App Review or a different support team, please direct or route the question accordingly.

We are seeking guidance on a supported implementation, not private APIs, undocumented entitlements, or a bypass of App Store validation. We have not submitted this fork to App Store Connect and have not received a rejection. We have not yet run a sandboxed reproduction, so we are not reporting a specific sandbox error as an observed result.

Technical context:

- Objective-C/AppKit application using public Accessibility APIs.
- Universal `arm64` / `x86_64` build; deployment target macOS 12.
- Local build and native ARM64 startup verified with Xcode 27.0 on macOS 27.0.1.
- Automated tests pass locally and in ARM/Intel GitHub CI; manual window-control verification for the new build is still pending Accessibility authorization.
- Source: https://github.com/MSetnik/spectacle-v2/tree/ce281dcfe7689863fdbed2a1e23e9265294d297b
- Relevant implementation: `Spectacle/Sources/SpectacleAccessibilityElement.m`.

Thank you for clarifying the supported path before we proceed with submission preparation.

## Tracking

- Status: prepared; not sent.
- Case/reference: none.
- Apple response: none.
