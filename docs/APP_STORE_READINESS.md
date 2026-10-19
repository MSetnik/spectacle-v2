# Mac App Store readiness

Reviewed on 2026-10-19 against commit `ce281dc`.

## Decision

Mac App Store distribution is a user requirement. On 2026-10-19 the user explicitly declined contacting Apple and requested research into existing apps. No inquiry was sent. An Apple support response is not a prerequisite for further work.

Research found a concrete alternative: a sandboxed app invokes a user-installed Shortcut to move and resize windows. snApp provides inspectable source and a Store listing; 941 Tiles provides a second Store example. Apple documents the required scripting access. See [the evidence and implementation plan](APP_STORE_RESEARCH.md).

The current Spectacle build is still not ready for submission. The next step is a sandboxed Shortcuts proof of concept, followed by integration and functional verification.

## Primary blocker: cross-application window control

Spectacle's core behavior depends on Accessibility access to other applications:

- `Spectacle/Sources/SpectacleAccessibilityElement.m` creates an application accessibility element with `AXUIElementCreateApplication`.
- It reads the focused window, position, and size using `AXUIElementCopyAttributeValue`.
- It moves and resizes the window using `AXUIElementSetAttributeValue` with `kAXPositionAttribute` and `kAXSizeAttribute`.
- `Spectacle/Sources/SpectacleAppDelegate.m` checks `AXIsProcessTrustedWithOptions` and directs the user to Accessibility settings.

[App Review Guideline 2.4.5(i)](https://developer.apple.com/app-store/review/guidelines/#hardware-compatibility) requires Mac App Store apps to be sandboxed. Apple's [App Sandbox documentation](https://developer.apple.com/documentation/security/protecting-user-data-with-app-sandbox) explicitly lists assistive use of Accessibility APIs as incompatible with the sandbox.

Apple Developer Technical Support also explains that `com.apple.security.accessibility` is not a supported entitlement that grants this access. User approval in System Settings is distinct from App Sandbox restrictions. See [Determining if an entitlement is real](https://developer.apple.com/forums/thread/799000).

**Assessment:** the current direct-Accessibility implementation cannot simply be sandboxed and signed. However, this does not rule out the product category: delegating window operations to Shortcuts is a demonstrated alternative in other Store apps. Use the documented `com.apple.security.scripting-targets` access group for Shortcuts, rather than an imaginary Accessibility entitlement or a temporary exception copied from a blog.

This conclusion is based on documentation and source inspection. We have not submitted this app, received a rejection, or run a sandboxed window-control reproduction. Other Store listings establish precedent, not approval of this fork or proof that all Spectacle features will behave identically.

## Current evidence

| Area | Status |
| --- | --- |
| Apple silicon | Release binary contains `arm64` and `x86_64`; the local Release process was observed running as ARM64 on macOS 27.0.1. |
| Automated tests | 101 local XCTest cases passed on ARM64; [ARM and Intel CI jobs](https://github.com/MSetnik/spectacle-v2/actions/runs/39259863547) passed. |
| Actual window control | Manual verification with Accessibility permission is still outstanding for the new build. |
| Signing | Ad-hoc signing only; no developer team or App Store provisioning is configured. |
| Sandbox | Not enabled in Spectacle. A Shortcuts backend is supported by external examples and Apple documentation, but has not been implemented or tested in this fork. |
| Bundle identity | Uses the upstream `com.divisiblebyzero.Spectacle` identifier to preserve existing settings. Ownership/availability under the user's developer team has not been checked. |
| Updates | The menu opens this fork's GitHub releases; a future Store edition must use the Store for updates under Guideline 2.4.5(vii). |
| Launch at login | Uses deprecated `LSSharedFileList` APIs; modernize and verify user-consented behavior before release. |
| Store assets and disclosures | No finalized Store identity, description, screenshots, privacy policy, support URL, or App Store Connect privacy responses. |
| Licensing | Preserve the existing MIT copyright and permission notice in the distributed product. The current app still uses the upstream name and artwork; establish a distinct, accurately represented fork identity and review Guideline 4.1. |

## Next step

Build a separate sandboxed prototype using ScriptingBridge and a companion Shortcut. Start with left/right half and maximize on the intended frontmost window, then test rapid keyboard commands, multiple windows and displays, denied/revoked permissions, and a missing Shortcut. Measure latency before integrating the full action set.

The [research document](APP_STORE_RESEARCH.md) records proposed entitlements, code boundaries, and verification criteria. No third-party app or Shortcut was installed or executed during that research.

The former [support request](APPLE_SUPPORT_REQUEST.md) is cancelled at the user's instruction.

## Work after the prototype

If the sandboxed prototype works reliably, integrate a Store backend and adapt window identity, history, permission onboarding, and asynchronous completion. Then prepare the Store-specific identity and settings migration, signing and provisioning, login-item behavior, in-app licensing credits, privacy disclosures, metadata, and final functional QA. Include the companion Shortcut and accurate setup instructions in review materials.

App Review approval remains outstanding. If testing exposes missing behavior, report the exact limitation before changing the feature scope. Direct distribution is not the selected path.
