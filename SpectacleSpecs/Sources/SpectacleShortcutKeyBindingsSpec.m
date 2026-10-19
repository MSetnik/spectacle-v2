#import <Carbon/Carbon.h>
#import <XCTest/XCTest.h>

#import "SpectacleShortcut.h"
#import "SpectacleShortcutKeyBindings.h"

static SpectacleShortcut *shortcutForKeyBinding(NSString *keyBinding);

@interface SpectacleShortcutKeyBindingsTests : XCTestCase
@end

@implementation SpectacleShortcutKeyBindingsTests

- (void)testShouldConvertAnEmptyOrNilKeyBindingToNilModifiers
{
  XCTAssertNil(SpectacleConvertShortcutKeyBindingToModifiers(nil));
  XCTAssertNil(SpectacleConvertShortcutKeyBindingToModifiers(@""));
  XCTAssertNil(SpectacleConvertShortcutKeyBindingToModifiers(@" "));
}

- (void)testShouldConvertKeyBindingsToModifiers
{
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToModifiers(@"cmd+c"), @(cmdKey));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToModifiers(@"shift+cmd+c"), @(shiftKey |cmdKey));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToModifiers(@"alt+shift+cmd+c"), @(optionKey | shiftKey |cmdKey));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToModifiers(@"ctrl+alt+shift+cmd+c"), @(controlKey | optionKey | shiftKey | cmdKey));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToModifiers(@"command+c"), @(cmdKey));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToModifiers(@"shift+command+c"), @(shiftKey |cmdKey));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToModifiers(@"option+shift+command+c"), @(optionKey | shiftKey |cmdKey));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToModifiers(@"control+option+shift+command+c"), @(controlKey | optionKey | shiftKey | cmdKey));
}

- (void)testShouldConvertMixedCaseKeyBindingsToModifiers
{
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToModifiers(@"Cmd+C"), @(cmdKey));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToModifiers(@"Shift+Cmd+C"), @(shiftKey |cmdKey));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToModifiers(@"Alt+Shift+Cmd+C"), @(optionKey | shiftKey |cmdKey));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToModifiers(@"Ctrl+Alt+Shift+Cmd+C"), @(controlKey | optionKey | shiftKey | cmdKey));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToModifiers(@"COMMAND+C"), @(cmdKey));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToModifiers(@"SHIFT+COMMAND+C"), @(shiftKey |cmdKey));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToModifiers(@"OPTION+SHIFT+COMMAND+C"), @(optionKey | shiftKey |cmdKey));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToModifiers(@"CONTROL+OPTION+SHIFT+COMMAND+C"), @(controlKey | optionKey | shiftKey | cmdKey));
}

- (void)testShouldConvertKeyBindingsWithWhitespaceToModifiers
{
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToModifiers(@" alt  +   shift    +     cmd    +c"), @(optionKey | shiftKey |cmdKey));
}

- (void)testShouldConvertAnEmptyOrNilKeyBindingToNilKeyCodes
{
  XCTAssertNil(SpectacleConvertShortcutKeyBindingToKeyCode(nil));
  XCTAssertNil(SpectacleConvertShortcutKeyBindingToKeyCode(@""));
  XCTAssertNil(SpectacleConvertShortcutKeyBindingToKeyCode(@" "));
}

- (void)testShouldConvertLowercaseAlphabeticalKeyBindingsToKeyCodes
{
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"a"), @(kVK_ANSI_A));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"b"), @(kVK_ANSI_B));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"c"), @(kVK_ANSI_C));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"d"), @(kVK_ANSI_D));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"e"), @(kVK_ANSI_E));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f"), @(kVK_ANSI_F));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"g"), @(kVK_ANSI_G));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"h"), @(kVK_ANSI_H));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"i"), @(kVK_ANSI_I));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"j"), @(kVK_ANSI_J));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"k"), @(kVK_ANSI_K));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"l"), @(kVK_ANSI_L));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"m"), @(kVK_ANSI_M));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"n"), @(kVK_ANSI_N));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"o"), @(kVK_ANSI_O));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"p"), @(kVK_ANSI_P));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"q"), @(kVK_ANSI_Q));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"r"), @(kVK_ANSI_R));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"s"), @(kVK_ANSI_S));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"t"), @(kVK_ANSI_T));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"u"), @(kVK_ANSI_U));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"v"), @(kVK_ANSI_V));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"w"), @(kVK_ANSI_W));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"x"), @(kVK_ANSI_X));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"y"), @(kVK_ANSI_Y));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"z"), @(kVK_ANSI_Z));
}

