#import <Cocoa/Cocoa.h>

// Window Server metadata only: no screenshots, titles, or cross-application AX calls.
@interface SpectacleWindowSnapshot : NSObject
@property (nonatomic, readonly) CGWindowID windowID;
@property (nonatomic, readonly) pid_t processIdentifier;
@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, readonly, copy) NSString *appName;
@property (nonatomic, readonly, copy) NSString *identity;
+ (instancetype)frontmostWindow;
+ (instancetype)refreshSnapshot:(SpectacleWindowSnapshot *)snapshot;
+ (instancetype)snapshotFromWindows:(NSArray<NSDictionary *> *)windows
                   processIdentifier:(pid_t)pid windowID:(CGWindowID)windowID
                             appName:(NSString *)appName launchDate:(NSDate *)launchDate;
+ (CGRect)flipRect:(CGRect)rect primaryScreenHeight:(CGFloat)height;
@end
