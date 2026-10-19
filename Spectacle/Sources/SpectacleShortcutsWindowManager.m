#import "SpectacleShortcutsWindowManager.h"
#import "SpectacleShortcutsHistory.h"
#import "SpectacleWindowPositionCalculator.h"
#import "SpectacleWindowPositionCalculationResult.h"

static NSError *windowError(NSString *message)
{
  return [NSError errorWithDomain:SpectacleShortcutsErrorDomain code:SpectacleShortcutsTargetChanged
                        userInfo:@{NSLocalizedDescriptionKey:message}];
}

@implementation SpectacleShortcutsWindowManager
{
  SpectacleWindowPositionCalculator *_calculator;
  id<SpectacleShortcutsTransport> _transport;
  SpectacleWindowSnapshot *(^_snapshotProvider)(void);
  SpectacleWindowSnapshot *(^_refreshProvider)(SpectacleWindowSnapshot *);
  NSArray<NSScreen *> *(^_screensProvider)(void);
  void (^_failureHandler)(NSError *);
  NSMutableArray<NSDictionary *> *_pending;
  NSMutableDictionary<NSString *, SpectacleShortcutsHistory *> *_histories;
  BOOL _busy;
  BOOL _alertVisible;
}

- (instancetype)initWithCalculator:(SpectacleWindowPositionCalculator *)calculator
{
  return [self initWithCalculator:calculator transport:[SpectacleShortcutsBridge new]
                snapshotProvider:^{ return SpectacleWindowSnapshot.frontmostWindow; }
                 refreshProvider:^SpectacleWindowSnapshot *(SpectacleWindowSnapshot *snapshot) {
                   return [SpectacleWindowSnapshot refreshSnapshot:snapshot];
                 }
                 screensProvider:^{ return NSScreen.screens; } failureHandler:nil];
}

- (instancetype)initWithCalculator:(SpectacleWindowPositionCalculator *)calculator
                         transport:(id<SpectacleShortcutsTransport>)transport
                  snapshotProvider:(SpectacleWindowSnapshot *(^)(void))snapshotProvider
                   refreshProvider:(SpectacleWindowSnapshot *(^)(SpectacleWindowSnapshot *))refreshProvider
                   screensProvider:(NSArray<NSScreen *> *(^)(void))screensProvider
                    failureHandler:(void (^)(NSError *))failureHandler
{
  if (self = [super init]) {
    _calculator = calculator;
    _transport = transport;
    _snapshotProvider = [snapshotProvider copy];
    _refreshProvider = [refreshProvider copy];
    _screensProvider = [screensProvider copy];
    _failureHandler = [failureHandler copy];
    _pending = [NSMutableArray new];
    _histories = [NSMutableDictionary new];
  }
  return self;
}

- (void)performWindowAction:(SpectacleWindowAction *)action
{
  NSAssert(NSThread.isMainThread, @"Window commands must enter on the main thread");
  SpectacleWindowSnapshot *snapshot = _snapshotProvider();
  if (!snapshot || _alertVisible || _pending.count >= 8) { NSBeep(); return; }
  [_pending addObject:@{@"action":action, @"snapshot":snapshot, @"date":NSDate.date}];
  [self runNextCommand];
}

- (void)runNextCommand
{
  if (_busy || !_pending.count) return;
  NSDictionary *command = _pending.firstObject;
  [_pending removeObjectAtIndex:0];
  SpectacleWindowSnapshot *captured = command[@"snapshot"];
  SpectacleWindowSnapshot *front = _snapshotProvider();
  SpectacleWindowSnapshot *current = _refreshProvider(captured);
  if (!current || ![front.identity isEqual:captured.identity]
      || -[command[@"date"] timeIntervalSinceNow] > 5) {
    // Never redirect queued work to whichever window became active in the meantime.
    [_pending removeAllObjects];
    NSBeep();
    return;
  }
  SpectacleWindowAction *action = command[@"action"];
  SpectacleShortcutsHistory *history = _histories[current.identity];
  if (!history) {
    // Bounded session-only history; window titles never enter storage.
    if (_histories.count >= 100) [_histories removeAllObjects];
    history = [SpectacleShortcutsHistory new];
    _histories[current.identity] = history;
  }
  BOOL historyAction = SpectacleIsUndoWindowAction(action) || SpectacleIsRedoWindowAction(action);
  CGRect target = historyAction ? [history targetForAction:action]
    : [self targetFrameForAction:action windowFrame:current.frame screens:_screensProvider()];
  if (CGRectIsNull(target) || CGRectIsEmpty(target) || CGRectIsInfinite(target)
      || !isfinite(target.origin.x) || !isfinite(target.origin.y)
      || CGRectEqualToRect(target, current.frame)) {
    NSBeep();
    [self runNextCommand];
    return;
  }
  NSDictionary *request = @{
    @"protocol":@1, @"requestID":NSUUID.UUID.UUIDString, @"operation":@"move",
    @"app":current.appName,
    @"beforeX":@(current.frame.origin.x), @"beforeY":@(current.frame.origin.y),
    @"beforeWidth":@(current.frame.size.width), @"beforeHeight":@(current.frame.size.height),
    @"x":@(target.origin.x), @"y":@(target.origin.y),
    @"width":@(target.size.width), @"height":@(target.size.height)
  };
  _busy = YES;
  [_transport executeRequest:request completion:^(NSDictionary *response, NSError *error) {
    [self finishCommand:action snapshot:current history:history error:error attempt:0];
  }];
}

