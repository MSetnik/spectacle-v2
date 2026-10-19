#import <XCTest/XCTest.h>
#import "SpectacleShortcutsBridge.h"
#import "SpectacleShortcutsHistory.h"
#import "SpectacleShortcutsWindowManager.h"
#import "SpectacleWindowPositionCalculator.h"

@interface SpectacleBridgeTestScreen : NSScreen
@property NSRect testFrame;
@property NSRect testVisibleFrame;
@end
@implementation SpectacleBridgeTestScreen
- (NSRect)frame { return self.testFrame; }
- (NSRect)visibleFrame { return self.testVisibleFrame; }
@end

@interface SpectacleBridgeTestTransport : NSObject <SpectacleShortcutsTransport>
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *requests;
@property (copy) SpectacleShortcutsCompletion completion;
@end
@implementation SpectacleBridgeTestTransport
- (instancetype)init { if (self = [super init]) _requests = [NSMutableArray new]; return self; }
- (void)executeRequest:(NSDictionary *)request completion:(SpectacleShortcutsCompletion)completion
{
  NSAssert(!self.completion, @"Requests must not overlap");
  [self.requests addObject:request]; self.completion = completion;
}
- (void)finishWithError:(NSError *)error
{
  SpectacleShortcutsCompletion completion = self.completion;
  self.completion = nil;
  completion(error ? nil : @{@"status":@"ok"}, error);
}
@end

static NSDictionary *windowInfo(CGWindowID windowID, pid_t pid, CGRect frame, NSInteger layer, CGFloat alpha)
{
  return @{(__bridge NSString *)kCGWindowNumber:@(windowID), (__bridge NSString *)kCGWindowOwnerPID:@(pid),
           (__bridge NSString *)kCGWindowLayer:@(layer), (__bridge NSString *)kCGWindowAlpha:@(alpha),
           (__bridge NSString *)kCGWindowBounds:CFBridgingRelease(CGRectCreateDictionaryRepresentation(frame))};
}

static SpectacleWindowSnapshot *snapshot(CGWindowID windowID, CGRect frame)
{
  return [SpectacleWindowSnapshot snapshotFromWindows:@[windowInfo(windowID, 42, frame, 0, 1)]
                                    processIdentifier:42 windowID:windowID appName:@"Test App"
                                           launchDate:[NSDate dateWithTimeIntervalSince1970:100]];
}