- (void)testShouldConvertUppercaseAlphabeticalKeyBindingsToKeyCodes
{
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"A"), @(kVK_ANSI_A));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"B"), @(kVK_ANSI_B));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"C"), @(kVK_ANSI_C));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"D"), @(kVK_ANSI_D));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"E"), @(kVK_ANSI_E));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F"), @(kVK_ANSI_F));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"G"), @(kVK_ANSI_G));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"H"), @(kVK_ANSI_H));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"I"), @(kVK_ANSI_I));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"J"), @(kVK_ANSI_J));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"K"), @(kVK_ANSI_K));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"L"), @(kVK_ANSI_L));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"M"), @(kVK_ANSI_M));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"N"), @(kVK_ANSI_N));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"O"), @(kVK_ANSI_O));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"P"), @(kVK_ANSI_P));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Q"), @(kVK_ANSI_Q));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"R"), @(kVK_ANSI_R));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"S"), @(kVK_ANSI_S));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"T"), @(kVK_ANSI_T));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"U"), @(kVK_ANSI_U));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"V"), @(kVK_ANSI_V));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"W"), @(kVK_ANSI_W));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"X"), @(kVK_ANSI_X));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Y"), @(kVK_ANSI_Y));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Z"), @(kVK_ANSI_Z));
}

- (void)testShouldConvertNumericKeyBindingsToKeyCodes
{
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"0"), @(kVK_ANSI_0));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"1"), @(kVK_ANSI_1));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"2"), @(kVK_ANSI_2));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"3"), @(kVK_ANSI_3));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"4"), @(kVK_ANSI_4));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"5"), @(kVK_ANSI_5));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"6"), @(kVK_ANSI_6));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"7"), @(kVK_ANSI_7));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"8"), @(kVK_ANSI_8));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"9"), @(kVK_ANSI_9));
}

- (void)testShouldConvertAlphabeticalKeyBindingsWithModifiersToKeyCodes
{
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"cmd+a"), @(kVK_ANSI_A));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"shift+cmd+b"), @(kVK_ANSI_B));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"alt+shift+cmd+c"), @(kVK_ANSI_C));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"ctrl+alt+shift+cmd+d"), @(kVK_ANSI_D));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"command+e"), @(kVK_ANSI_E));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"shift+command+f"), @(kVK_ANSI_F));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"option+shift+command+g"), @(kVK_ANSI_G));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"control+option+shift+command+h"), @(kVK_ANSI_H));
}

- (void)testShouldConvertAlphanumericKeyBindingsWithWhitespaceToKeyCodes
{
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@" cmd  +   a    "), @(kVK_ANSI_A));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@" shift  +   cmd    +     0      "), @(kVK_ANSI_0));
}