- (void)finishCommand:(SpectacleWindowAction *)action snapshot:(SpectacleWindowSnapshot *)before
              history:(SpectacleShortcutsHistory *)history error:(NSError *)error attempt:(NSUInteger)attempt
{
  SpectacleWindowSnapshot *after = _refreshProvider(before);
  // Window Server geometry may lag completion of the automation by a few frames.
  if (!error && after && CGRectEqualToRect(before.frame, after.frame) && attempt < 5) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
      [self finishCommand:action snapshot:before history:history error:nil attempt:attempt + 1];
    });
    return;
  }
  if (after && !CGRectEqualToRect(before.frame, after.frame)) {
    // Preserve an undo path even if Shortcuts failed after a partial resize.
    [history recordAction:error ? kSpectacleWindowActionNone : action before:before.frame after:after.frame];
  } else if (!error) {
    error = windowError(@"The window did not move. It may be fullscreen, minimized, closed, or unable to use that size.");
  }
  _busy = NO;
  if (error) {
    [_pending removeAllObjects];
    [self reportError:error];
  } else {
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"ShortcutsBridgeVerified"];
    [self runNextCommand];
  }
}

- (CGRect)targetFrameForAction:(SpectacleWindowAction *)action windowFrame:(CGRect)windowFrame
                      screens:(NSArray<NSScreen *> *)screens
{
  if (!screens.count) return CGRectNull;
  CGFloat primaryHeight = CGRectGetMaxY(screens.firstObject.frame);
  CGRect cocoaRect = [SpectacleWindowSnapshot flipRect:windowFrame primaryScreenHeight:primaryHeight];
  NSScreen *source = nil;
  CGFloat largestArea = 0;
  for (NSScreen *screen in screens) {
    CGRect overlap = CGRectIntersection(cocoaRect, screen.frame);
    CGFloat area = CGRectIsNull(overlap) ? 0 : overlap.size.width * overlap.size.height;
    if (area > largestArea) { source = screen; largestArea = area; }
  }
  if (!source) return CGRectNull;
  NSScreen *destination = source;
  if (SpectacleIsMovingToDisplayWindowAction(action)) {
    if (screens.count < 2) return CGRectNull;
    NSArray *ordered = [screens sortedArrayUsingComparator:^NSComparisonResult(NSScreen *a, NSScreen *b) {
      if (a.frame.origin.x != b.frame.origin.x) return a.frame.origin.x < b.frame.origin.x ? NSOrderedAscending : NSOrderedDescending;
      if (a.frame.origin.y != b.frame.origin.y) return a.frame.origin.y < b.frame.origin.y ? NSOrderedAscending : NSOrderedDescending;
      return NSOrderedSame;
    }];
    NSInteger index = (NSInteger)[ordered indexOfObjectIdenticalTo:source];
    index += SpectacleIsNextDisplayWindowAction(action) ? 1 : -1;
    destination = ordered[(index + ordered.count) % ordered.count];
  }
  SpectacleWindowPositionCalculationResult *result = [_calculator calculateWindowRect:cocoaRect
                                                          visibleFrameOfSourceScreen:source.visibleFrame
                                                     visibleFrameOfDestinationScreen:destination.visibleFrame action:action];
  return result ? [SpectacleWindowSnapshot flipRect:result.windowRect primaryScreenHeight:primaryHeight] : CGRectNull;
}

- (void)reportError:(NSError *)error
{
  if (_failureHandler) { _failureHandler(error); return; }
  if (_alertVisible) return;
  _alertVisible = YES;
  NSAlert *alert = [NSAlert new];
  alert.messageText = @"Window control needs attention";
  alert.informativeText = error.localizedDescription;
  [alert addButtonWithTitle:@"OK"];
  [alert addButtonWithTitle:@"Set Up Window Control…"];
  NSInteger choice = [alert runModal];
  _alertVisible = NO;
  if (choice == NSAlertSecondButtonReturn) [self showSetup];
}

- (void)showSetup
{
  if (_alertVisible || _busy) return;
  _alertVisible = YES;
  [_pending removeAllObjects];
  NSAlert *alert = [NSAlert new];
  alert.messageText = @"Set up window control";
  alert.informativeText = @"Spectacle uses Apple's Shortcuts app to arrange windows. Add the included Spectacle Window Bridge shortcut, keep its name, then verify the connection. macOS may ask you to allow Spectacle to control Shortcuts and Shortcuts to manage windows.";
  [alert addButtonWithTitle:@"Add Shortcut"];
  [alert addButtonWithTitle:@"Verify Connection"];
  [alert addButtonWithTitle:@"Later"];
  NSInteger choice = [alert runModal];
  _alertVisible = NO;
  if (choice == NSAlertFirstButtonReturn) {
    NSURL *url = [NSBundle.mainBundle URLForResource:SpectacleCompanionShortcutName withExtension:@"shortcut" subdirectory:@"Shortcuts"];
    if (!url || ![NSWorkspace.sharedWorkspace openURL:url]) {
      [self reportError:windowError(@"The companion Shortcut is missing from this copy of Spectacle. Install a complete build and try again.")];
    }
  } else if (choice == NSAlertSecondButtonReturn) {
    _busy = YES;
    NSDictionary *request = @{@"protocol":@1, @"requestID":NSUUID.UUID.UUIDString, @"operation":@"probe"};
    [_transport executeRequest:request completion:^(NSDictionary *response, NSError *error) {
      self->_busy = NO;
      [self->_pending removeAllObjects];
      if (error) { [self reportError:error]; return; }
      [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"ShortcutsBridgeVerified"];
      NSAlert *success = [NSAlert new];
      success.messageText = @"Window control is connected";
      success.informativeText = @"Focus a window and use a Spectacle keyboard shortcut or menu command. The first move may request permission inside Shortcuts.";
      self->_alertVisible = YES;
      [success runModal];
      self->_alertVisible = NO;
    }];
  }
}
@end
