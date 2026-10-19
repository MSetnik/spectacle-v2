# Shortcuts backend

The `Spectacle Store` scheme selects the `Store` configuration: App Sandbox, native ARM64/Intel, macOS 13+, and the provisional fork identifier `io.github.msetnik.Spectacle`. The existing `Spectacle` scheme preserves direct Accessibility operation and macOS 12 support. The Store binary excludes the legacy AX mover and uses `SMAppService` for user-controlled launch at login.

## Companion workflow

The complete unsigned source is [SpectacleWindowBridge.plist](../Shortcuts/SpectacleWindowBridge.plist). Its [generator](../scripts/generate-window-shortcut.py) is deterministic and performs no network requests. Run `python3 scripts/verify-shortcut.py` to check the restricted action set, references, and guards.

The workflow uses only built-in actions: JSON dictionary reads, conditions, window filtering, size/position changes, and a JSON response. It contains no AppleScript, shell execution, screen capture, clipboard use, or network action. A probe only checks the protocol. A move requires exactly one visible window matching the captured app name and all four bounds. It retains that window object through resize, move, and final resize.

The app pins each command to a Window Server ID, process ID and launch date. Before dispatch it refreshes geometry and checks that the same window is still frontmost. The queue is bounded and drops old requests. Failures clear pending work. The app records observed post-operation geometry, including partial changes after errors, so undo does not rely on a requested but unapplied frame.

## Signing and local testing

macOS requires a signed Shortcut for import. **Signing in `anyone` mode uploads this workflow to Apple for validation.** This is separate from an Apple support inquiry. Do not perform the upload without the user's approval for this generated file. No files, window titles, or runtime requests belong in the workflow source sent for validation.

After approval, use:

```sh
python3 scripts/generate-window-shortcut.py --binary \
  --output 'build/Shortcuts/Spectacle Window Bridge.shortcut'
shortcuts sign --mode anyone \
  --input 'build/Shortcuts/Spectacle Window Bridge.shortcut' \
  --output 'Spectacle/Resources/Shortcuts/Spectacle Window Bridge.shortcut'
./scripts/build-store.sh
```

The build command never signs/uploads a Shortcut. It refuses to package an application without the signed companion, verifies both CPU architectures, checks the sandbox and scripting entitlements, and rejects a binary that still imports cross-app AX APIs. Store signing/provisioning is still needed for submission; local builds are ad-hoc signed.

For source validation without a signed companion, use `./scripts/build-store.sh --check-only`. This builds and verifies the sandboxed executable but deliberately creates no distributable archive. CI runs this check on both native ARM and Intel runners.

Launch the Store build, select **Add Shortcut**, then **Verify Connection**. Keep the companion name unchanged. Approve the relevant macOS Automation and Shortcuts window-control prompts as the user. A real move must then be tested; a successful probe alone does not prove window permissions or movement.

## Validation and remaining checks

Unit tests exercise geometry, response validation, command serialization, focus changes, history, and failure handling with an injected transport. They do not invoke Shortcuts or grant permissions. Manual validation must cover real window movement, cycling, undo/redo, permission refusal/revocation, missing/renamed helpers, cold/warm latency, multiple displays, fullscreen/Spaces, and minimum window sizes.

Shortcuts serializes actions using an Apple-maintained file format. The generated workflow must be inspected after import and exercised on each supported macOS version before release. App-name plus geometry matching deliberately rejects ambiguous identical windows. No AX role information is available in the Store backend; dialogs and unusual window types need particular attention during manual QA.

The Store identity has a separate sandbox container. Existing direct-edition settings are not silently read from outside it. Store branding, a user-driven settings import, privacy disclosures, developer-team provisioning, and App Store Connect submission remain separate release tasks.

## Current status (2026-10-19)

The backend and unsigned companion are implemented. All 116 local XCTest cases pass on ARM64. Both direct and sandboxed configurations build for `arm64` and `x86_64`. The Store signature contains App Sandbox and the Shortcuts scripting target, without `get-task-allow` or temporary exceptions. Its executable has no imports of `AXUIElement`, `AXIsProcessTrusted`, or `LSSharedFileList`.

The Store app's onboarding and preferences were opened locally. Visual inspection exposed an upstream shortcut-recorder drawing bug with modern AppKit; drawing now uses and clips to the control's bounds. The corrected preferences display was verified in the running Store app.

The user explicitly approved `shortcuts sign --mode anyone` for the generated companion on 2026-10-19. The XML `.plist` input was rejected as an incorrect format. Converting to binary `.shortcut` passed that local format check, but three signing attempts failed with `NSURLErrorDomain` codes **504, 502, and 502**. No signed companion was produced or imported. These are observed failures of the signing request, not proof of a general Apple outage or a rejection by App Review. No Apple support inquiry was sent.

Signing/import and end-to-end movement are therefore still blocked on obtaining the signed companion. No Automation/window-control permission was granted by the agent. Retry the documented signing command when the service is reachable, then perform the manual checks above. Do not describe this edition as ready for publication until real-window checks are recorded here.
