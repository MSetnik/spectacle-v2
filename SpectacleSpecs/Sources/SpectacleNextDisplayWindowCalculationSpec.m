#import <XCTest/XCTest.h>

#import "SpectacleWindowPositionCalculationResult.h"
#import "SpectacleWindowPositionCalculator.h"

@interface SpectacleNextDisplayWindowCalculationTests : XCTestCase
@end

@implementation SpectacleNextDisplayWindowCalculationTests

- (void)testShouldCalculateACenteredWindowSCGRectInTheNextDisplay
{
  CGRect visibleFrameSourceScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  CGRect visibleFrameDestinationScreen = CGRectMake(1440.0f, 4.0f, 1440.0f, 873.0f);
  SpectacleWindowPositionCalculator *windowPositionCalculator = [[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *message) {
    XCTFail(@"%@", message);
  }];

  SpectacleWindowPositionCalculationResult *result = [windowPositionCalculator calculateWindowRect:CGRectMake(165.0f, 245.0f, 564.0f, 384.0f)
                                                                        visibleFrameOfSourceScreen:visibleFrameSourceScreen
                                                                   visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                                                            action:kSpectacleWindowActionNextDisplay];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(1878.0f, 249.0f, 564.0f, 384.0f)));
}

@end
