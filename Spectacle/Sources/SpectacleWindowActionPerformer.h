#import <Foundation/Foundation.h>
#import "SpectacleWindowAction.h"

@protocol SpectacleWindowActionPerformer <NSObject>
- (void)performWindowAction:(SpectacleWindowAction *)action;
@end
