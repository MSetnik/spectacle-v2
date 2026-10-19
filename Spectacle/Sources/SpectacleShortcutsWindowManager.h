#import <Cocoa/Cocoa.h>
#import "SpectacleWindowActionPerformer.h"
#import "SpectacleShortcutsBridge.h"
#import "SpectacleWindowSnapshot.h"

@class SpectacleWindowPositionCalculator;

@interface SpectacleShortcutsWindowManager : NSObject <SpectacleWindowActionPerformer>
- (instancetype)initWithCalculator:(SpectacleWindowPositionCalculator *)calculator;
- (instancetype)initWithCalculator:(SpectacleWindowPositionCalculator *)calculator
                         transport:(id<SpectacleShortcutsTransport>)transport
                  snapshotProvider:(SpectacleWindowSnapshot *(^)(void))snapshotProvider
                   refreshProvider:(SpectacleWindowSnapshot *(^)(SpectacleWindowSnapshot *))refreshProvider
                   screensProvider:(NSArray<NSScreen *> *(^)(void))screensProvider
                    failureHandler:(void (^)(NSError *))failureHandler;
- (void)showSetup;
- (CGRect)targetFrameForAction:(SpectacleWindowAction *)action windowFrame:(CGRect)windowFrame
                      screens:(NSArray<NSScreen *> *)screens;
@end
