#import <Foundation/Foundation.h>

extern NSString *const SpectacleCompanionShortcutName;
extern NSString *const SpectacleShortcutsErrorDomain;
typedef NS_ENUM(NSInteger, SpectacleShortcutsErrorCode) {
  SpectacleShortcutsMissing = 1,
  SpectacleShortcutsAutomationDenied,
  SpectacleShortcutsExecutionFailed,
  SpectacleShortcutsInvalidResponse,
  SpectacleShortcutsTargetChanged,
};

typedef void (^SpectacleShortcutsCompletion)(NSDictionary *response, NSError *error);

@protocol SpectacleShortcutsTransport <NSObject>
- (void)executeRequest:(NSDictionary *)request completion:(SpectacleShortcutsCompletion)completion;
@end

@interface SpectacleShortcutsBridge : NSObject <SpectacleShortcutsTransport>
+ (NSDictionary *)validatedResponse:(id)value requestID:(NSString *)requestID error:(NSError **)error;
@end
