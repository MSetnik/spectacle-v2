#import "SpectacleQuantizedWindowMover.h"

#import "SpectacleAccessibilityElement.h"

@implementation SpectacleQuantizedWindowMover
{
  id<SpectacleWindowMover> _innerWindowMover;
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
}

@end