@interface SpectacleShortcutsTests : XCTestCase
@end
@implementation SpectacleShortcutsTests
{
  SpectacleBridgeTestTransport *_transport;
  SpectacleShortcutsWindowManager *_manager;
  SpectacleWindowSnapshot *_front;
  NSMutableDictionary<NSNumber *, SpectacleWindowSnapshot *> *_windows;
  NSMutableArray<NSError *> *_errors;
  SpectacleBridgeTestScreen *_screen;
}
- (void)setUp
{
  _transport = [SpectacleBridgeTestTransport new];
  _windows = [NSMutableDictionary new]; _errors = [NSMutableArray new];
  _front = snapshot(7, CGRectMake(100, 100, 600, 400)); _windows[@7] = _front;
  _screen = [SpectacleBridgeTestScreen new];
  _screen.testFrame = NSMakeRect(0, 0, 1440, 900);
  _screen.testVisibleFrame = NSMakeRect(0, 30, 1440, 840);
  __weak typeof(self) weakSelf = self;
  _manager = [[SpectacleShortcutsWindowManager alloc]
              initWithCalculator:[[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *message) { XCTFail(@"%@", message); }]
              transport:_transport snapshotProvider:^{ return weakSelf.currentFront; }
              refreshProvider:^SpectacleWindowSnapshot *(SpectacleWindowSnapshot *value) { return [weakSelf currentSnapshot:value]; }
              screensProvider:^{ return @[weakSelf.currentScreen]; }
              failureHandler:^(NSError *error) { [weakSelf recordError:error]; }];
}
- (SpectacleWindowSnapshot *)currentFront { return _front; }
- (NSScreen *)currentScreen { return _screen; }
- (SpectacleWindowSnapshot *)currentSnapshot:(SpectacleWindowSnapshot *)value { return _windows[@(value.windowID)]; }
- (void)recordError:(NSError *)error { [_errors addObject:error]; }
- (void)completeWithFrame:(CGRect)frame error:(NSError *)error
{
  CGWindowID windowID = _front.windowID;
  _front = snapshot(windowID, frame); _windows[@(windowID)] = _front;
  [_transport finishWithError:error];
}
- (void)testRejectsMismatchedReplies
{
  NSError *error = nil;
  XCTAssertNil(([SpectacleShortcutsBridge validatedResponse:@{@"protocol":@1, @"requestID":@"old", @"status":@"ok"} requestID:@"new" error:&error]));
  XCTAssertEqual(error.code, SpectacleShortcutsInvalidResponse);
}
- (void)testRejectsMalformedAndIncompatibleReplies
{
  for (id value in @[@"not JSON", @[], @{@"protocol":@2, @"requestID":@"id", @"status":@"ok"}]) {
    NSError *error = nil;
    XCTAssertNil([SpectacleShortcutsBridge validatedResponse:value requestID:@"id" error:&error]);
    XCTAssertEqual(error.code, SpectacleShortcutsInvalidResponse);
  }
}
- (void)testAcceptsJSONAndSingleItemReplies
{
  NSError *error = nil;
  NSDictionary *result = [SpectacleShortcutsBridge validatedResponse:@[@"{\"protocol\":1,\"requestID\":\"id\",\"status\":\"ok\"}"] requestID:@"id" error:&error];
  XCTAssertEqualObjects(result[@"status"], @"ok"); XCTAssertNil(error);
}
- (void)testPropagatesCompanionRefusal
{
  NSError *error = nil;
  XCTAssertNil(([SpectacleShortcutsBridge validatedResponse:@{@"protocol":@1, @"requestID":@"id", @"status":@"target-changed"} requestID:@"id" error:&error]));
  XCTAssertEqual(error.code, SpectacleShortcutsTargetChanged);
}
- (void)testWindowDiscoverySkipsOtherProcessesAndInvisibleOverlays
{
  CGRect frame = CGRectMake(0, 0, 500, 400);
  NSArray *windows = @[windowInfo(1, 77, frame, 0, 1), windowInfo(2, 42, frame, 3, 1),
                       windowInfo(3, 42, frame, 0, 0), windowInfo(4, 42, frame, 0, 1)];
  SpectacleWindowSnapshot *result = [SpectacleWindowSnapshot snapshotFromWindows:windows processIdentifier:42
                                                                      windowID:0 appName:@"Test" launchDate:NSDate.date];
  XCTAssertEqual(result.windowID, 4u);
}
- (void)testSnapshotIdentitySurvivesMovementButNotProcessReuse
{
  SpectacleWindowSnapshot *moved = snapshot(7, CGRectMake(0, 0, 300, 200));
  XCTAssertEqualObjects(_front.identity, moved.identity);
  SpectacleWindowSnapshot *reused = [SpectacleWindowSnapshot snapshotFromWindows:@[windowInfo(7, 42, moved.frame, 0, 1)]
                                         processIdentifier:42 windowID:7 appName:@"Test App" launchDate:NSDate.date];
  XCTAssertNotEqualObjects(_front.identity, reused.identity);
}
- (void)testCoordinateConversionUsesPrimaryScreenEvenAboveOrLeftOfIt
{
  CGRect frame = CGRectMake(-1200, -800, 600, 500);
  CGRect flipped = [SpectacleWindowSnapshot flipRect:frame primaryScreenHeight:900];
  XCTAssertTrue(CGRectEqualToRect(flipped, CGRectMake(-1200, 1200, 600, 500)));
  XCTAssertTrue(CGRectEqualToRect([SpectacleWindowSnapshot flipRect:flipped primaryScreenHeight:900], frame));
}
- (void)testHalfRespectsMenuBarAndDock
{
  CGRect target = [_manager targetFrameForAction:kSpectacleWindowActionLeftHalf windowFrame:_front.frame screens:@[_screen]];
  XCTAssertTrue(CGRectEqualToRect(target, CGRectMake(0, 30, 720, 840)));
}
- (void)testTransfersToDisplayLeftOfPrimary
{
  SpectacleBridgeTestScreen *left = [SpectacleBridgeTestScreen new];
  left.testFrame = NSMakeRect(-1280, 0, 1280, 1024); left.testVisibleFrame = left.testFrame;
  CGRect target = [_manager targetFrameForAction:kSpectacleWindowActionNextDisplay windowFrame:_front.frame screens:@[_screen, left]];
  XCTAssertTrue(CGRectContainsRect(CGRectMake(-1280, -124, 1280, 1024), target));
}
- (void)testCommandsAreSerializedAndUseFreshBounds
{
  [_manager performWindowAction:kSpectacleWindowActionLeftHalf];
  [_manager performWindowAction:kSpectacleWindowActionRightHalf];
  XCTAssertEqual(_transport.requests.count, 1u);
  XCTAssertEqualObjects(_transport.requests[0][@"beforeX"], @100);
  [self completeWithFrame:CGRectMake(0, 30, 720, 840) error:nil];
  XCTAssertEqual(_transport.requests.count, 2u);
  XCTAssertEqualObjects(_transport.requests[1][@"beforeX"], @0);
  XCTAssertEqualObjects(_transport.requests[1][@"x"], @720);
}
- (void)testUndoIsRecordedOnlyAfterObservedMovement
{
  CGRect original = _front.frame;
  [_manager performWindowAction:kSpectacleWindowActionLeftHalf];
  [_manager performWindowAction:kSpectacleWindowActionUndo];
  XCTAssertEqual(_transport.requests.count, 1u);
  [self completeWithFrame:CGRectMake(0, 30, 720, 840) error:nil];
  NSDictionary *undo = _transport.requests.lastObject;
  XCTAssertEqualObjects(undo[@"x"], @(original.origin.x));
  XCTAssertEqualObjects(undo[@"width"], @(original.size.width));
}
- (void)testFocusChangeCancelsPendingCommands
{
  [_manager performWindowAction:kSpectacleWindowActionLeftHalf];
  [_manager performWindowAction:kSpectacleWindowActionRightHalf];
  _windows[@7] = snapshot(7, CGRectMake(0, 30, 720, 840));
  _front = snapshot(8, CGRectMake(100, 100, 600, 400)); _windows[@8] = _front;
  [_transport finishWithError:nil];
  XCTAssertEqual(_transport.requests.count, 1u);
}
- (void)testFailureCancelsPendingCommands
{
  [_manager performWindowAction:kSpectacleWindowActionLeftHalf];
  [_manager performWindowAction:kSpectacleWindowActionRightHalf];
  [_transport finishWithError:[NSError errorWithDomain:SpectacleShortcutsErrorDomain code:2 userInfo:nil]];
  XCTAssertEqual(_transport.requests.count, 1u); XCTAssertEqual(_errors.count, 1u);
  [_manager performWindowAction:kSpectacleWindowActionUndo];
  XCTAssertEqual(_transport.requests.count, 1u);
}
- (void)testPartialFailureStillAllowsUndo
{
  [_manager performWindowAction:kSpectacleWindowActionLeftHalf];
  [self completeWithFrame:CGRectMake(100, 100, 720, 840)
                   error:[NSError errorWithDomain:SpectacleShortcutsErrorDomain code:3 userInfo:nil]];
  [_manager performWindowAction:kSpectacleWindowActionUndo];
  XCTAssertEqualObjects(_transport.requests.lastObject[@"width"], @600);
}
- (void)testHistoryRedoIsClearedByNewMove
{
  SpectacleShortcutsHistory *history = [SpectacleShortcutsHistory new];
  CGRect a = CGRectMake(10, 20, 400, 300), b = CGRectMake(0, 0, 800, 600), c = CGRectMake(20, 20, 500, 300);
  [history recordAction:kSpectacleWindowActionLeftHalf before:a after:b];
  XCTAssertTrue(CGRectEqualToRect([history targetForAction:kSpectacleWindowActionUndo], a));
  [history recordAction:kSpectacleWindowActionUndo before:b after:a];
  XCTAssertTrue(CGRectEqualToRect([history targetForAction:kSpectacleWindowActionRedo], b));
  [history recordAction:kSpectacleWindowActionCenter before:a after:c];
  XCTAssertTrue(CGRectIsNull([history targetForAction:kSpectacleWindowActionRedo]));
}
@end
