#import <XCTest/XCTest.h>

#import "SpectacleWindowPositionCalculationResult.h"
#import "SpectacleWindowPositionCalculator.h"

@interface SpectacleLeftHalfWindowCalculationTests : XCTestCase
@end

@implementation SpectacleLeftHalfWindowCalculationTests

- (void)testShouldCalculateAWindowSCGRectInTheLeftHalfOfTheScreen
{
  CGRect visibleFrameSourceScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  CGRect visibleFrameDestinationScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  SpectacleWindowPositionCalculator *windowPositionCalculator = [[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *message) {
    XCTFail(@"%@", message);
  }];

  SpectacleWindowPositionCalculationResult *result = [windowPositionCalculator calculateWindowRect:CGRectMake(165.0f, 245.0f, 564.0f, 384.0f)
                                                                        visibleFrameOfSourceScreen:visibleFrameSourceScreen
                                                                   visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                                                            action:kSpectacleWindowActionLeftHalf];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(0.0f, 4.0f, 720.0f, 873.0f)));
}

- (void)testShouldCalculateAWindowSCGRectInTheLeft23OfTheScreen
{
  CGRect visibleFrameSourceScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  CGRect visibleFrameDestinationScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  SpectacleWindowPositionCalculator *windowPositionCalculator = [[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *message) {
    XCTFail(@"%@", message);
  }];

  SpectacleWindowPositionCalculationResult *result = [windowPositionCalculator calculateWindowRect:CGRectMake(0.0f, 4.0f, 720.0f, 873.0f)
                                                                        visibleFrameOfSourceScreen:visibleFrameSourceScreen
                                                                   visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                                                            action:kSpectacleWindowActionLeftHalf];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(0.0f, 4.0f, 960.0f, 873.0f)));
}

- (void)testShouldCalculateAWindowSCGRectInTheLeft13OfTheScreen
{
  CGRect visibleFrameSourceScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  CGRect visibleFrameDestinationScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  SpectacleWindowPositionCalculator *windowPositionCalculator = [[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *message) {
    XCTFail(@"%@", message);
  }];

  SpectacleWindowPositionCalculationResult *result = [windowPositionCalculator calculateWindowRect:CGRectMake(0.0f, 4.0f, 960.0f, 873.0f)
                                                                        visibleFrameOfSourceScreen:visibleFrameSourceScreen
                                                                   visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                                                            action:kSpectacleWindowActionLeftHalf];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(0.0f, 4.0f, 480.0f, 873.0f)));
}

@end
