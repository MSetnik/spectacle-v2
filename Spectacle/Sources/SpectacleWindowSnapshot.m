#import "SpectacleWindowSnapshot.h"
@import CoreGraphics;

@implementation SpectacleWindowSnapshot

+ (instancetype)frontmostWindow
{
  NSRunningApplication *app = NSWorkspace.sharedWorkspace.frontmostApplication;
  if (!app || app.processIdentifier == NSProcessInfo.processInfo.processIdentifier) return nil;
  return [self snapshotForApplication:app windowID:kCGNullWindowID];
}

+ (instancetype)snapshotForApplication:(NSRunningApplication *)app windowID:(CGWindowID)windowID
{
  NSArray *windows = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly |
                                                                 kCGWindowListExcludeDesktopElements, kCGNullWindowID));
  return [self snapshotFromWindows:windows processIdentifier:app.processIdentifier windowID:windowID
                          appName:app.localizedName launchDate:app.launchDate];
}

+ (instancetype)refreshSnapshot:(SpectacleWindowSnapshot *)snapshot
{
  NSRunningApplication *app = [NSRunningApplication runningApplicationWithProcessIdentifier:snapshot.processIdentifier];
  if (!app) return nil;
  SpectacleWindowSnapshot *fresh = [self snapshotForApplication:app windowID:snapshot.windowID];
  return [fresh.identity isEqual:snapshot.identity] ? fresh : nil;
}

+ (instancetype)snapshotFromWindows:(NSArray<NSDictionary *> *)windows
                   processIdentifier:(pid_t)pid windowID:(CGWindowID)windowID
                             appName:(NSString *)appName launchDate:(NSDate *)launchDate
{
  if (appName.length == 0 || !launchDate) return nil;
  for (NSDictionary *info in windows) {
    if ([info[(__bridge NSString *)kCGWindowOwnerPID] intValue] != pid
        || [info[(__bridge NSString *)kCGWindowLayer] integerValue] != 0
        || [info[(__bridge NSString *)kCGWindowAlpha] doubleValue] <= 0) continue;
    CGWindowID candidateID = [info[(__bridge NSString *)kCGWindowNumber] unsignedIntValue];
    if (windowID && windowID != candidateID) continue;
    CGRect frame = CGRectNull;
    NSDictionary *bounds = info[(__bridge NSString *)kCGWindowBounds];
    if (![bounds isKindOfClass:NSDictionary.class]
        || !CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)bounds, &frame)
        || CGRectIsEmpty(frame) || CGRectIsInfinite(frame)
        || !isfinite(frame.origin.x) || !isfinite(frame.origin.y)) continue;
    // Some apps put tiny layer-zero overlays ahead of their document window in the
    // Window Server list. Only apply this guard when choosing a new target; a
    // previously captured window ID must remain refreshable at any valid size.
    if (!windowID && (frame.size.width < 100 || frame.size.height < 100)) continue;
    SpectacleWindowSnapshot *result = [self new];
    result->_windowID = candidateID;
    result->_processIdentifier = pid;
    result->_frame = frame;
    result->_appName = [appName copy];
    result->_identity = [NSString stringWithFormat:@"%d:%.6f:%u", pid, launchDate.timeIntervalSince1970, candidateID];
    return result;
  }
  return nil;
}

+ (CGRect)flipRect:(CGRect)rect primaryScreenHeight:(CGFloat)height
{
  // Both AX and CG use a top-left origin; AppKit geometry uses the primary screen's bottom-left.
  rect.origin.y = height - CGRectGetMaxY(rect);
  return rect;
}
@end
