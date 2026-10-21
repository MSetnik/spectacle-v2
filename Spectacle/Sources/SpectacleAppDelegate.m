#import "SpectacleAppDelegate.h"

#import "SpectacleDefaultShortcutHelpers.h"
#import "SpectacleMigratingShortcutStorage.h"
#import "SpectaclePreferencesController.h"
#import "SpectacleScreenDetector.h"
#import "SpectacleShortcutJSONStorage.h"
#import "SpectacleShortcutManager.h"
#import "SpectacleShortcutTranslations.h"
#import "SpectacleShortcutUserDefaultsStorage.h"
#import "SpectacleUtilities.h"
#import "SpectacleWindowPositionCalculator.h"
#import "SpectacleWindowActionPerformer.h"
#include <math.h>
#if SPECTACLE_STORE
#import "SpectacleShortcutsWindowManager.h"
#else
#import "SpectacleWindowPositionManager.h"
#endif

#if !SPECTACLE_STORE
typedef NS_ENUM(NSUInteger, SpectacleSetupStep) {
  SpectacleSetupStepWelcome,
  SpectacleSetupStepPermission,
  SpectacleSetupStepTest
};

static NSString *const SpectacleSetupCompleteKey = @"SpectacleSetupComplete";

static NSTextField *SpectacleSetupLabel(NSRect frame, NSFont *font)
{
  NSTextField *label = [NSTextField labelWithString:@""];
  label.frame = frame;
  label.font = font;
  label.lineBreakMode = NSLineBreakByWordWrapping;
  label.maximumNumberOfLines = 0;
  return label;
}
#endif

