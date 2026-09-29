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

@interface POCWindow : NSPanel
@end
@implementation POCWindow
@end

@interface POCAppDelegate : NSObject<NSApplicationDelegate>
- (void)blink:(id)e;
@end
@implementation POCAppDelegate
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app {
  return YES;
}
- (void)blink:(id)e {
  NSLog(@"ok");
}
@end

static POCWindow * w;
static void blink_upp() {
  [NSApp activateIgnoringOtherApps:YES];
  [w makeKeyAndOrderFront:w];
  NSLog(@"blink");
}

static int run(void) {
  POCView * v = [POCView new];

  NSViewController * vc = [NSViewController new];
  vc.view = v;

  w = [POCWindow new];
  w.acceptsMouseMovedEvents = YES;
  w.contentViewController = vc;
  w.styleMask = NSWindowStyleMaskClosable
    | NSWindowStyleMaskNonactivatingPanel
    ;
  // w.hidesOnDeactivate = NO;
  w.opaque = NO;
  w.backgroundColor = [w.backgroundColor colorWithAlphaComponent:0.3];
  // w.alphaValue = 0.6;
  // w.ignoresMouseEvents = YES;
  w.level = NSFloatingWindowLevel;
  w.floatingPanel = YES;
  // w.level = NSPopUpMenuWindowLevel;
  // w.level = NSScreenSaverWindowLevel;
  w.collectionBehavior = 0
    | NSWindowCollectionBehaviorTransient
    // | NSWindowCollectionBehaviorStationary
    | NSWindowCollectionBehaviorCanJoinAllSpaces
    | NSWindowCollectionBehaviorCanJoinAllApplications
    | NSWindowCollectionBehaviorFullScreenAuxiliary
    ;

  NSRect crect = NSMakeRect(30, 30, 512, 512);
  // NSRect crect = NSMakeRect(30, 30, 32, 32);
  NSRect frect = [w frameRectForContentRect:crect];
  [w setFrame:frect display:YES];
  [w makeKeyAndOrderFront:w];

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

  POCAppDelegate * del = [POCAppDelegate new];

  NSStatusItem * status = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
  status.behavior = NSStatusItemBehaviorTerminationOnRemoval;
  status.button.title = @"OK";
  status.button.target = del;
  status.button.action = @selector(blink:);

  EventTypeSpec event_type = {
    .eventClass = kEventClassKeyboard,
    .eventKind  = kEventHotKeyPressed,
  };
  EventHandlerUPP upp = NewEventHandlerUPP(blink_upp);
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
  if (err != noErr) {
        printf("hotkey registration failed: %d\n", (int)err);
    return 2;
  }

  NSApplication * a = [NSApplication sharedApplication];
  a.delegate = del;
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
