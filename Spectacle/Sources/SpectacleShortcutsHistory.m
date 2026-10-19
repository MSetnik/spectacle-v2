#import "SpectacleShortcutsHistory.h"

@implementation SpectacleShortcutsHistory
{
  NSMutableArray<NSValue *> *_undo;
  NSMutableArray<NSValue *> *_redo;
}
- (instancetype)init
{
  if (self = [super init]) { _undo = [NSMutableArray new]; _redo = [NSMutableArray new]; }
  return self;
}
- (CGRect)targetForAction:(SpectacleWindowAction *)action
{
  NSValue *value = SpectacleIsUndoWindowAction(action) ? _undo.lastObject : _redo.lastObject;
  return value ? value.rectValue : CGRectNull;
}
- (void)recordAction:(SpectacleWindowAction *)action before:(CGRect)before after:(CGRect)after
{
  if (CGRectEqualToRect(before, after) || CGRectIsNull(before) || CGRectIsNull(after)) return;
  if (SpectacleIsUndoWindowAction(action)) {
    if (!_undo.count) return;
    [_undo removeLastObject];
    [_redo addObject:[NSValue valueWithRect:before]];
  } else if (SpectacleIsRedoWindowAction(action)) {
    if (!_redo.count) return;
    [_redo removeLastObject];
    [_undo addObject:[NSValue valueWithRect:before]];
  } else {
    [_undo addObject:[NSValue valueWithRect:before]];
    [_redo removeAllObjects];
  }
  if (_undo.count > 50) [_undo removeObjectAtIndex:0];
  if (_redo.count > 50) [_redo removeObjectAtIndex:0];
}
@end
