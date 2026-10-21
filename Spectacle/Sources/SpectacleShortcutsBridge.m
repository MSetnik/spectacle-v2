#import "SpectacleShortcutsBridge.h"
@import ScriptingBridge;

NSString *const SpectacleCompanionShortcutName = @"Spectacle Window Bridge";
NSString *const SpectacleShortcutsErrorDomain = @"SpectacleShortcutsError";

// Public Shortcuts scripting interface, documented in WWDC21 session 10232.
@protocol SpectacleShortcutsEvents
- (SBElementArray *)shortcuts;
@end
@protocol SpectacleScriptableShortcut
@property (copy, readonly) NSString *name;
- (id)runWithInput:(id)input;
@end

static NSError *bridgeError(SpectacleShortcutsErrorCode code, NSString *description)
{
  return [NSError errorWithDomain:SpectacleShortcutsErrorDomain code:code
                        userInfo:@{NSLocalizedDescriptionKey: description}];
}

@interface SpectacleShortcutsBridge () <SBApplicationDelegate>
@end

@implementation SpectacleShortcutsBridge
{
  dispatch_queue_t _queue;
  NSError *_eventError;
}

- (instancetype)init
{
  if (self = [super init]) {
    _queue = dispatch_queue_create("io.github.msetnik.Spectacle.shortcuts", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

- (id)eventDidFail:(const AppleEvent *)event withError:(NSError *)error
{
  _eventError = error;
  return nil;
}

- (void)executeRequest:(NSDictionary *)request completion:(SpectacleShortcutsCompletion)completion
{
  // SBApplication is synchronous. Keep both the proxy and its errors on one worker queue.
  NSDictionary *immutableRequest = [request copy];
  dispatch_async(_queue, ^{
    @autoreleasepool {
      self->_eventError = nil;
      NSError *error = nil;
      NSDictionary *response = nil;
      NSData *data = [NSJSONSerialization dataWithJSONObject:immutableRequest options:0 error:&error];
      if (data) {
        SBApplication<SpectacleShortcutsEvents> *events =
          (id)[SBApplication applicationWithBundleIdentifier:@"com.apple.shortcuts.events"];
        events.delegate = self;
        events.timeout = 60 * 30; // Apple Event timeout is measured in ticks, not seconds.
        // Shortcuts permits duplicate names, and its name specifier may resolve
        // one arbitrarily or fail with -1728. Never run an ambiguous workflow.
        SBObject<SpectacleScriptableShortcut> *shortcut = nil;
        NSUInteger matches = 0;
        for (SBObject<SpectacleScriptableShortcut> *candidate in events.shortcuts) {
          if ([candidate.name isEqualToString:SpectacleCompanionShortcutName]) {
            shortcut = candidate;
            matches++;
          }
        }
        if (matches > 1) {
          error = bridgeError(SpectacleShortcutsAmbiguous,
                              @"Multiple Spectacle Window Bridge shortcuts have the same name. Keep one copy in Shortcuts, then verify the connection again.");
        } else if (!events || !matches || ![shortcut get]) {
          error = bridgeError(SpectacleShortcutsMissing,
                              @"Install the Spectacle Window Bridge shortcut, keeping its original name.");
        } else {
          id output = [shortcut runWithInput:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
          response = [SpectacleShortcutsBridge validatedResponse:output
                                                      requestID:immutableRequest[@"requestID"] error:&error];
        }
        if (self->_eventError) {
          BOOL denied = self->_eventError.code == -1743;
          BOOL missing = self->_eventError.code == -1728;
          error = bridgeError(missing ? SpectacleShortcutsMissing : (denied ? SpectacleShortcutsAutomationDenied : SpectacleShortcutsExecutionFailed),
                              missing ? @"Install the Spectacle Window Bridge shortcut, keeping its original name." :
                              denied ? @"Allow Spectacle to control Shortcuts in System Settings → Privacy & Security → Automation."
                                     : @"Shortcuts could not finish the request. Check its permissions and try again. Pending commands were cancelled.");
          response = nil;
        }
      }
      if (error) {
        NSLog(@"Shortcuts bridge %@ failed (%@:%ld)", immutableRequest[@"operation"],
              error.domain, (long)error.code);
      } else if ([immutableRequest[@"operation"] isEqual:@"probe"]) {
        NSLog(@"Shortcuts bridge probe succeeded");
      }
      dispatch_async(dispatch_get_main_queue(), ^{ completion(response, error); });
    }
  });
}

+ (NSDictionary *)validatedResponse:(id)value requestID:(NSString *)requestID error:(NSError **)error
{
  if ([value isKindOfClass:NSArray.class] && [value count] == 1) value = [value firstObject];
  if ([value isKindOfClass:NSString.class]) value = [value dataUsingEncoding:NSUTF8StringEncoding];
  if ([value isKindOfClass:NSData.class]) value = [NSJSONSerialization JSONObjectWithData:value options:0 error:nil];
  if (![value isKindOfClass:NSDictionary.class]
      || ![value[@"protocol"] isEqual:@2]
      || ![value[@"requestID"] isKindOfClass:NSString.class]
      || ![value[@"requestID"] isEqual:requestID]
      || ![value[@"status"] isKindOfClass:NSString.class]) {
    if (error) *error = bridgeError(SpectacleShortcutsInvalidResponse,
                                    @"The companion Shortcut is incompatible or returned an incomplete result. Reinstall it using Set Up Window Control.");
    return nil;
  }
  if (![value[@"status"] isEqual:@"ok"]) {
    if (error) *error = bridgeError(SpectacleShortcutsTargetChanged,
                                    @"The window changed or could not be identified uniquely. Focus the window and try again.");
    return nil;
  }
  return value;
}
@end
