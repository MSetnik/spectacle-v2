# Shortcuts backend

The `Spectacle Store` scheme selects the `Store` configuration: App Sandbox, native ARM64/Intel, macOS 13+, and the provisional fork identifier `io.github.msetnik.Spectacle`. The existing `Spectacle` scheme preserves direct Accessibility operation and macOS 12 support. The Store binary excludes the legacy AX mover and uses `SMAppService` for user-controlled launch at login.

## Companion workflow

The complete unsigned source is [SpectacleWindowBridge.plist](../Shortcuts/SpectacleWindowBridge.plist). Its [generator](../scripts/generate-window-shortcut.py) is deterministic and performs no network requests. Run `python3 scripts/verify-shortcut.py` to check the restricted action set, references, and guards.

The workflow uses only built-in actions: JSON dictionary reads, conditions, window filtering, size/position changes, and a JSON response. It contains no AppleScript, shell execution, screen capture, clipboard use, or network action. A probe only checks the protocol. Protocol **2** accepts separate `resize` and `move` operations, each requiring exactly one window matching the captured app name and all four bounds. Each invocation performs only one geometry mutation. The generated filter intentionally uses the five predicates that Shortcuts preserves on import; Shortcuts silently discarded an additional `Is Visible` predicate during local UI inspection.

The app pins each command to a Window Server ID, process ID and launch date. Before dispatch it refreshes geometry and checks that the same window is still frontmost. Initial discovery skips tiny layer-zero overlays, which the local fixture puts ahead of its main window; refresh by known ID still accepts any valid size. After each operation it polls geometry every 50 ms and requires three unchanged samples. An unchanged frame gets 500 ms for a delayed start or refusal; a continually changing frame times out after two seconds. A bounded second resize/move pass handles size constraints on the source display. Already-applied stages are skipped. The next call uses fresh settled bounds, preventing a move from using a height that has not yet been applied. The queue is bounded and drops old requests. Failures clear pending work. The app records observed post-operation geometry, including partial changes after errors, so undo does not rely on a requested but unapplied frame.

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

## Current status (2026-10-21)

The backend and companion are implemented. All **121** local XCTest cases pass on ARM64, including regressions for delayed resize, refused dimensions, changing geometry, a disappearing window, and a tiny overlay ahead of the target. Both direct and sandboxed configurations build for `arm64` and `x86_64`. The Store signature contains App Sandbox and the Shortcuts scripting target, without `get-task-allow` or temporary exceptions. Its executable has no imports of `AXUIElement`, `AXIsProcessTrusted`, or `LSSharedFileList`. The earlier protocol-2 implementation's [ARM and Intel CI](https://github.com/MSetnik/spectacle-v2/actions/runs/39273815866) passed; CI has not yet run for these latest fixes.

The Store app's onboarding and preferences were opened locally. Visual inspection exposed an upstream shortcut-recorder drawing bug with modern AppKit; drawing now uses and clips to the control's bounds. The corrected preferences display was verified in the running Store app.

The user explicitly approved `shortcuts sign --mode anyone` for the generated companion on 2026-10-19. Earlier attempts failed with `NSURLErrorDomain` codes **504, 502, 500, and 502**. On 2026-10-21, signing the protocol-2 binary succeeded. The signed companion is bundled in the universal Store app and its local ZIP. This establishes a buildable testing artifact, not App Store provisioning or approval. No Apple support inquiry was sent.

During the earlier failures, the CLI log showed a completed CloudKit operation, successful TLS verification/handshake, then an HTTP 500 response after about 28 seconds. An independent GET of the public snApp record at `https://www.icloud.com/shortcuts/api/records/6e9ac882bad94858bb595e8bd8a28bc4` returned HTTP 502 with an `AppleHttpServer` error page; the iCloud home page returned 200. This was an observed failure on the iCloud Shortcuts API path, not evidence of its internal cause. A proposed upload of a separate one-action diagnostic payload was denied by automatic approval review and was not performed.

The user explicitly approved importing/running the signed companion and running Spectacle's **Verify Connection**. The corrected 42-action workflow imported into Shortcuts. Its protocol, operation, and unique-window conditions and five window predicates were inspected in the editor; earlier generated copies showed missing conditions and were renamed as diagnostics. The signed companion returned the expected JSON for `probe`. On the isolated fixture, CLI invocations of `resize` and `move` produced the requested frames, and a stale-frame request returned `target-changed` without moving it. The sandboxed Spectacle then completed **Verify Connection** through its Shortcuts scripting bridge. No additional OS permission prompt appeared.

Repeated imports left multiple shortcuts with the shipping name. Shortcuts CLI lookup by name became ambiguous, and Shortcuts Events' direct name lookup returned `-1728`. Enumerating exact name matches allowed a successful sandboxed probe with two matches during diagnosis. The final bridge now refuses to run when more than one copy has the shipping name, instead of selecting one arbitrarily. An attempt to remove a duplicate in the UI was rejected by automatic approval review, so the duplicates remain. This local library needs cleanup before release QA.

### Local real-window test

Build the isolated fixture with `./scripts/build-window-fixture.sh`; it creates `build/WindowFixture/Spectacle Window Test.app`. It contains no documents and displays only its own frame. Its geometry display is polled to avoid stale notification-time measurements. The fixture is development tooling, not part of either distributable app.

A manually created local **Spectacle Development Reference** workflow was used, restricted to `App Name is Spectacle Window Test`. It uses native Find Windows, Resize Window, and Move Window actions. This workflow is distinct from the generated companion and was not exported or uploaded.

| Check | Observation |
| --- | --- |
| Initial frame | `(180, 180, 640, 432)` in top-left coordinates. |
| First resize + move | Requested `(100, 120, 600, 400)` and observed exactly that frame. |
| Immediate consecutive geometry actions | Further runs exposed incorrect final Y coordinates and delayed/refused resize. Repeating the same request could then reach the expected frame. |
| Request below the configured minimum | A request for `200 × 100` retained the previous size; the following immediate move could produce Y=26. A successful Shortcut run alone is not evidence of correct geometry. |
| Controlled wait between resize and move | With a one-second Wait inserted between the native actions and Bring to Front disabled, a request for `(180, 180, 640, 432)` reached exactly that frame on the first run. This motivated separate protocol-2 operations and observed-frame settling in the app. The product uses polling, not this fixed one-second delay. |
| Global keyboard shortcut | Automated Option–Command–Left input has not produced a repeatable, attributable Spectacle action. One run changed the fixture to the right half while later runs did nothing or reported `target-changed`. Physical keyboard registration/focus behavior remains unverified. |

The generated protocol-2 companion is signed, bundled, imported, and exercised against the isolated fixture. **Spectacle → generated companion → window → history** is still not fully accepted: the app-to-companion probe passed, but a repeatable window action initiated by the sandboxed app has not been demonstrated after the overlay fix. Duplicate-name cleanup, keyboard/menu triggering, performance measurements, multiple displays, permission refusal/revocation, and supported macOS-version checks remain pending. Do not describe the separate CLI action tests or injected-transport tests as end-to-end acceptance of the shipping workflow.
