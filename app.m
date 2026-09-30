@import AppKit;
@import Carbon;
@import Foundation;

@interface POCView : NSView
@property (nonatomic,strong) NSMutableArray * paths;
@property (nonatomic,strong) NSBezierPath * curpath;
@end
@implementation POCView
- (BOOL)isOpaque { return NO; }

- (void)mouseDown:(NSEvent *)e {
  NSPoint point = [self convertPoint:e.locationInWindow fromView:nil];

  self.curpath = [NSBezierPath new];
  self.curpath.lineWidth = 3.0;
  self.curpath.lineCapStyle = NSLineCapStyleRound;
  [self.curpath moveToPoint:point];
}
- (void)mouseDragged:(NSEvent *)e {
  if (!self.curpath) return;

  NSPoint point = [self convertPoint:e.locationInWindow fromView:nil];
  [self.curpath lineToPoint:point];
  self.needsDisplay = YES;
}
- (void)mouseUp:(NSEvent *)e {
  if (!self.curpath) return;
  if (!self.paths) self.paths = [NSMutableArray new];
  [self.paths addObject:self.curpath];
  self.curpath = nil;
}

- (void)drawRect:(NSRect)rect {
  [super drawRect:rect];

  [[NSColor clearColor] setFill];
  NSRectFill(rect);

  [[NSColor redColor] setStroke];
  for (NSBezierPath * path in self.paths) [path stroke];

  if (self.curpath) [self.curpath stroke];
}
@end

static NSPanel * g_sketchpad;
static void toggle_sketchpad() {
  if (g_sketchpad) {
    [g_sketchpad close];
    g_sketchpad = nil;
    return;
  }

  NSViewController * vc = [NSViewController new];
  vc.view = [POCView new];

  NSPanel * w = g_sketchpad = [NSPanel new];
  w.acceptsMouseMovedEvents = YES;
  w.contentViewController = vc;
  w.styleMask = 0
    | NSWindowStyleMaskClosable
    | NSWindowStyleMaskNonactivatingPanel
    ;
  w.opaque = NO;
  w.backgroundColor = [w.backgroundColor colorWithAlphaComponent:0.3];
  w.level = NSFloatingWindowLevel;
  w.floatingPanel = YES;
  w.collectionBehavior = 0
    | NSWindowCollectionBehaviorTransient
    | NSWindowCollectionBehaviorCanJoinAllSpaces
    | NSWindowCollectionBehaviorCanJoinAllApplications
    | NSWindowCollectionBehaviorFullScreenAuxiliary
    ;

  NSRect frect = [w screen].frame;
  [w setFrame:frect display:YES];
  [w makeKeyAndOrderFront:w];

  [NSApp activateIgnoringOtherApps:YES];
}

@interface POCActionPanel : NSPanel
@end

static NSPanel * g_actionpanel;
static void toggle_actionpanel() {
  if (g_actionpanel) {
    [g_actionpanel close];
    g_actionpanel = nil;
    return;
  }

  NSPanel * w = g_actionpanel = [POCActionPanel new];
  w.level = NSFloatingWindowLevel;
  w.floatingPanel = YES;
  w.collectionBehavior = 0
    | NSWindowCollectionBehaviorTransient
    | NSWindowCollectionBehaviorCanJoinAllSpaces
    | NSWindowCollectionBehaviorCanJoinAllApplications
    | NSWindowCollectionBehaviorFullScreenAuxiliary
    ;

  NSRect frect = CGRectMake(30, 30, 32, 32);
  [w setFrame:frect display:YES];
  [w makeKeyAndOrderFront:w];

  [NSApp activateIgnoringOtherApps:YES];
}

@implementation POCActionPanel
- (BOOL)canBecomeKeyWindow {
  return YES;
}
- (BOOL)acceptsFirstResponder {
  return YES;
}
- (void)keyDown:(NSEvent *)e {
  NSString * chrs = e.charactersIgnoringModifiers;
  if (chrs.length != 1) return;

  unichar c = [chrs characterAtIndex:0];
  switch (c) {
    case ' ': toggle_sketchpad(); break;
    default: NSLog(@"keydown: %@", e); break;
  }

  toggle_actionpanel();
}
@end

static int run(void) {
  // Apple menu
  NSMenuItem * quit = [[NSMenuItem alloc] initWithTitle:@"Quit deckie"
                                                 action:@selector(terminate:)
                                          keyEquivalent:@"q"];

  NSMenu * menu = [NSMenu new];
  [menu addItem:quit];

  NSMenuItem * item = [NSMenuItem new];
  item.submenu = menu;

  NSMenu * bar = [NSMenu new];
  [bar addItem:item];

  EventTypeSpec event_type = {
    .eventClass = kEventClassKeyboard,
    .eventKind  = kEventHotKeyPressed,
  };
  EventHandlerUPP upp = NewEventHandlerUPP(toggle_actionpanel);
  if (noErr != InstallApplicationEventHandler(upp, 1, &event_type, NULL, NULL)) {
    return 1;
  }

  EventHotKeyID hk_id = {
    .signature = 0xcafe,
    .id        = 0xbeba,
  };
  EventHotKeyRef ref = NULL;
  OSStatus err = RegisterEventHotKey(
      kVK_ANSI_Grave,
      cmdKey | shiftKey,
      hk_id,
      GetApplicationEventTarget(),
      kEventHotKeyNoOptions,
      &ref);
  if (err != noErr) return 2;

  NSApplication * a = [NSApplication sharedApplication];
  a.mainMenu = bar;
  [a activateIgnoringOtherApps:YES];
  [a run];
  return 0;
}

int main() {
  @autoreleasepool {
    return run();
  }
}