@implementation SpectacleAppDelegate
{
  NSDictionary<NSString *, NSMenuItem *> *_shortcutMenuItems;
  NSStatusItem *_statusItem;
  id<SpectacleShortcutStorage> _shortcutStorage;
  SpectacleShortcutManager *_shortcutManager;
  id<SpectacleWindowActionPerformer> _windowPositionManager;
  SpectaclePreferencesController *_preferencesController;
  NSTimer *_disableShortcutsForAnHourTimer;
  NSSet<NSString *> *_blacklistedApplications;
  NSMutableSet<NSString *> *_disabledApplications;
  BOOL _shortcutsAreDisabledForAnHour;
#if !SPECTACLE_STORE
  NSWindow *_setupWindow;
  NSWindow *_setupTestWindow;
  NSTextField *_setupStepLabel;
  NSTextField *_setupTitleLabel;
  NSTextField *_setupBodyLabel;
  NSTextField *_setupStatusLabel;
  NSButton *_setupPrimaryButton;
  NSButton *_setupSecondaryButton;
  NSButton *_setupBackButton;
  SpectacleSetupStep _setupStep;
  BOOL _setupSnapVerified;
#endif
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
  // Unit tests exercise the window logic without registering global shortcuts or prompting for access.
  if (NSClassFromString(@"XCTestCase")) {
    return;
  }
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  NSNotificationCenter *workspaceNotificationCenter = [NSWorkspace sharedWorkspace].notificationCenter;
  [notificationCenter addObserver:self
                         selector:@selector(enableStatusItem)
                             name:@"SpectacleStatusItemEnabledNotification"
                           object:nil];
  [notificationCenter addObserver:self
                         selector:@selector(disableStatusItem)
                             name:@"SpectacleStatusItemDisabledNotification"
                           object:nil];
  [notificationCenter addObserver:self
                         selector:@selector(updateShortcutMenuItems)
                             name:@"SpectacleShortcutChangedNotification"
                           object:nil];
  [notificationCenter addObserver:self
                         selector:@selector(updateShortcutMenuItems)
                             name:@"SpectacleRestoreDefaultShortcutsNotification"
                           object:nil];
  [notificationCenter addObserver:self
                         selector:@selector(menuDidSendAction:)
                             name:NSMenuDidSendActionNotification
                           object:nil];
  [notificationCenter addObserver:self
                         selector:@selector(inputSourceSelectionDidChange)
                             name:NSTextInputContextKeyboardSelectionDidChangeNotification
                           object:nil];
  [workspaceNotificationCenter addObserver:self
                                  selector:@selector(applicationDidActivate:)
                                      name:NSWorkspaceDidActivateApplicationNotification
                                    object:nil];
  [workspaceNotificationCenter addObserver:self
                                  selector:@selector(applicationDidDeactivate:)
                                      name:NSWorkspaceDidDeactivateApplicationNotification
                                    object:nil];
  [SpectacleUtilities registerDefaultsForBundle:[NSBundle mainBundle]];
  _shortcutMenuItems = @{
                         @"MoveToCenter": _moveToCenterShortcutMenuItem,
                         @"MoveToFullscreen": _moveToFullscreenShortcutMenuItem,
                         @"MoveToLeftHalf": _moveToLeftShortcutMenuItem,
                         @"MoveToRightHalf": _moveToRightShortcutMenuItem,
                         @"MoveToTopHalf": _moveToTopShortcutMenuItem,
                         @"MoveToBottomHalf": _moveToBottomShortcutMenuItem,
                         @"MoveToUpperLeft": _moveToUpperLeftShortcutMenuItem,
                         @"MoveToLowerLeft": _moveToLowerLeftShortcutMenuItem,
                         @"MoveToUpperRight": _moveToUpperRightShortcutMenuItem,
                         @"MoveToLowerRight": _moveToLowerRightShortcutMenuItem,
                         @"MoveToNextDisplay": _moveToNextDisplayShortcutMenuItem,
                         @"MoveToPreviousDisplay": _moveToPreviousDisplayShortcutMenuItem,
                         @"MoveToNextThird": _moveToNextThirdShortcutMenuItem,
                         @"MoveToPreviousThird": _moveToPreviousThirdShortcutMenuItem,
                         @"MakeLarger": _makeLargerShortcutMenuItem,
                         @"MakeSmaller": _makeSmallerShortcutMenuItem,
                         @"UndoLastMove": _undoLastMoveShortcutMenuItem,
                         @"RedoLastMove": _redoLastMoveShortcutMenuItem,
                         };
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  _blacklistedApplications = [NSSet setWithArray:[userDefaults objectForKey:@"BlacklistedApplications"]];
  _disabledApplications = [NSMutableSet setWithArray:[userDefaults objectForKey:@"DisabledApplications"]];
  _shortcutStorage = [[SpectacleMigratingShortcutStorage alloc] initWithShortcutStorage:[SpectacleShortcutUserDefaultsStorage new]
                                                                   migrationDestination:[SpectacleShortcutJSONStorage new]];
  _shortcutManager = [[SpectacleShortcutManager alloc] initWithShortcutStorage:_shortcutStorage];
  SpectacleWindowPositionCalculator *windowPositionCalculator = [[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *errorMessage) {
    NSAlert *alert = [NSAlert new];
    alert.alertStyle = NSWarningAlertStyle;
    alert.messageText = @"Encountered an unexpected error";
    alert.informativeText = errorMessage;
    [alert runModal];
  }];
#if SPECTACLE_STORE
  _windowPositionManager = [[SpectacleShortcutsWindowManager alloc] initWithCalculator:windowPositionCalculator];
#else
  _windowPositionManager = [[SpectacleWindowPositionManager alloc] initWithScreenDetector:[SpectacleScreenDetector new]
                                                                 windowPositionCalculator:windowPositionCalculator
                                                                          sharedWorkspace:[NSWorkspace sharedWorkspace]];
#endif
  _preferencesController = [[SpectaclePreferencesController alloc] initWithShortcutManager:_shortcutManager
                                                                     windowPositionManager:_windowPositionManager
                                                                           shortcutStorage:_shortcutStorage];
  _shortcutsAreDisabledForAnHour = NO;
  [self manageShortcuts];
  [self disableShortcutsIfFrontmostApplicationIsBlacklistedOrDisabled];
  BOOL statusItemEnabled = [userDefaults boolForKey:@"StatusItemEnabled"];
  if (statusItemEnabled) {
    [self enableStatusItem];
  }
  [self updateShortcutMenuItems];
#if SPECTACLE_STORE
  for (NSMenuItem *item in _statusItemMenu.itemArray) {
    if (item.action == @selector(checkForUpdates:)) {
      item.title = @"Set Up Window Control…";
      item.tag = 0;
    }
  }
  if (![userDefaults boolForKey:@"ShortcutsBridgeVerified"]) {
    [(SpectacleShortcutsWindowManager *)_windowPositionManager showSetup];
  }
#else
  NSMenuItem *setupMenuItem = [[NSMenuItem alloc] initWithTitle:@"Set Up spectacle-matko…"
                                                    action:@selector(showSetupWindow:)
                                             keyEquivalent:@""];
  setupMenuItem.target = self;
  [_statusItemMenu insertItem:setupMenuItem atIndex:1];
  [_statusItemMenu itemAtIndex:0].title = @"About spectacle-matko";
  if (![userDefaults boolForKey:SpectacleSetupCompleteKey] || !AXIsProcessTrustedWithOptions(NULL)) {
    [self showSetupWindow:self];
  }
#endif
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)application hasVisibleWindows:(BOOL)visibleWindows
{
#if !SPECTACLE_STORE
  if (![NSUserDefaults.standardUserDefaults boolForKey:SpectacleSetupCompleteKey]
      || !AXIsProcessTrustedWithOptions(NULL)) {
    [self showSetupWindow:self];
    return YES;
  }
#endif
  [self showPreferencesWindow:self];

  return YES;
}

