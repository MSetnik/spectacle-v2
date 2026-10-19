#import <XCTest/XCTest.h>

#import "SpectacleWindowPositionCalculationResult.h"
#import "SpectacleWindowPositionCalculator.h"

@interface SpectacleSmallerWindowCalculationTests : XCTestCase
@end

@implementation SpectacleSmallerWindowCalculationTests

- (void)testShouldCalculateAWindowSSmallerCGRectWhenCenteredInTheScreen
{
  CGRect visibleFrameSourceScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  CGRect visibleFrameDestinationScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  SpectacleWindowPositionCalculator *windowPositionCalculator = [[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *message) {
    XCTFail(@"%@", message);
  }];

  SpectacleWindowPositionCalculationResult *result = [windowPositionCalculator calculateWindowRect:CGRectMake(315.0f, 177.0f, 810.0f, 526.0f)
                                                                        visibleFrameOfSourceScreen:visibleFrameSourceScreen
                                                                   visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                                                            action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(330.0f, 192.0f, 780.0f, 496.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(330.0f, 192.0f, 780.0f, 496.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(345.0f, 207.0f, 750.0f, 466.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(345.0f, 207.0f, 750.0f, 466.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(360.0f, 222.0f, 720.0f, 436.0f)));
}

- (void)testShouldCalculateAWindowSSmallerCGRectWhenAgainstTheTopEdgeOfTheScreen
{
  CGRect visibleFrameSourceScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  CGRect visibleFrameDestinationScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  SpectacleWindowPositionCalculator *windowPositionCalculator = [[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *message) {
    XCTFail(@"%@", message);
  }];

  SpectacleWindowPositionCalculationResult *result = [windowPositionCalculator calculateWindowRect:CGRectMake(357.0f, 351.0f, 810.0f, 526.0f)
                                                                        visibleFrameOfSourceScreen:visibleFrameSourceScreen
                                                                   visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                                                            action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(372.0f, 381.0f, 780.0f, 496.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(372.0f, 381.0f, 780.0f, 496.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(387.0f, 411.0f, 750.0f, 466.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(387.0f, 411.0f, 750.0f, 466.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(402.0f, 441.0f, 720.0f, 436.0f)));
}

- (void)testShouldCalculateAWindowSSmallerCGRectWhenAgainstTheBottomEdgeOfTheScreen
{
  CGRect visibleFrameSourceScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  CGRect visibleFrameDestinationScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  SpectacleWindowPositionCalculator *windowPositionCalculator = [[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *message) {
    XCTFail(@"%@", message);
  }];

  SpectacleWindowPositionCalculationResult *result = [windowPositionCalculator calculateWindowRect:CGRectMake(193.0f, 4.0f, 810.0f, 526.0f)
                                                                        visibleFrameOfSourceScreen:visibleFrameSourceScreen
                                                                   visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                                                            action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(208.0f, 4.0f, 780.0f, 496.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(208.0f, 4.0f, 780.0f, 496.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(223.0f, 4.0f, 750.0f, 466.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(223.0f, 4.0f, 750.0f, 466.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(238.0f, 4.0f, 720.0f, 436.0f)));
}

- (void)testShouldCalculateAWindowSSmallerCGRectWhenAgainstTheLeftEdgeOfTheScreen
{
  CGRect visibleFrameSourceScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  CGRect visibleFrameDestinationScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  SpectacleWindowPositionCalculator *windowPositionCalculator = [[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *message) {
    XCTFail(@"%@", message);
  }];

  SpectacleWindowPositionCalculationResult *result = [windowPositionCalculator calculateWindowRect:CGRectMake(0.0f, 205.0f, 810.0f, 526.0f)
                                                                        visibleFrameOfSourceScreen:visibleFrameSourceScreen
                                                                   visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                                                            action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(0.0f, 220.0f, 780.0f, 496.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(0.0f, 220.0f, 780.0f, 496.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(0.0f, 235.0f, 750.0f, 466.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(0.0f, 235.0f, 750.0f, 466.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(0.0f, 250.0f, 720.0f, 436.0f)));
}

- (void)testShouldCalculateAWindowSSmallerCGRectWhenAgainstTheRightEdgeOfTheScreen
{
  CGRect visibleFrameSourceScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  CGRect visibleFrameDestinationScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  SpectacleWindowPositionCalculator *windowPositionCalculator = [[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *message) {
    XCTFail(@"%@", message);
  }];

  SpectacleWindowPositionCalculationResult *result = [windowPositionCalculator calculateWindowRect:CGRectMake(630.0f, 258.0f, 810.0f, 526.0f)
                                                                        visibleFrameOfSourceScreen:visibleFrameSourceScreen
                                                                   visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                                                            action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(660.0f, 273.0f, 780.0f, 496.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(660.0f, 273.0f, 780.0f, 496.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(690.0f, 288.0f, 750.0f, 466.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(690.0f, 288.0f, 750.0f, 466.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(720.0f, 303.0f, 720.0f, 436.0f)));
}

- (void)testShouldCalculateAWindowSSmallerCGRectWhenAgainstTheTopAndLeftEdgesOfTheScreen
{
  CGRect visibleFrameSourceScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  CGRect visibleFrameDestinationScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  SpectacleWindowPositionCalculator *windowPositionCalculator = [[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *message) {
    XCTFail(@"%@", message);
  }];

  SpectacleWindowPositionCalculationResult *result = [windowPositionCalculator calculateWindowRect:CGRectMake(0.0f, 351.0f, 810.0f, 526.0f)
                                                                        visibleFrameOfSourceScreen:visibleFrameSourceScreen
                                                                   visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                                                            action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(0.0f, 381.0f, 780.0f, 496.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(0.0f, 381.0f, 780.0f, 496.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(0.0f, 411.0f, 750.0f, 466.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(0.0f, 411.0f, 750.0f, 466.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(0.0f, 441.0f, 720.0f, 436.0f)));
}

- (void)testShouldCalculateAWindowSSmallerCGRectWhenAgainstTheTopAndRightEdgesOfTheScreen
{
  CGRect visibleFrameSourceScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  CGRect visibleFrameDestinationScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  SpectacleWindowPositionCalculator *windowPositionCalculator = [[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *message) {
    XCTFail(@"%@", message);
  }];

  SpectacleWindowPositionCalculationResult *result = [windowPositionCalculator calculateWindowRect:CGRectMake(630.0f, 351.0f, 810.0f, 526.0f)
                                                                        visibleFrameOfSourceScreen:visibleFrameSourceScreen
                                                                   visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                                                            action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(660.0f, 381.0f, 780.0f, 496.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(660.0f, 381.0f, 780.0f, 496.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(690.0f, 411.0f, 750.0f, 466.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(690.0f, 411.0f, 750.0f, 466.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(720.0f, 441.0f, 720.0f, 436.0f)));
}

- (void)testShouldCalculateAWindowSSmallerCGRectWhenAgainstTheBottomAndLeftEdgesOfTheScreen
{
  CGRect visibleFrameSourceScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  CGRect visibleFrameDestinationScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  SpectacleWindowPositionCalculator *windowPositionCalculator = [[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *message) {
    XCTFail(@"%@", message);
  }];

  SpectacleWindowPositionCalculationResult *result = [windowPositionCalculator calculateWindowRect:CGRectMake(0.0f, 4.0f, 810.0f, 526.0f)
                                                                        visibleFrameOfSourceScreen:visibleFrameSourceScreen
                                                                   visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                                                            action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(0.0f, 4.0f, 780.0f, 496.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(0.0f, 4.0f, 780.0f, 496.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(0.0f, 4.0f, 750.0f, 466.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(0.0f, 4.0f, 750.0f, 466.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(0.0f, 4.0f, 720.0f, 436.0f)));
}

- (void)testShouldCalculateAWindowSSmallerCGRectWhenAgainstTheBottomAndRightEdgesOfTheScreen
{
  CGRect visibleFrameSourceScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  CGRect visibleFrameDestinationScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  SpectacleWindowPositionCalculator *windowPositionCalculator = [[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *message) {
    XCTFail(@"%@", message);
  }];

  SpectacleWindowPositionCalculationResult *result = [windowPositionCalculator calculateWindowRect:CGRectMake(630.0f, 4.0f, 810.0f, 526.0f)
                                                                        visibleFrameOfSourceScreen:visibleFrameSourceScreen
                                                                   visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                                                            action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(660.0f, 4.0f, 780.0f, 496.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(660.0f, 4.0f, 780.0f, 496.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(690.0f, 4.0f, 750.0f, 466.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(690.0f, 4.0f, 750.0f, 466.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(720.0f, 4.0f, 720.0f, 436.0f)));
}

- (void)testShouldCalculateAWindowSSmallerCGRectWhenAgainstTheTopAndBottomEdgesOfTheScreen
{
  CGRect visibleFrameSourceScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  CGRect visibleFrameDestinationScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  SpectacleWindowPositionCalculator *windowPositionCalculator = [[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *message) {
    XCTFail(@"%@", message);
  }];

  SpectacleWindowPositionCalculationResult *result = [windowPositionCalculator calculateWindowRect:CGRectMake(299.0f, 4.0f, 810.0f, 873.0f)
                                                                        visibleFrameOfSourceScreen:visibleFrameSourceScreen
                                                                   visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                                                            action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(314.0f, 4.0f, 780.0f, 873.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(314.0f, 4.0f, 780.0f, 873.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(329.0f, 4.0f, 750.0f, 873.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(329.0f, 4.0f, 750.0f, 873.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(344.0f, 4.0f, 720.0f, 873.0f)));
}

- (void)testShouldCalculateAWindowSSmallerCGRectWhenAgainstTheLeftAndRightEdgesOfTheScreen
{
  CGRect visibleFrameSourceScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  CGRect visibleFrameDestinationScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  SpectacleWindowPositionCalculator *windowPositionCalculator = [[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *message) {
    XCTFail(@"%@", message);
  }];

  SpectacleWindowPositionCalculationResult *result = [windowPositionCalculator calculateWindowRect:CGRectMake(0.0f, 240.0f, 1440.0f, 536.0f)
                                                                        visibleFrameOfSourceScreen:visibleFrameSourceScreen
                                                                   visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                                                            action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(0.0f, 255.0f, 1440.0f, 506.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(0.0f, 255.0f, 1440.0f, 506.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(0.0f, 270.0f, 1440.0f, 476.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(0.0f, 270.0f, 1440.0f, 476.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(0.0f, 285.0f, 1440.0f, 446.0f)));
}

- (void)testShouldCalculateAWindowSSmallerCGRectWhenAgainstAllEdgesOfTheScreen
{
  CGRect visibleFrameSourceScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  CGRect visibleFrameDestinationScreen = CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f);
  SpectacleWindowPositionCalculator *windowPositionCalculator = [[SpectacleWindowPositionCalculator alloc] initWithErrorHandler:^(NSString *message) {
    XCTFail(@"%@", message);
  }];

  SpectacleWindowPositionCalculationResult *result = [windowPositionCalculator calculateWindowRect:CGRectMake(0.0f, 4.0f, 1440.0f, 873.0f)
                                                                        visibleFrameOfSourceScreen:visibleFrameSourceScreen
                                                                   visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                                                            action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(15.0f, 19.0f, 1410.0f, 843.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(15.0f, 19.0f, 1410.0f, 843.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(30.0f, 34.0f, 1380.0f, 813.0f)));
  result = [windowPositionCalculator calculateWindowRect:CGRectMake(30.0f, 34.0f, 1380.0f, 813.0f)
                              visibleFrameOfSourceScreen:visibleFrameSourceScreen
                         visibleFrameOfDestinationScreen:visibleFrameDestinationScreen
                                                  action:kSpectacleWindowActionSmaller];
  XCTAssertTrue(CGRectEqualToRect(result.windowRect, CGRectMake(45.0f, 49.0f, 1350.0f, 783.0f)));
}

@end
