#import <Carbon/Carbon.h>
#import <XCTest/XCTest.h>

#import "SpectacleShortcut.h"
#import "SpectacleShortcutTranslations.h"

static SpectacleShortcut *shortcutForKeyBinding(NSString *keyBinding);

@interface SpectacleShortcutTranslationsTests : XCTestCase
@end

@implementation SpectacleShortcutTranslationsTests

- (void)testShouldTranslateAlphanumericKeyCodes
{
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_A), @"A");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_B), @"B");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_C), @"C");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_D), @"D");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_E), @"E");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_F), @"F");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_G), @"G");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_H), @"H");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_I), @"I");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_J), @"J");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_K), @"K");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_L), @"L");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_M), @"M");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_N), @"N");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_O), @"O");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_P), @"P");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_Q), @"Q");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_R), @"R");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_S), @"S");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_T), @"T");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_U), @"U");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_V), @"V");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_W), @"W");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_X), @"X");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_Y), @"Y");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_Z), @"Z");

  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_0), @"0");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_1), @"1");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_2), @"2");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_3), @"3");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_4), @"4");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_5), @"5");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_6), @"6");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_7), @"7");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_8), @"8");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_9), @"9");
}

- (void)testShouldTranslateKeyboardLayoutIndependentKeyCodes
{
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F1), @"F1");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F2), @"F2");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F3), @"F3");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F4), @"F4");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F5), @"F5");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F6), @"F6");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F7), @"F7");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F8), @"F8");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F9), @"F9");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F10), @"F10");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F11), @"F11");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F12), @"F12");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F13), @"F13");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F14), @"F14");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F15), @"F15");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F16), @"F16");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F17), @"F17");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F18), @"F18");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F19), @"F19");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_F20), @"F20");

  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_KeypadDecimal), @".");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_KeypadMultiply), @"*");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_KeypadPlus), @"+");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_KeypadClear), @"⌧");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_KeypadDivide), @"/");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_KeypadEnter), @"⌤");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_KeypadMinus), @"-");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_KeypadEquals), @"=");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_Keypad0), @"0");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_Keypad1), @"1");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_Keypad2), @"2");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_Keypad3), @"3");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_Keypad4), @"4");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_Keypad5), @"5");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_Keypad6), @"6");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_Keypad7), @"7");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_Keypad8), @"8");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ANSI_Keypad9), @"9");

  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_Return), @"↩");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_Tab), @"⇥");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_Space), @"␣");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_Delete), @"⌫");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_Escape), @"⎋");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_Command), @"⌘");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_Shift), @"⇧");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_CapsLock), @"⇪");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_Option), @"⌥");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_Control), @"⌃");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_RightShift), @"");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_RightOption), @"");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_RightControl), @"");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_Function), @"");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_VolumeUp), @"");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_VolumeDown), @"");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_Mute), @"");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_Help), @"");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_Home), @"↖");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_PageUp), @"⇞");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_ForwardDelete), @"⌦");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_End), @"↘");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_PageDown), @"⇟");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_LeftArrow), @"←");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_RightArrow), @"→");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_DownArrow), @"↓");
  XCTAssertEqualObjects(SpectacleTranslateKeyCode(kVK_UpArrow), @"↑");
}

- (void)testShouldTranslateEmptyModifiers
{
  XCTAssertEqualObjects(SpectacleTranslateModifiers(0), @"");
}

- (void)testShouldTranslateModifiers
{
  XCTAssertEqualObjects(SpectacleTranslateModifiers(NSControlKeyMask), @"⌃");
  XCTAssertEqualObjects(SpectacleTranslateModifiers(NSAlternateKeyMask), @"⌥");
  XCTAssertEqualObjects(SpectacleTranslateModifiers(NSShiftKeyMask), @"⇧");
  XCTAssertEqualObjects(SpectacleTranslateModifiers(NSCommandKeyMask), @"⌘");
}

- (void)testShouldTranslateShortcuts
{
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"option+command+c")), @"⌥⌘C");
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"option+command+f")), @"⌥⌘F");
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"option+command+left")), @"⌥⌘←");
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"option+command+right")), @"⌥⌘→");
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"option+command+up")), @"⌥⌘↑");
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"option+command+down")), @"⌥⌘↓");
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"control+command+left")), @"⌃⌘←");
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"control+shift+command+left")), @"⌃⇧⌘←");
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"control+command+right")), @"⌃⌘→");
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"control+shift+command+right")), @"⌃⇧⌘→");
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"control+option+command+right")), @"⌃⌥⌘→");
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"control+option+command+left")), @"⌃⌥⌘←");
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"control+option+right")), @"⌃⌥→");
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"control+option+left")), @"⌃⌥←");
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"control+option+shift+right")), @"⌃⌥⇧→");
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"control+option+shift+left")), @"⌃⌥⇧←");
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"option+command+z")), @"⌥⌘Z");
  XCTAssertEqualObjects(SpectacleTranslateShortcut(shortcutForKeyBinding(@"option+shift+command+z")), @"⌥⇧⌘Z");
}