- (IBAction)checkForUpdates:(id)sender
{
#if SPECTACLE_STORE
  [(SpectacleShortcutsWindowManager *)_windowPositionManager showSetup];
#else
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/MSetnik/spectacle-v2/releases"]];
#endif
}

- (IBAction)showPreferencesWindow:(id)sender
{
  [_preferencesController showWindow:sender];
}

- (IBAction)moveFrontmostWindowToFullscreen:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionFullscreen];
}

- (IBAction)moveFrontmostWindowToCenter:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionCenter];
}

- (IBAction)moveFrontmostWindowToLeftHalf:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionLeftHalf];
}

- (IBAction)moveFrontmostWindowToRightHalf:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionRightHalf];
}

- (IBAction)moveFrontmostWindowToTopHalf:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionTopHalf];
}

- (IBAction)moveFrontmostWindowToBottomHalf:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionBottomHalf];
}

- (IBAction)moveFrontmostWindowToUpperLeft:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionUpperLeft];
}

- (IBAction)moveFrontmostWindowToLowerLeft:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionLowerLeft];
}

- (IBAction)moveFrontmostWindowToUpperRight:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionUpperRight];
}

- (IBAction)moveFrontmostWindowToLowerRight:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionLowerRight];
}

- (IBAction)moveFrontmostWindowToNextDisplay:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionNextDisplay];
}

- (IBAction)moveFrontmostWindowToPreviousDisplay:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionPreviousDisplay];
}

- (IBAction)moveFrontmostWindowToNextThird:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionNextThird];
}

- (IBAction)moveFrontmostWindowToPreviousThird:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionPreviousThird];
}

- (IBAction)makeFrontmostWindowLarger:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionLarger];
}

- (IBAction)makeFrontmostWindowSmaller:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionSmaller];
}

- (IBAction)undoLastWindowAction:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionUndo];
}

- (IBAction)redoLastWindowAction:(id)sender
{
  [_windowPositionManager performWindowAction:kSpectacleWindowActionRedo];
}

- (IBAction)disableOrEnableShortcutsForAnHour:(id)sender
{
  NSInteger newMenuItemState = NSMixedState;
  if (_shortcutsAreDisabledForAnHour) {
    _shortcutsAreDisabledForAnHour = NO;
    [_disableShortcutsForAnHourTimer invalidate];
    [self enableShortcutsIfPermitted];
    newMenuItemState = NSOffState;
  } else {
    _shortcutsAreDisabledForAnHour = YES;
    _disableShortcutsForAnHourTimer = [NSTimer scheduledTimerWithTimeInterval:3600
                                                                       target:self
                                                                     selector:@selector(disableOrEnableShortcutsForAnHour:)
                                                                     userInfo:nil
                                                                      repeats:NO];
    [_shortcutManager unregisterShortcuts];
    newMenuItemState = NSOnState;
  }
  self.disableShortcutsForAnHourMenuItem.state = newMenuItemState;
}

