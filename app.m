@import AppKit;
@import Carbon;
@import Foundation;

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

static void blink_upp() {
  NSLog(@"okay");
}

static int run(void) {
  NSViewController * vc = [NSViewController new];
  // vc.view = [NSViewDelegate new];

  POCWindow * w = [POCWindow new];
  w.acceptsMouseMovedEvents = YES;
  w.contentViewController = vc;
  w.styleMask = NSWindowStyleMaskClosable;
  w.level = kCGMainMenuWindowLevel - 1;
  w.hidesOnDeactivate = NO;
  w.collectionBehavior =
    NSWindowCollectionBehaviorTransient |
    NSWindowCollectionBehaviorStationary |
    NSWindowCollectionBehaviorCanJoinAllSpaces |
    NSWindowCollectionBehaviorCanJoinAllApplications |
    NSWindowCollectionBehaviorFullScreenAuxiliary;

  NSRect crect = NSMakeRect(30, 30, 64, 64);
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