- (void)testShouldConvertNamedKeyBindingsToKeyCodes
{
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f1"), @(kVK_F1));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f2"), @(kVK_F2));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f3"), @(kVK_F3));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f4"), @(kVK_F4));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f5"), @(kVK_F5));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f6"), @(kVK_F6));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f7"), @(kVK_F7));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f8"), @(kVK_F8));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f9"), @(kVK_F9));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f10"), @(kVK_F10));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f11"), @(kVK_F11));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f12"), @(kVK_F12));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f13"), @(kVK_F13));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f14"), @(kVK_F14));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f15"), @(kVK_F15));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f16"), @(kVK_F16));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f17"), @(kVK_F17));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f18"), @(kVK_F18));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f19"), @(kVK_F19));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"f20"), @(kVK_F20));

  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypaddecimal"), @(kVK_ANSI_KeypadDecimal));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypadmultiply"), @(kVK_ANSI_KeypadMultiply));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypadplus"), @(kVK_ANSI_KeypadPlus));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypadclear"), @(kVK_ANSI_KeypadClear));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypaddivide"), @(kVK_ANSI_KeypadDivide));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypadenter"), @(kVK_ANSI_KeypadEnter));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypadminus"), @(kVK_ANSI_KeypadMinus));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypadequals"), @(kVK_ANSI_KeypadEquals));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypad0"), @(kVK_ANSI_Keypad0));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypad1"), @(kVK_ANSI_Keypad1));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypad2"), @(kVK_ANSI_Keypad2));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypad3"), @(kVK_ANSI_Keypad3));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypad4"), @(kVK_ANSI_Keypad4));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypad5"), @(kVK_ANSI_Keypad5));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypad6"), @(kVK_ANSI_Keypad6));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypad7"), @(kVK_ANSI_Keypad7));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypad8"), @(kVK_ANSI_Keypad8));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"keypad9"), @(kVK_ANSI_Keypad9));

  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"return"), @(kVK_Return));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"tab"), @(kVK_Tab));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"space"), @(kVK_Space));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"delete"), @(kVK_Delete));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"escape"), @(kVK_Escape));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"command"), @(kVK_Command));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"shift"), @(kVK_Shift));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"capslock"), @(kVK_CapsLock));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"option"), @(kVK_Option));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"control"), @(kVK_Control));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"rightshift"), @(kVK_RightShift));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"rightoption"), @(kVK_RightOption));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"rightcontrol"), @(kVK_RightControl));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"function"), @(kVK_Function));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"volumeup"), @(kVK_VolumeUp));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"volumedown"), @(kVK_VolumeDown));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"mute"), @(kVK_Mute));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"help"), @(kVK_Help));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"home"), @(kVK_Home));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"pageup"), @(kVK_PageUp));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"forwarddelete"), @(kVK_ForwardDelete));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"end"), @(kVK_End));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"pagedown"), @(kVK_PageDown));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"left"), @(kVK_LeftArrow));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"right"), @(kVK_RightArrow));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"down"), @(kVK_DownArrow));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"up"), @(kVK_UpArrow));
}

- (void)testShouldConvertMixedCaseNamedKeyBindingsToKeyCodes
{
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F1"), @(kVK_F1));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F2"), @(kVK_F2));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F3"), @(kVK_F3));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F4"), @(kVK_F4));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F5"), @(kVK_F5));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F6"), @(kVK_F6));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F7"), @(kVK_F7));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F8"), @(kVK_F8));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F9"), @(kVK_F9));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F10"), @(kVK_F10));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F11"), @(kVK_F11));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F12"), @(kVK_F12));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F13"), @(kVK_F13));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F14"), @(kVK_F14));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F15"), @(kVK_F15));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F16"), @(kVK_F16));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F17"), @(kVK_F17));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F18"), @(kVK_F18));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F19"), @(kVK_F19));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"F20"), @(kVK_F20));

  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"KeypadDecimal"), @(kVK_ANSI_KeypadDecimal));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"KeypadMultiply"), @(kVK_ANSI_KeypadMultiply));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"KeypadPlus"), @(kVK_ANSI_KeypadPlus));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"KeypadClear"), @(kVK_ANSI_KeypadClear));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"KeypadDivide"), @(kVK_ANSI_KeypadDivide));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"KeypadEnter"), @(kVK_ANSI_KeypadEnter));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"KeypadMinus"), @(kVK_ANSI_KeypadMinus));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"KeypadEquals"), @(kVK_ANSI_KeypadEquals));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Keypad0"), @(kVK_ANSI_Keypad0));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Keypad1"), @(kVK_ANSI_Keypad1));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Keypad2"), @(kVK_ANSI_Keypad2));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Keypad3"), @(kVK_ANSI_Keypad3));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Keypad4"), @(kVK_ANSI_Keypad4));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Keypad5"), @(kVK_ANSI_Keypad5));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Keypad6"), @(kVK_ANSI_Keypad6));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Keypad7"), @(kVK_ANSI_Keypad7));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Keypad8"), @(kVK_ANSI_Keypad8));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Keypad9"), @(kVK_ANSI_Keypad9));

  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Return"), @(kVK_Return));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Tab"), @(kVK_Tab));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Space"), @(kVK_Space));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Delete"), @(kVK_Delete));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Escape"), @(kVK_Escape));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Command"), @(kVK_Command));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Shift"), @(kVK_Shift));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"CapsLock"), @(kVK_CapsLock));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Option"), @(kVK_Option));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Control"), @(kVK_Control));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"RightShift"), @(kVK_RightShift));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"RightOption"), @(kVK_RightOption));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"RightControl"), @(kVK_RightControl));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Function"), @(kVK_Function));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"VolumeUp"), @(kVK_VolumeUp));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"VolumeDown"), @(kVK_VolumeDown));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Mute"), @(kVK_Mute));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Help"), @(kVK_Help));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Home"), @(kVK_Home));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"PageUp"), @(kVK_PageUp));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"ForwardDelete"), @(kVK_ForwardDelete));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"End"), @(kVK_End));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"PageDown"), @(kVK_PageDown));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Left"), @(kVK_LeftArrow));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Right"), @(kVK_RightArrow));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Down"), @(kVK_DownArrow));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"Up"), @(kVK_UpArrow));
}

