#import <XCTest/XCTest.h>

#import "SpectacleAccessibilityElement.h"
#import "SpectacleQuantizedWindowMover.h"
#import "SpectacleScreenDetectionResult.h"
#import "SpectacleScreenDetector.h"
#import "SpectacleStandardWindowMover.h"
#import "SpectacleWindowPositionCalculationResult.h"
#import "SpectacleWindowPositionCalculator.h"
#import "SpectacleWindowPositionManager.h"

// Typed test doubles exercise CGRect arguments/returns on both arm64 and x86_64.
@interface SpectacleTestScreen : NSScreen
@end
@implementation SpectacleTestScreen
- (NSRect)frame { return NSMakeRect(0, 0, 1440, 900); }
- (NSRect)visibleFrame { return NSMakeRect(0, 4, 1440, 873); }
@end

@interface SpectacleTestElement : SpectacleAccessibilityElement
@property CGRect rect;
@property BOOL sheet;
@property BOOL systemDialog;
@property NSUInteger writes;
@property NSUInteger positionWrites;
@end
@implementation SpectacleTestElement
- (CGRect)rectOfElement { return self.rect; }
- (BOOL)isSheet { return self.sheet; }
- (BOOL)isSystemDialog { return self.systemDialog; }
- (void)setRectOfElement:(CGRect)rect { self.rect = rect; self.writes++; }
- (void)setPositionOfElement:(CGPoint)position { self.rect = CGRectMake(position.x, position.y, self.rect.size.width, self.rect.size.height); self.writes++; self.positionWrites++; }
@end

@interface SpectacleConstrainedTestElement : SpectacleTestElement
@property CGSize minimumSize;
@end
@implementation SpectacleConstrainedTestElement
- (void)setRectOfElement:(CGRect)rect
{
  rect.size.width = MAX(rect.size.width, self.minimumSize.width);
  rect.size.height = MAX(rect.size.height, self.minimumSize.height);
  [super setRectOfElement:rect];
}
@end

@interface SpectacleTestScreenDetector : SpectacleScreenDetector
@property (nonatomic, strong) SpectacleScreenDetectionResult *result;
@end
@implementation SpectacleTestScreenDetector
- (SpectacleScreenDetectionResult *)screenWithAction:(SpectacleWindowAction *)action
                            frontmostWindowElement:(SpectacleAccessibilityElement *)element
                                           screens:(NSArray<NSScreen *> *)screens
                                        mainScreen:(NSScreen *)mainScreen
{
  return self.result;
}
@end

@interface SpectacleTestCalculator : SpectacleWindowPositionCalculator
@property (nonatomic, strong) SpectacleWindowPositionCalculationResult *result;
@property NSUInteger calls;
@property CGRect receivedRect;
@end
@implementation SpectacleTestCalculator
- (SpectacleWindowPositionCalculationResult *)calculateWindowRect:(CGRect)rect
                                     visibleFrameOfSourceScreen:(CGRect)source
                                visibleFrameOfDestinationScreen:(CGRect)destination
                                                         action:(SpectacleWindowAction *)action
{
  self.calls++;
  self.receivedRect = rect;
  return self.result;
}
@end

@interface SpectacleTestWorkspace : NSWorkspace
@end
@implementation SpectacleTestWorkspace
- (NSRunningApplication *)frontmostApplication { return nil; }
@end

@interface SpectacleWindowPositionManagerTests : XCTestCase
@end

@implementation SpectacleWindowPositionManagerTests
{
  SpectacleTestScreen *_screen;
  SpectacleTestElement *_element;
  SpectacleTestScreenDetector *_detector;
  SpectacleTestCalculator *_calculator;
  SpectacleWindowPositionManager *_manager;
  NSUInteger _failures;
}

- (void)setUp
{
  [super setUp];
  _screen = [SpectacleTestScreen new];
  _element = [SpectacleTestElement new];
  _element.rect = CGRectMake(165, 245, 564, 384);
  _detector = [SpectacleTestScreenDetector new];
  _detector.result = [SpectacleScreenDetectionResult resultWithSourceScreen:_screen destinationScreen:_screen];
  _calculator = [[SpectacleTestCalculator alloc] initWithErrorHandler:nil];
  _failures = 0;
  __weak typeof(self) weakSelf = self;
  _manager = [[SpectacleWindowPositionManager alloc] initWithScreenDetector:_detector
                                                windowPositionCalculator:_calculator
                                                         sharedWorkspace:[SpectacleTestWorkspace new]
                                                         failureFeedback:^{ [weakSelf recordFailureFeedback]; }
                                                             windowMover:[SpectacleStandardWindowMover new]];
}

