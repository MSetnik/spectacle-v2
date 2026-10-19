# Mac App Store readiness

Updated on 2026-10-19 for the `feat/shortcuts-store-backend` implementation, based on the native work in `ce281dc`.

## Decision

Mac App Store distribution is a user requirement. On 2026-10-19 the user explicitly declined contacting Apple and requested research into existing apps. No inquiry was sent. An Apple support response is not a prerequisite for further work.

Research found a concrete alternative: a sandboxed app invokes a user-installed Shortcut to move and resize windows. snApp provides inspectable source and a Store listing; 941 Tiles provides a second Store example. Apple documents the required scripting access. See [the evidence and implementation plan](APP_STORE_RESEARCH.md).

The sandboxed Shortcuts backend and companion source are now implemented. The current build is still not ready for submission: Apple's signing command returned network errors, so the companion has not been imported and real window control has not been verified. See the [implementation and exact validation status](SHORTCUTS_BACKEND.md).

## Primary blocker: cross-application window control

The direct edition's core behavior depends on Accessibility access to other applications:

- `Spectacle/Sources/SpectacleAccessibilityElement.m` creates an application accessibility element with `AXUIElementCreateApplication`.
- It reads the focused window, position, and size using `AXUIElementCopyAttributeValue`.
- It moves and resizes the window using `AXUIElementSetAttributeValue` with `kAXPositionAttribute` and `kAXSizeAttribute`.
- `Spectacle/Sources/SpectacleAppDelegate.m` checks `AXIsProcessTrustedWithOptions` and directs the user to Accessibility settings.

[App Review Guideline 2.4.5(i)](https://developer.apple.com/app-store/review/guidelines/#hardware-compatibility) requires Mac App Store apps to be sandboxed. Apple's [App Sandbox documentation](https://developer.apple.com/documentation/security/protecting-user-data-with-app-sandbox) explicitly lists assistive use of Accessibility APIs as incompatible with the sandbox.

Apple Developer Technical Support also explains that `com.apple.security.accessibility` is not a supported entitlement that grants this access. User approval in System Settings is distinct from App Sandbox restrictions. See [Determining if an entitlement is real](https://developer.apple.com/forums/thread/799000).

**Assessment:** the current direct-Accessibility implementation cannot simply be sandboxed and signed. However, this does not rule out the product category: delegating window operations to Shortcuts is a demonstrated alternative in other Store apps. Use the documented `com.apple.security.scripting-targets` access group for Shortcuts, rather than an imaginary Accessibility entitlement or a temporary exception copied from a blog.

This conclusion is based on documentation and source inspection. We have not submitted this app or received a rejection. The separate Store configuration builds and opens with the sandbox enabled; real window movement remains unverified. Other Store listings establish precedent, not approval of this fork or proof that all Spectacle features will behave identically.

## Current evidence

| Area | Status |
| --- | --- |
| Apple silicon | Release binary contains `arm64` and `x86_64`; the local Release process was observed running as ARM64 on macOS 27.0.1. |
| Automated tests | 116 local XCTest cases passed on ARM64, including 15 Shortcuts backend tests. The earlier native baseline's [ARM and Intel CI jobs](https://github.com/MSetnik/spectacle-v2/actions/runs/39259863547) passed; those results do not validate the new backend. CI now also builds and verifies the Store configuration. |
| Actual window control | Unit coverage is in place. The companion signing request failed with 504/502 errors; import and real-window tests are outstanding. |
| Signing | Ad-hoc signing only; no developer team or App Store provisioning is configured. |
| Sandbox | Enabled and verified in the Store signature, using the documented Shortcuts scripting group. The Store binary excludes direct AX movers and has no temporary exception or debug entitlement. |
| Bundle identity | Direct builds retain `com.divisiblebyzero.Spectacle`; Store builds use provisional `io.github.msetnik.Spectacle` with a separate settings container. Developer-team ownership/availability remains unchecked. |
| Updates | Store builds replace the GitHub update menu with window-control setup; Store updates will be delivered by the Store under Guideline 2.4.5(vii). |
| Launch at login | Store builds use `SMAppService` and require macOS 13+. Registration and approval behavior still need manual verification. Direct builds preserve the existing behavior. |
| Store assets and disclosures | No finalized Store identity, description, screenshots, privacy policy, support URL, or App Store Connect privacy responses. |
| Licensing | Preserve the existing MIT copyright and permission notice in the distributed product. The current app still uses the upstream name and artwork; establish a distinct, accurately represented fork identity and review Guideline 4.1. |

## Next step

Obtain the signed companion using the user's approved Apple validation command, import it, and test the implemented backend. Start with left/right half and maximize on the intended frontmost window, then test rapid keyboard commands, multiple windows and displays, denied/revoked permissions, and a missing Shortcut. Measure actual latency.

The [research document](APP_STORE_RESEARCH.md) records proposed entitlements, code boundaries, and verification criteria. No third-party app or Shortcut was installed or executed during that research.

The former [support request](APPLE_SUPPORT_REQUEST.md) is cancelled at the user's instruction.

## Work after the prototype

Window identity, asynchronous completion, queued commands, observed-frame history, and permission onboarding are integrated. After real-window validation, prepare the final Store identity and user-driven settings migration, signing and provisioning, login-item verification, in-app licensing credits, privacy disclosures, metadata, and final functional QA. Include the companion Shortcut and accurate setup instructions in review materials.

App Review approval remains outstanding. If testing exposes missing behavior, report the exact limitation before changing the feature scope. Direct distribution is not the selected path.