- (IBAction)disableOrEnableShortcutsForApplication:(id)sender
{
  NSRunningApplication *frontmostApplication = [NSWorkspace sharedWorkspace].frontmostApplication;
  if ([_disabledApplications containsObject:frontmostApplication.bundleIdentifier]) {
    [_disabledApplications removeObject:frontmostApplication.bundleIdentifier];
    [self enableShortcutsIfPermitted];
    self.disableShortcutsForApplicationMenuItem.state = NSOffState;
  } else {
    [_disabledApplications addObject:frontmostApplication.bundleIdentifier];
    [_shortcutManager unregisterShortcuts];
    self.disableShortcutsForApplicationMenuItem.state = NSOnState;
  }
  [NSUserDefaults.standardUserDefaults setObject:_disabledApplications.allObjects forKey:@"DisabledApplications"];
}

- (IBAction)openSystemPreferences:(id)sender
{
#if !SPECTACLE_STORE
  [self openSetupSystemSettings:sender];
#else
  NSURL *accessibilitySettingsURL = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"];
  [[NSWorkspace sharedWorkspace] openURL:accessibilitySettingsURL];
#endif
}

#if !SPECTACLE_STORE
- (void)createSetupWindow
{
  _setupWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 620, 390)
                                            styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
                                              backing:NSBackingStoreBuffered defer:NO];
  _setupWindow.title = @"Set up spectacle-matko";
  _setupWindow.releasedWhenClosed = NO;
  [_setupWindow center];
  NSView *content = _setupWindow.contentView;

  _setupStepLabel = SpectacleSetupLabel(NSMakeRect(28, 348, 564, 20), [NSFont systemFontOfSize:12 weight:NSFontWeightSemibold]);
  _setupStepLabel.textColor = NSColor.secondaryLabelColor;
  _setupTitleLabel = SpectacleSetupLabel(NSMakeRect(28, 290, 564, 48), [NSFont systemFontOfSize:25 weight:NSFontWeightSemibold]);
  _setupBodyLabel = SpectacleSetupLabel(NSMakeRect(28, 149, 564, 125), [NSFont systemFontOfSize:14]);
  _setupStatusLabel = SpectacleSetupLabel(NSMakeRect(28, 94, 564, 45), [NSFont systemFontOfSize:12]);
  _setupStatusLabel.textColor = NSColor.secondaryLabelColor;
  for (NSView *view in @[_setupStepLabel, _setupTitleLabel, _setupBodyLabel, _setupStatusLabel]) {
    [content addSubview:view];
  }

  _setupBackButton = [[NSButton alloc] initWithFrame:NSMakeRect(28, 26, 100, 32)];
  _setupBackButton.title = @"Back";
  _setupBackButton.target = self;
  _setupBackButton.action = @selector(setupBack:);
  [content addSubview:_setupBackButton];

  _setupSecondaryButton = [[NSButton alloc] initWithFrame:NSMakeRect(265, 26, 156, 32)];
  _setupSecondaryButton.target = self;
  _setupSecondaryButton.action = @selector(setupSecondary:);
  [content addSubview:_setupSecondaryButton];

  _setupPrimaryButton = [[NSButton alloc] initWithFrame:NSMakeRect(429, 26, 163, 32)];
  _setupPrimaryButton.keyEquivalent = @"\r";
  _setupPrimaryButton.target = self;
  _setupPrimaryButton.action = @selector(setupPrimary:);
  [content addSubview:_setupPrimaryButton];
}

