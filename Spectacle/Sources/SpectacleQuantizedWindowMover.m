#import "SpectacleQuantizedWindowMover.h"

#import "SpectacleAccessibilityElement.h"

@implementation SpectacleQuantizedWindowMover
{
  id<SpectacleWindowMover> _innerWindowMover;
  NSUInteger _resizeGeneration;
}

// An AX client can report the old size until its own event loop processes the
// resize. Keep trying briefly, but never let a queued snap affect a new focus.
- (void)finishDeferredGrowthOfElement:(SpectacleAccessibilityElement *)element
                            targetRect:(CGRect)targetRect
                            generation:(NSUInteger)generation
                               attempt:(NSUInteger)attempt
                         stagnantReads:(NSUInteger)stagnantReads
                          previousSize:(CGSize)previousSize
{
  if (generation != _resizeGeneration || attempt >= 24 || stagnantReads >= 8
      || ![element isFocusedWindow]) return;

  CGRect current = [element rectOfElement];
  if (CGRectIsNull(current)) return;
  if (current.size.width >= targetRect.size.width && current.size.height >= targetRect.size.height) {
    if (!CGPointEqualToPoint(current.origin, targetRect.origin)) {
      [element setPositionOfElement:targetRect.origin];
    }
    return;
  }

  NSUInteger nextStagnantReads = CGSizeEqualToSize(current.size, previousSize) ? stagnantReads + 1 : 0;
  if (nextStagnantReads >= 8) return;
  [element setSizeOfElement:targetRect.size];
  if (!CGPointEqualToPoint(current.origin, targetRect.origin)) {
    [element setPositionOfElement:targetRect.origin];
  }
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 40 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
    [self finishDeferredGrowthOfElement:element targetRect:targetRect generation:generation
                                attempt:attempt + 1 stagnantReads:nextStagnantReads
                           previousSize:current.size];
  });
}

- (instancetype)initWithInnerWindowMover:(id<SpectacleWindowMover>)innerWindowMover
{
  if (self = [super init]) {
    _innerWindowMover = innerWindowMover;
  }
  return self;
}

- (instancetype)init
{
  return [self initWithInnerWindowMover:nil];
}

+ (instancetype)newWithInnerWindowMover:(id<SpectacleWindowMover>)innerWindowMover
{
  return [[self alloc] initWithInnerWindowMover:innerWindowMover];
}

- (void)moveWindowRect:(CGRect)windowRect
         frameOfScreen:(CGRect)frameOfScreen
  visibleFrameOfScreen:(CGRect)visibleFrameOfScreen
frontmostWindowElement:(SpectacleAccessibilityElement *)frontmostWindowElement
                action:(SpectacleWindowAction *)action
{
  NSUInteger generation = ++_resizeGeneration;
  CGRect movedWindowRect = [frontmostWindowElement rectOfElement];
  if (CGRectIsNull(movedWindowRect)) return;

  // Some apps accept only part of a large resize per AX request. Finish that
  // growth within this action, after moving to the destination origin.
  if (movedWindowRect.size.width < windowRect.size.width || movedWindowRect.size.height < windowRect.size.height) {
    [frontmostWindowElement setPositionOfElement:windowRect.origin];
    for (NSUInteger attempt = 0; attempt < 8; attempt++) {
      CGSize previousSize = movedWindowRect.size;
      [frontmostWindowElement setSizeOfElement:windowRect.size];
      movedWindowRect = [frontmostWindowElement rectOfElement];
      if (CGRectIsNull(movedWindowRect)) return;
      if ((movedWindowRect.size.width >= windowRect.size.width && movedWindowRect.size.height >= windowRect.size.height)
          || CGSizeEqualToSize(previousSize, movedWindowRect.size)) break;
    }
  }

  // Quantization correction applies only when the app made the window too large.
  // Centering an undersized window here made each subsequent snap grow in steps.
  if (movedWindowRect.size.width > windowRect.size.width || movedWindowRect.size.height > windowRect.size.height) {
    CGRect adjustedWindowRect = windowRect;
    NSUInteger attempts = 0;
    NSUInteger unchangedAttempts = 0;
    while ((movedWindowRect.size.width > windowRect.size.width || movedWindowRect.size.height > windowRect.size.height)
           && attempts++ < 8) {
      if (movedWindowRect.size.width > windowRect.size.width) {
        adjustedWindowRect.size.width -= 2;
      }
      if (movedWindowRect.size.height > windowRect.size.height) {
        adjustedWindowRect.size.height -= 2;
      }
      if (adjustedWindowRect.size.width < windowRect.size.width * 0.85f || adjustedWindowRect.size.height < windowRect.size.height * 0.85f) {
        break;
      }
      CGSize previousSize = movedWindowRect.size;
      [frontmostWindowElement setRectOfElement:adjustedWindowRect];
      movedWindowRect = [frontmostWindowElement rectOfElement];
      unchangedAttempts = CGSizeEqualToSize(previousSize, movedWindowRect.size) ? unchangedAttempts + 1 : 0;
      if (unchangedAttempts >= 2 || CGRectIsNull(movedWindowRect)) break;
    }
    if (CGRectIsNull(movedWindowRect)) return;
    adjustedWindowRect.origin.x += floor((windowRect.size.width - movedWindowRect.size.width) / 2.0f);
    adjustedWindowRect.origin.y += floor((windowRect.size.height - movedWindowRect.size.height) / 2.0f);
    [frontmostWindowElement setRectOfElement:adjustedWindowRect];
  } else if (!CGPointEqualToPoint(movedWindowRect.origin, windowRect.origin)) {
    [frontmostWindowElement setPositionOfElement:windowRect.origin];
  }
  [_innerWindowMover moveWindowRect:windowRect
                      frameOfScreen:frameOfScreen
               visibleFrameOfScreen:visibleFrameOfScreen
             frontmostWindowElement:frontmostWindowElement
                             action:action];

  movedWindowRect = [frontmostWindowElement rectOfElement];
  if (!CGRectIsNull(movedWindowRect)
      && (movedWindowRect.size.width < windowRect.size.width
          || movedWindowRect.size.height < windowRect.size.height)) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 40 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
      [self finishDeferredGrowthOfElement:frontmostWindowElement targetRect:windowRect
                              generation:generation attempt:0 stagnantReads:0
                             previousSize:movedWindowRect.size];
    });
  }
}

@end
