#import <Cocoa/Cocoa.h>

// A manual integration fixture. It observes only its own window and never automates other apps.
@interface FixtureDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@property (strong) NSWindow *window;
@property (strong) NSTextField *geometry;
@property (strong) NSTimer *geometryTimer;
@end

@implementation FixtureDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
  NSMenu *menu = [NSMenu new];
  NSMenuItem *applicationItem = [NSMenuItem new];
  [menu addItem:applicationItem];
  NSMenu *applicationMenu = [NSMenu new];
  [applicationMenu addItemWithTitle:@"Quit Spectacle Window Test" action:@selector(terminate:) keyEquivalent:@"q"];
  applicationItem.submenu = applicationMenu;
  NSApp.mainMenu = menu;

  self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 640, 400)
                                          styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                                                    NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
                                            backing:NSBackingStoreBuffered defer:NO];
  self.window.title = @"Spectacle Window Test — Target";
  self.window.minSize = NSMakeSize(320, 220);
  self.window.delegate = self;
  [self.window setFrameTopLeftPoint:NSMakePoint(180, NSMaxY(NSScreen.screens.firstObject.frame) - 180)];

  NSTextField *heading = [NSTextField labelWithString:@"Spectacle window-control test"];
  heading.font = [NSFont boldSystemFontOfSize:22];
  self.geometry = [NSTextField wrappingLabelWithString:@""];
  self.geometry.font = [NSFont monospacedSystemFontOfSize:17 weight:NSFontWeightRegular];
  NSTextField *note = [NSTextField wrappingLabelWithString:@"This window contains no documents. Move or resize it to check the Shortcuts backend. Coordinates use the primary display’s top-left origin."];
  // Keep the measurement UI from imposing its intrinsic size on the test window.
  heading.frame = NSMakeRect(24, 344, 592, 32);
  self.geometry.frame = NSMakeRect(24, 256, 592, 64);
  note.frame = NSMakeRect(24, 136, 592, 100);
  for (NSView *view in @[heading, self.geometry, note]) {
    view.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
    [self.window.contentView addSubview:view];
  }
  // Some systems deliver resize notifications before animation reaches its final frame.
  self.geometryTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                                     selector:@selector(updateGeometry) userInfo:nil repeats:YES];
  [self updateGeometry];
  [self.window makeKeyAndOrderFront:nil];
  [NSApp activateIgnoringOtherApps:YES];
}

- (void)updateGeometry
{
  NSRect frame = self.window.frame;
  CGFloat y = NSMaxY(NSScreen.screens.firstObject.frame) - NSMaxY(frame);
  self.geometry.stringValue = [NSString stringWithFormat:@"x: %.0f   y: %.0f\nwidth: %.0f   height: %.0f",
                              frame.origin.x, y, frame.size.width, frame.size.height];
}
- (void)windowDidMove:(NSNotification *)notification { [self updateGeometry]; }
- (void)windowDidResize:(NSNotification *)notification { [self updateGeometry]; }
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender { return YES; }
@end

int main(void)
{
  @autoreleasepool {
    NSApplication *application = NSApplication.sharedApplication;
    FixtureDelegate *delegate = [FixtureDelegate new];
    application.delegate = delegate;
    [application setActivationPolicy:NSApplicationActivationPolicyRegular];
    [application run];
  }
  return 0;
}