- (void)refreshSetupWindow
{
  BOOL trusted = AXIsProcessTrustedWithOptions(NULL);
  _setupBackButton.hidden = _setupStep == SpectacleSetupStepWelcome;
  _setupSecondaryButton.enabled = YES;
  _setupStatusLabel.textColor = NSColor.secondaryLabelColor;

  switch (_setupStep) {
    case SpectacleSetupStepWelcome:
      _setupStepLabel.stringValue = @"STEP 1 OF 3  ·  WELCOME";
      _setupTitleLabel.stringValue = @"Welcome to spectacle-matko";
      _setupBodyLabel.stringValue = @"Move and resize windows with keyboard shortcuts. Setup takes two steps: allow window control in macOS, then try a snap on a test window.\n\nThe original Spectacle can stay installed. Quit it before testing because both apps use the same shortcuts.";
      _setupStatusLabel.stringValue = @"Your existing windows and documents will not be changed during setup.";
      _setupPrimaryButton.title = @"Continue";
      _setupSecondaryButton.title = @"Not now";
      break;
    case SpectacleSetupStepPermission:
      _setupStepLabel.stringValue = @"STEP 2 OF 3  ·  WINDOW CONTROL";
      _setupTitleLabel.stringValue = @"Allow window control";
      _setupBodyLabel.stringValue = @"Open System Settings. Under Privacy & Security → Device Control and Data Access, add spectacle-matko from Applications and turn it on. On older macOS versions this setting is called Accessibility.\n\nReturn here and click Check Access.";
      _setupStatusLabel.stringValue = trusted ? @"Access granted. Click Check Access to continue." : @"Waiting for macOS to grant access to spectacle-matko.";
      _setupPrimaryButton.title = @"Open Settings";
      _setupSecondaryButton.title = @"Check Access";
      break;
    case SpectacleSetupStepTest:
      _setupStepLabel.stringValue = @"STEP 3 OF 3  ·  TEST A SNAP";
      _setupTitleLabel.stringValue = @"Try window snapping";
      _setupBodyLabel.stringValue = @"Open the small test window and press Option + Command + Right Arrow once. It should move to the right half of the screen. The test window contains no documents.";
      _setupStatusLabel.stringValue = _setupSnapVerified ? @"Snap verified. spectacle-matko is ready." : @"Waiting for the test window to snap to the right half.";
      _setupPrimaryButton.title = @"Open Test Window";
      _setupSecondaryButton.title = @"Finish Setup";
      _setupSecondaryButton.enabled = _setupSnapVerified;
      break;
  }
}

- (IBAction)showSetupWindow:(id)sender
{
  if (!_setupWindow) [self createSetupWindow];
  _setupStep = SpectacleSetupStepWelcome;
  _setupSnapVerified = NO;
  [self refreshSetupWindow];
  [NSApp activateIgnoringOtherApps:YES];
  [_setupWindow makeKeyAndOrderFront:self];
}

- (IBAction)setupPrimary:(id)sender
{
  switch (_setupStep) {
    case SpectacleSetupStepWelcome:
      _setupStep = SpectacleSetupStepPermission;
      [self refreshSetupWindow];
      break;
    case SpectacleSetupStepPermission:
      [self openSetupSystemSettings:sender];
      break;
    case SpectacleSetupStepTest:
      [self openSetupTestWindow];
      break;
  }
}

- (IBAction)setupSecondary:(id)sender
{
  switch (_setupStep) {
    case SpectacleSetupStepWelcome:
      [_setupWindow close];
      break;
    case SpectacleSetupStepPermission:
      if (AXIsProcessTrustedWithOptions(NULL)) {
        _setupStep = SpectacleSetupStepTest;
        [self refreshSetupWindow];
      } else {
        _setupStatusLabel.stringValue = @"Access is still off. Add spectacle-matko in System Settings, then try again.";
      }
      break;
    case SpectacleSetupStepTest:
      if (_setupSnapVerified && AXIsProcessTrustedWithOptions(NULL)) {
        [NSUserDefaults.standardUserDefaults setBool:YES forKey:SpectacleSetupCompleteKey];
        [_setupWindow close];
      }
      break;
  }
}

