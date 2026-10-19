#import <Cocoa/Cocoa.h>
#import "SpectacleWindowAction.h"

@interface SpectacleShortcutsHistory : NSObject
- (CGRect)targetForAction:(SpectacleWindowAction *)action;
- (void)recordAction:(SpectacleWindowAction *)action before:(CGRect)before after:(CGRect)after;
@end
