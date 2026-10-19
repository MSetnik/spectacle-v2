# Mac App Store readiness

Reviewed on 2026-10-19 against commit `ce281dc`.

## Decision

Mac App Store distribution is a user requirement. Obtain clarification from Apple before changing the application's architecture or preparing a submission. The current build is not ready for Mac App Store submission.

## Primary blocker: cross-application window control

Spectacle's core behavior depends on Accessibility access to other applications:

- `Spectacle/Sources/SpectacleAccessibilityElement.m` creates an application accessibility element with `AXUIElementCreateApplication`.
- It reads the focused window, position, and size using `AXUIElementCopyAttributeValue`.
- It moves and resizes the window using `AXUIElementSetAttributeValue` with `kAXPositionAttribute` and `kAXSizeAttribute`.
- `Spectacle/Sources/SpectacleAppDelegate.m` checks `AXIsProcessTrustedWithOptions` and directs the user to Accessibility settings.

[App Review Guideline 2.4.5(i)](https://developer.apple.com/app-store/review/guidelines/#hardware-compatibility) requires Mac App Store apps to be sandboxed. Apple's [App Sandbox documentation](https://developer.apple.com/documentation/security/protecting-user-data-with-app-sandbox) explicitly lists assistive use of Accessibility APIs as incompatible with the sandbox.

Apple Developer Technical Support also explains that `com.apple.security.accessibility` is not a supported entitlement that grants this access. User approval in System Settings is distinct from App Sandbox restrictions. See [Determining if an entitlement is real](https://developer.apple.com/forums/thread/799000).

**Assessment:** the current implementation has no demonstrated, supported route to a new Mac App Store submission while retaining its core functionality. A signing certificate alone will not resolve this. Do not assume an exception exists or add an undocumented entitlement. Request a supported alternative or explicit guidance from Apple.

This conclusion is based on documentation and source inspection. We have not submitted this app, received a rejection, or run a sandboxed window-control reproduction. Existing App Store listings for other products do not establish eligibility for this new submission.

## Current evidence

| Area | Status |
| --- | --- |
| Apple silicon | Release binary contains `arm64` and `x86_64`; the local Release process was observed running as ARM64 on macOS 27.0.1. |
| Automated tests | 101 local XCTest cases passed on ARM64; [ARM and Intel CI jobs](https://github.com/MSetnik/spectacle-v2/actions/runs/39259863547) passed. |
| Actual window control | Manual verification with Accessibility permission is still outstanding for the new build. |
| Signing | Ad-hoc signing only; no developer team or App Store provisioning is configured. |
| Sandbox | Not enabled; enabling it without resolving cross-application window control would remove essential functionality. |
| Bundle identity | Uses the upstream `com.divisiblebyzero.Spectacle` identifier to preserve existing settings. Ownership/availability under the user's developer team has not been checked. |
| Updates | The menu opens this fork's GitHub releases; a future Store edition must use the Store for updates under Guideline 2.4.5(vii). |
| Launch at login | Uses deprecated `LSSharedFileList` APIs; modernize and verify user-consented behavior before release. |
| Store assets and disclosures | No finalized Store identity, description, screenshots, privacy policy, support URL, or App Store Connect privacy responses. |
| Licensing | Preserve the existing MIT copyright and permission notice in the distributed product. The current app still uses the upstream name and artwork; establish a distinct, accurately represented fork identity and review Guideline 4.1. |

## Next step

Use the prepared [Apple support request](APPLE_SUPPORT_REQUEST.md). Ask about the exact APIs and whether a supported architecture or official exception process exists for a **new** listing. This is a pre-submission feasibility question, not an appeal against an actual rejection.

The technical route is [Apple code-level support](https://developer.apple.com/contact/request/code-level-support/), which requires signing in and eligible program membership. If Apple routes distribution policy questions separately, use [Apple Developer Support](https://developer.apple.com/contact/). Do not send duplicate requests without cross-referencing the original case.

No support request has been sent as part of this document's preparation. Record the case number and substantive answer here once received, excluding credentials and private account details.

## Work after Apple's clarification

If Apple identifies an allowed path, first build a minimal proof of window movement and resizing under the required restrictions. Then prepare the Store-specific identity and settings migration, signing and provisioning, login-item behavior, in-app licensing credits, privacy disclosures, metadata, and final functional QA. Confirm distribution eligibility before investing in Store artwork or screenshots.

If Apple confirms there is no supported path, the user must decide whether to change the product's core functionality or reconsider the App Store requirement. Direct distribution is not the selected path.