- (IBAction)setupBack:(id)sender
{
  if (_setupStep > SpectacleSetupStepWelcome) {
    _setupStep--;
    [self refreshSetupWindow];
  }
}

- (IBAction)openSetupSystemSettings:(id)sender
{
  NSURL *url = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"];
  if (![[NSWorkspace sharedWorkspace] openURL:url]) {
    _setupStatusLabel.stringValue = @"System Settings did not open. Open it manually from the Apple menu.";
  } else {
    _setupStatusLabel.stringValue = @"After enabling spectacle-matko, return here and click Check Access.";
  }
}

- (void)openSetupTestWindow
{
  if (!_setupTestWindow) {
    _setupTestWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 440, 270)
                                               styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable
                                                 backing:NSBackingStoreBuffered defer:NO];
    _setupTestWindow.title = @"spectacle-matko · Test Window";
    _setupTestWindow.releasedWhenClosed = NO;
    _setupTestWindow.minSize = NSMakeSize(320, 220);
    NSTextField *instruction = SpectacleSetupLabel(NSMakeRect(28, 90, 384, 100), [NSFont systemFontOfSize:18 weight:NSFontWeightMedium]);
    instruction.stringValue = @"Press Option + Command + Right Arrow to snap this window to the right half.";
    [_setupTestWindow.contentView addSubview:instruction];
    [_setupTestWindow center];
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center addObserver:self selector:@selector(setupTestWindowChanged:)
                  name:NSWindowDidMoveNotification object:_setupTestWindow];
    [center addObserver:self selector:@selector(setupTestWindowChanged:)
                  name:NSWindowDidResizeNotification object:_setupTestWindow];
  }
  [NSApp activateIgnoringOtherApps:YES];
  [_setupTestWindow makeKeyAndOrderFront:self];
}

- (void)setupTestWindowChanged:(NSNotification *)notification
{
  if (_setupStep != SpectacleSetupStepTest || _setupSnapVerified) return;
  NSScreen *screen = _setupTestWindow.screen ?: NSScreen.mainScreen;
  NSRect visible = screen.visibleFrame;
  NSRect frame = _setupTestWindow.frame;
  CGFloat expectedLeft = NSMidX(visible);
  CGFloat expectedWidth = NSWidth(visible) / 2.0;
  if (fabs(NSMinX(frame) - expectedLeft) > 32 || fabs(NSWidth(frame) - expectedWidth) > 32
      || fabs(NSHeight(frame) - NSHeight(visible)) > 32) return;
  _setupSnapVerified = YES;
  [_setupTestWindow orderOut:self];
  [self refreshSetupWindow];
  [NSApp activateIgnoringOtherApps:YES];
  [_setupWindow makeKeyAndOrderFront:self];
}
#else
- (IBAction)showSetupWindow:(id)sender
{
  [(SpectacleShortcutsWindowManager *)_windowPositionManager showSetup];
}
#endif

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)manageShortcuts
{
  SpectacleShortcutAction action = ^(SpectacleShortcut *shortcut) {
    [self->_windowPositionManager performWindowAction:shortcut.windowAction];
  };
  NSArray<SpectacleShortcut *> *shortcuts = [_shortcutStorage loadShortcutsWithAction:action];
  if (shortcuts.count != 0) {
    [_shortcutManager manageShortcuts:shortcuts];
  } else {
    [_shortcutManager manageShortcuts:SpectacleDefaultShortcutsWithAction(action)];
  }
}

- (void)enableStatusItem
{
  _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  NSImage *statusImage = [NSBundle.mainBundle imageForResource:@"Spectacle Status Item"];
  [statusImage setTemplate:YES];
  _statusItem.highlightMode = YES;
  _statusItem.image = statusImage;
  _statusItem.menu = _statusItemMenu;
  NSString *appName = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"] ?: @"Spectacle";
  _statusItem.toolTip = [appName stringByAppendingFormat:@" %@", SpectacleUtilities.applicationVersion];
}

- (void)disableStatusItem
{
  [NSStatusBar.systemStatusBar removeStatusItem:_statusItem];
}

