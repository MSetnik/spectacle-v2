#import <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "SpectacleShortcut.h"

@interface SpectacleShortcutTests : XCTestCase
@end

@implementation SpectacleShortcutTests

- (void)testShouldBeInitializedWithAKeyBinding
{
  SpectacleShortcut *shortcut = [[SpectacleShortcut alloc] initWithShortcutName:@"MoveToCenter"
                                                             shortcutKeyBinding:@"option+command+c"];
  XCTAssertEqual(shortcut.shortcutKeyCode, kVK_ANSI_C);
  XCTAssertEqual(shortcut.shortcutModifiers, optionKey | cmdKey);
}

- (void)testShouldBeCopiedWithANewShortcutAction
{
  SpectacleShortcut *shortcut = [[SpectacleShortcut alloc] initWithShortcutName:@"MoveToCenter"
                                                                shortcutKeyCode:kVK_ANSI_C
                                                              shortcutModifiers:NSAlternateKeyMask | NSCommandKeyMask];
  XCTAssertFalse(shortcut.shortcutAction);
  XCTAssertTrue([shortcut copyWithShortcutAction:^(SpectacleShortcut *shortcut) {}].shortcutAction);
}

- (void)testShouldTriggerShortcutActions
{
  __block BOOL shortcutActionTriggered = NO;
  SpectacleShortcut *shortcut = [[SpectacleShortcut alloc] initWithShortcutName:@"MoveToCenter"
                                                                shortcutKeyCode:kVK_ANSI_C
                                                              shortcutModifiers:NSAlternateKeyMask | NSCommandKeyMask
                                                                 shortcutAction:^(SpectacleShortcut *shortcut) {
                                                                   shortcutActionTriggered = YES;
                                                                 }];
  [shortcut triggerShortcutAction];
  XCTAssertTrue(shortcutActionTriggered);
}

- (void)testShouldDetermineIfTheShortcutIsCleared
{
  XCTAssertTrue([[[SpectacleShortcut alloc] initWithShortcutName:nil shortcutKeyBinding:nil] isClearedShortcut]);
  XCTAssertTrue([[[SpectacleShortcut alloc] initWithShortcutName:nil shortcutKeyBinding:@""] isClearedShortcut]);
  XCTAssertTrue([[[SpectacleShortcut alloc] initWithShortcutName:nil
                                          shortcutKeyCode:-1
                                        shortcutModifiers:0] isClearedShortcut]);
  XCTAssertTrue([[[SpectacleShortcut alloc] initWithShortcutName:@"MoveToCenter"
                                          shortcutKeyCode:-1
                                        shortcutModifiers:0] isClearedShortcut]);
}

- (void)testShouldProvideADisplayString
{
  XCTAssertEqualObjects([[[SpectacleShortcut alloc] initWithShortcutName:@"MoveToCenter"
                                          shortcutKeyCode:kVK_ANSI_C
                                        shortcutModifiers:NSAlternateKeyMask | NSCommandKeyMask] displayString], @"⌥⌘C");
}

- (void)testShouldProvideAKeyBinding
{
  SpectacleShortcut *shortcut = [[SpectacleShortcut alloc] initWithShortcutName:@"MoveToCenter"
                                                             shortcutKeyBinding:@"alt+cmd+c"];
  XCTAssertEqualObjects(shortcut.shortcutKeyBinding, @"alt+cmd+c");
}

- (void)testShouldSupportEquality
{
  SpectacleShortcut *shortcut1 = [[SpectacleShortcut alloc] initWithShortcutName:@"MoveToCenter"
                                                                 shortcutKeyCode:kVK_ANSI_C
                                                               shortcutModifiers:NSAlternateKeyMask | NSCommandKeyMask];
  SpectacleShortcut *shortcut2 = [[SpectacleShortcut alloc] initWithShortcutName:@"MoveToCenter"
                                                                 shortcutKeyCode:kVK_ANSI_C
                                                               shortcutModifiers:NSAlternateKeyMask | NSCommandKeyMask];
  SpectacleShortcut *shortcut3 = [[SpectacleShortcut alloc] initWithShortcutName:nil
                                                                 shortcutKeyCode:kVK_ANSI_C
                                                               shortcutModifiers:NSAlternateKeyMask | NSCommandKeyMask];
  XCTAssertEqualObjects(shortcut1, shortcut2);
  XCTAssertEqualObjects(shortcut1, shortcut3);
  XCTAssertNotEqualObjects(shortcut1, [[SpectacleShortcut alloc] initWithShortcutName:nil
                                                                shortcutKeyCode:-1
                                                              shortcutModifiers:0]);
}

- (void)testMatchesExactModifiersForShortcutConflictDetection
{
  SpectacleShortcut *shortcut = [[SpectacleShortcut alloc] initWithShortcutName:@"MoveToCenter"
                                                                shortcutKeyCode:kVK_ANSI_C
                                                              shortcutModifiers:NSAlternateKeyMask | NSCommandKeyMask];
  // A subset must not conflict: Option+C and Option+Command+C are distinct shortcuts.
  XCTAssertFalse([shortcut containsModifiers:NSAlternateKeyMask]);
  XCTAssertTrue([shortcut containsModifiers:NSAlternateKeyMask | NSCommandKeyMask]);
  XCTAssertTrue([shortcut containsModifiers:optionKey | cmdKey]);
  XCTAssertFalse([shortcut containsModifiers:NSControlKeyMask]);
}

@end