- (void)recordFailureFeedback { _failures++; }

- (void)moveWindow
{
  [_manager moveFrontmostWindowElement:_element action:kSpectacleWindowActionCenter
                               screens:@[_screen] mainScreen:_screen];
}

- (void)assertRejectedBeforeCalculation
{
  [self moveWindow];
  XCTAssertEqual(_calculator.calls, 0u);
  XCTAssertEqual(_element.writes, 0u);
  XCTAssertEqual(_failures, 1u);
}

- (void)testDoesNotMoveSheets
{
  _element.sheet = YES;
  [self assertRejectedBeforeCalculation];
}

- (void)testDoesNotMoveSystemDialogs
{
  _element.systemDialog = YES;
  [self assertRejectedBeforeCalculation];
}

- (void)testDoesNotMoveUnavailableWindowRects
{
  _element.rect = CGRectNull;
  [self assertRejectedBeforeCalculation];
}

- (void)testDoesNotMoveWhenScreenDetectionFails
{
  _detector.result = nil;
  [self assertRejectedBeforeCalculation];
}

- (void)testDoesNotMoveWhenCalculationFails
{
  [self moveWindow];
  XCTAssertEqual(_calculator.calls, 1u);
  XCTAssertEqual(_element.writes, 0u);
  XCTAssertEqual(_failures, 1u);
}

- (void)testDoesNotMoveWhenCalculatedRectIsUnchanged
{
  CGRect normalized = [SpectacleAccessibilityElement normalizeCoordinatesOfRect:_element.rect frameOfScreen:_screen.frame];
  _calculator.result = [SpectacleWindowPositionCalculationResult resultWithAction:kSpectacleWindowActionCenter windowRect:normalized];
  [self moveWindow];
  XCTAssertEqual(_calculator.calls, 1u);
  XCTAssertEqual(_element.writes, 0u);
  XCTAssertEqual(_failures, 1u);
}

- (void)testMovesWindowUsingCalculatedRect
{
  CGRect original = _element.rect;
  CGRect calculated = CGRectMake(10, 20, 640, 480);
  _calculator.result = [SpectacleWindowPositionCalculationResult resultWithAction:kSpectacleWindowActionCenter windowRect:calculated];
  [self moveWindow];
  CGRect expectedInput = [SpectacleAccessibilityElement normalizeCoordinatesOfRect:original frameOfScreen:_screen.frame];
  CGRect expectedOutput = [SpectacleAccessibilityElement normalizeCoordinatesOfRect:calculated frameOfScreen:_screen.frame];
  XCTAssertTrue(CGRectEqualToRect(_calculator.receivedRect, expectedInput));
  XCTAssertTrue(CGRectEqualToRect(_element.rect, expectedOutput));
  XCTAssertEqual(_element.writes, 1u);
  XCTAssertEqual(_failures, 0u);
}

- (void)testPureTranslationUsesOnlyOneAccessibilityWrite
{
  CGRect target = CGRectMake(300, 200, _element.rect.size.width, _element.rect.size.height);
  [[SpectacleStandardWindowMover new] moveWindowRect:target frameOfScreen:_screen.frame
                               visibleFrameOfScreen:_screen.visibleFrame frontmostWindowElement:_element
                                             action:kSpectacleWindowActionRightHalf];
  XCTAssertTrue(CGRectEqualToRect(_element.rect, target));
  XCTAssertEqual(_element.writes, 1u);
  XCTAssertEqual(_element.positionWrites, 1u);
}

- (void)testConstrainedWindowDoesNotTriggerUnboundedResizeAttempts
{
  SpectacleConstrainedTestElement *element = [SpectacleConstrainedTestElement new];
  element.rect = CGRectMake(0, 0, 600, 400);
  element.minimumSize = element.rect.size;
  [[SpectacleQuantizedWindowMover new] moveWindowRect:CGRectMake(0, 0, 400, 300)
                                      frameOfScreen:_screen.frame visibleFrameOfScreen:_screen.visibleFrame
                            frontmostWindowElement:element action:kSpectacleWindowActionLeftHalf];
  XCTAssertLessThanOrEqual(element.writes, 3u);
  XCTAssertTrue(CGSizeEqualToSize(element.rect.size, element.minimumSize));
}

@end