- (void)updateShortcutMenuItems
{
  for (NSString *shortcutName in _shortcutMenuItems.allKeys) {
    NSMenuItem *shortcutMenuItem = _shortcutMenuItems[shortcutName];
    SpectacleShortcut *shortcut = [_shortcutManager shortcutForShortcutName:shortcutName];
    if (shortcut) {
      shortcutMenuItem.keyEquivalent = [SpectacleTranslateKeyCode(shortcut.shortcutKeyCode) lowercaseString];
      shortcutMenuItem.keyEquivalentModifierMask = SpectacleConvertModifiersToCocoaIfNecessary(shortcut.shortcutModifiers);
    } else {
      shortcutMenuItem.keyEquivalent = @"";
      shortcutMenuItem.keyEquivalentModifierMask = 0;
    }
  }
}

- (void)enableShortcutsIfPermitted
{
  NSRunningApplication *frontmostApplication = [NSWorkspace sharedWorkspace].frontmostApplication;
  // Do not enable shortcuts if they should remain disabled for an hour.
  if (_shortcutsAreDisabledForAnHour) {
    return;
  }
  // Do not enable shortcuts if the application is blacklisted or disabled.
  if ([_blacklistedApplications containsObject:frontmostApplication.bundleIdentifier]
      || [_disabledApplications containsObject:frontmostApplication.bundleIdentifier]) {
    return;
  }
  [_shortcutManager registerShortcuts];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"SpectacleShortcutChangedNotification" object:self];
}

- (void)disableShortcutsIfFrontmostApplicationIsBlacklistedOrDisabled
{
  NSRunningApplication *frontmostApplication = [NSWorkspace sharedWorkspace].frontmostApplication;
  // Do not disable shortcuts if the application is not blacklisted or disabled.
  if (![_blacklistedApplications containsObject:frontmostApplication.bundleIdentifier]
      && ![_disabledApplications containsObject:frontmostApplication.bundleIdentifier]) {
    return;
  }
  [_shortcutManager unregisterShortcuts];
}

- (void)applicationDidActivate:(NSNotification *)notification
{
  NSRunningApplication *application = notification.userInfo[NSWorkspaceApplicationKey];
  if ([_blacklistedApplications containsObject:application.bundleIdentifier]
      || [_disabledApplications containsObject:application.bundleIdentifier]) {
    [_shortcutManager unregisterShortcuts];
  }
}

- (void)applicationDidDeactivate:(NSNotification *)notification
{
  NSRunningApplication *application = notification.userInfo[NSWorkspaceApplicationKey];
  if ([_blacklistedApplications containsObject:application.bundleIdentifier]
      || [_disabledApplications containsObject:application.bundleIdentifier]) {
    [self enableShortcutsIfPermitted];
  }
}

- (void)menuWillOpen:(NSMenu *)menu
{
  NSRunningApplication *frontmostApplication = [NSWorkspace sharedWorkspace].frontmostApplication;
  self.disableShortcutsForApplicationMenuItem.hidden = NO;
  if ([_blacklistedApplications containsObject:frontmostApplication.bundleIdentifier]) {
    self.disableShortcutsForApplicationMenuItem.hidden = YES;
  } else {
    self.disableShortcutsForApplicationMenuItem.title =
      [NSString stringWithFormat:NSLocalizedString(@"MenuItemTitleDisableShortcutsForApplication", @"The menu item title that displays the application to disable shortcuts for"), frontmostApplication.localizedName];
  }
  if ([_disabledApplications containsObject:frontmostApplication.bundleIdentifier]) {
    self.disableShortcutsForApplicationMenuItem.state = NSOnState;
  } else {
    self.disableShortcutsForApplicationMenuItem.state = NSOffState;
  }
}

- (void)menuDidSendAction:(NSNotification *)notification
{
  NSMenuItem *menuItem = notification.userInfo[@"MenuItem"];
  if (menuItem.tag == -1) {
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  }
}

- (void)inputSourceSelectionDidChange
{
  [_preferencesController loadRegisteredShortcuts];
  [self updateShortcutMenuItems];
}

@end
