#import "SpectacleLoginItemHelper.h"
#if SPECTACLE_STORE
@import ServiceManagement;
@import AppKit;
#endif

@implementation SpectacleLoginItemHelper

#if SPECTACLE_STORE
+ (BOOL)isLoginItemEnabledForBundle:(NSBundle *)bundle
{
  return SMAppService.mainAppService.status == SMAppServiceStatusEnabled;
}

+ (void)enableLoginItemForBundle:(NSBundle *)bundle
{
  NSError *error = nil;
  if (![SMAppService.mainAppService registerAndReturnError:&error]) {
    [[NSAlert alertWithError:error] runModal];
  } else if (SMAppService.mainAppService.status == SMAppServiceStatusRequiresApproval) {
    [SMAppService openSystemSettingsLoginItems];
  }
}

+ (void)disableLoginItemForBundle:(NSBundle *)bundle
{
  NSError *error = nil;
  if (![SMAppService.mainAppService unregisterAndReturnError:&error]) {
    [[NSAlert alertWithError:error] runModal];
  }
}
#else
+ (BOOL)isLoginItemEnabledForBundle:(NSBundle *)bundle
{
  LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
  NSString *applicationPath = bundle.bundlePath;
  BOOL result = NO;
  if (sharedFileList) {
    UInt32 seedValue;
    NSArray *sharedFileListArray = CFBridgingRelease(LSSharedFileListCopySnapshot(sharedFileList, &seedValue));
    for (id sharedFile in sharedFileListArray) {
      LSSharedFileListItemRef sharedFileListItem = (__bridge LSSharedFileListItemRef)sharedFile;
      CFURLRef applicationPathURL = NULL;
      LSSharedFileListItemResolve(sharedFileListItem, 0, (CFURLRef *)&applicationPathURL, NULL);
      if (applicationPathURL != NULL) {
        NSString *resolvedApplicationPath = [(__bridge NSURL *)applicationPathURL path];
        CFRelease(applicationPathURL);
        if ([resolvedApplicationPath compare:applicationPath] == NSOrderedSame) {
          result = YES;
          break;
        }
      }
    }
    CFRelease(sharedFileList);
  } else {
    NSLog(@"Unable to create the shared file list.");
  }
  return result;
}

+ (void)enableLoginItemForBundle:(NSBundle *)bundle
{
  LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
  NSString *applicationPath = bundle.bundlePath;
  NSURL *applicationPathURL = [NSURL fileURLWithPath:applicationPath];
  if (sharedFileList) {
    LSSharedFileListItemRef sharedFileListItem = LSSharedFileListInsertItemURL(sharedFileList,
                                                                               kLSSharedFileListItemLast,
                                                                               NULL,
                                                                               NULL,
                                                                               (__bridge CFURLRef)applicationPathURL,
                                                                               NULL,
                                                                               NULL);
    if (sharedFileListItem) {
      CFRelease(sharedFileListItem);
    }
    CFRelease(sharedFileList);
  } else {
    NSLog(@"Unable to create the shared file list.");
  }
}

+ (void)disableLoginItemForBundle:(NSBundle *)bundle
{
  LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
  NSString *applicationPath = bundle.bundlePath;
  if (sharedFileList) {
    UInt32 seedValue;
    NSArray *sharedFileListArray = CFBridgingRelease(LSSharedFileListCopySnapshot(sharedFileList, &seedValue));
    for (id sharedFile in sharedFileListArray) {
      LSSharedFileListItemRef sharedFileListItem = (__bridge LSSharedFileListItemRef)sharedFile;
      CFURLRef applicationPathURL;
      if (LSSharedFileListItemResolve(sharedFileListItem, 0, &applicationPathURL, NULL) == noErr) {
        NSString *resolvedApplicationPath = [(__bridge NSURL *)applicationPathURL path];
        if ([resolvedApplicationPath compare:applicationPath] == NSOrderedSame) {
          LSSharedFileListItemRemove(sharedFileList, sharedFileListItem);
        }
        CFRelease(applicationPathURL);
      }
    }
    CFRelease(sharedFileList);
  } else {
    NSLog(@"Unable to create the shared file list.");
  }
}

#endif
@end