- (void)testShouldConvertNamedKeyBindingsWithModifiersToKeyCodes
{
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"cmd+up"), @(kVK_UpArrow));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"shift+cmd+down"), @(kVK_DownArrow));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"alt+shift+cmd+left"), @(kVK_LeftArrow));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"ctrl+alt+shift+cmd+right"), @(kVK_RightArrow));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"command+space"), @(kVK_Space));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"shift+command+f1"), @(kVK_F1));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"option+shift+command+keypad0"), @(kVK_ANSI_Keypad0));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"control+option+shift+command+escape"), @(kVK_Escape));
}

- (void)testShouldConvertMixedCaseNamedKeyBindingsWithModifiersToKeyCodes
{
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"cmd+Up"), @(kVK_UpArrow));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"shift+cmd+Down"), @(kVK_DownArrow));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"alt+shift+cmd+left"), @(kVK_LeftArrow));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"ctrl+alt+shift+cmd+Right"), @(kVK_RightArrow));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"command+SPACE"), @(kVK_Space));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"shift+command+F1"), @(kVK_F1));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"option+shift+command+KEYPAD0"), @(kVK_ANSI_Keypad0));
  XCTAssertEqualObjects(SpectacleConvertShortcutKeyBindingToKeyCode(@"control+option+shift+command+ESCAPE"), @(kVK_Escape));
}

- (void)testShouldConvertEmptyShortcutsToNilKeyBindings
{
  XCTAssertNil(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(nil)));
}

- (void)testShouldConvertShortcutsToKeyBindings
{
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"alt+cmd+c")), @"alt+cmd+c");
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"alt+cmd+f")), @"alt+cmd+f");
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"alt+cmd+left")), @"alt+cmd+left");
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"alt+cmd+right")), @"alt+cmd+right");
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"alt+cmd+up")), @"alt+cmd+up");
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"alt+cmd+down")), @"alt+cmd+down");
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"ctrl+cmd+left")), @"ctrl+cmd+left");
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"ctrl+shift+cmd+left")), @"ctrl+shift+cmd+left");
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"ctrl+cmd+right")), @"ctrl+cmd+right");
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"ctrl+shift+cmd+right")), @"ctrl+shift+cmd+right");
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"ctrl+alt+cmd+right")), @"ctrl+alt+cmd+right");
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"ctrl+alt+cmd+left")), @"ctrl+alt+cmd+left");
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"ctrl+alt+right")), @"ctrl+alt+right");
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"ctrl+alt+left")), @"ctrl+alt+left");
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"ctrl+alt+shift+right")), @"ctrl+alt+shift+right");
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"ctrl+alt+shift+left")), @"ctrl+alt+shift+left");
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"alt+cmd+z")), @"alt+cmd+z");
  XCTAssertEqualObjects(SpectacleConvertShortcutToKeyBinding(shortcutForKeyBinding(@"alt+shift+cmd+z")), @"alt+shift+cmd+z");
}

@end

static SpectacleShortcut *shortcutForKeyBinding(NSString *keyBinding)
{
  return [[SpectacleShortcut alloc] initWithShortcutName:nil shortcutKeyBinding:keyBinding];
}