- (void)testShouldConvertEmptyModifiers
{
  XCTAssertEqual(SpectacleConvertCocoaModifiersToCarbon(0), 0);
  XCTAssertEqual(SpectacleConvertCarbonModifiersToCocoa(0), 0);
}

- (void)testShouldConvertInvalidModifiers
{
  XCTAssertEqual(SpectacleConvertCocoaModifiersToCarbon(42), 0);
  XCTAssertEqual(SpectacleConvertCarbonModifiersToCocoa(42), 0);
}

- (void)testShouldConvertCocoaModifiersToCarbonModifiers
{
  XCTAssertEqual(SpectacleConvertCocoaModifiersToCarbon(NSControlKeyMask), controlKey);
  XCTAssertEqual(SpectacleConvertCocoaModifiersToCarbon(NSAlternateKeyMask), optionKey);
  XCTAssertEqual(SpectacleConvertCocoaModifiersToCarbon(NSShiftKeyMask), shiftKey);
  XCTAssertEqual(SpectacleConvertCocoaModifiersToCarbon(NSCommandKeyMask), cmdKey);
}

- (void)testShouldConvertCarbonModifiersToCocoaModifiers
{
  XCTAssertEqual(SpectacleConvertCarbonModifiersToCocoa(controlKey), NSControlKeyMask);
  XCTAssertEqual(SpectacleConvertCarbonModifiersToCocoa(optionKey), NSAlternateKeyMask);
  XCTAssertEqual(SpectacleConvertCarbonModifiersToCocoa(shiftKey), NSShiftKeyMask);
  XCTAssertEqual(SpectacleConvertCarbonModifiersToCocoa(cmdKey), NSCommandKeyMask);
}

- (void)testShouldConvertModifiersToCarbonModifiersIfNecessary
{
  XCTAssertEqual(SpectacleConvertModifiersToCarbonIfNecessary(controlKey), controlKey);
  XCTAssertEqual(SpectacleConvertModifiersToCarbonIfNecessary(optionKey), optionKey);
  XCTAssertEqual(SpectacleConvertModifiersToCarbonIfNecessary(shiftKey), shiftKey);
  XCTAssertEqual(SpectacleConvertModifiersToCarbonIfNecessary(cmdKey), cmdKey);
  XCTAssertEqual(SpectacleConvertModifiersToCarbonIfNecessary(NSControlKeyMask), controlKey);
  XCTAssertEqual(SpectacleConvertModifiersToCarbonIfNecessary(NSAlternateKeyMask), optionKey);
  XCTAssertEqual(SpectacleConvertModifiersToCarbonIfNecessary(NSShiftKeyMask), shiftKey);
  XCTAssertEqual(SpectacleConvertModifiersToCarbonIfNecessary(NSCommandKeyMask), cmdKey);
}

- (void)testShouldConvertModifiersToCocoaModifiersIfNecessary
{
  XCTAssertEqual(SpectacleConvertModifiersToCocoaIfNecessary(NSControlKeyMask), NSControlKeyMask);
  XCTAssertEqual(SpectacleConvertModifiersToCocoaIfNecessary(NSAlternateKeyMask), NSAlternateKeyMask);
  XCTAssertEqual(SpectacleConvertModifiersToCocoaIfNecessary(NSShiftKeyMask), NSShiftKeyMask);
  XCTAssertEqual(SpectacleConvertModifiersToCocoaIfNecessary(NSCommandKeyMask), NSCommandKeyMask);
  XCTAssertEqual(SpectacleConvertModifiersToCocoaIfNecessary(controlKey), NSControlKeyMask);
  XCTAssertEqual(SpectacleConvertModifiersToCocoaIfNecessary(optionKey), NSAlternateKeyMask);
  XCTAssertEqual(SpectacleConvertModifiersToCocoaIfNecessary(shiftKey), NSShiftKeyMask);
  XCTAssertEqual(SpectacleConvertModifiersToCocoaIfNecessary(cmdKey), NSCommandKeyMask);
}

@end

static SpectacleShortcut *shortcutForKeyBinding(NSString *keyBinding)
{
  return [[SpectacleShortcut alloc] initWithShortcutName:nil shortcutKeyBinding:keyBinding];
}
