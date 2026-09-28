@import AppKit;
@import Foundation;

@interface POCAppDelegate : NSObject<NSApplicationDelegate>
@end
@implementation POCAppDelegate
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app {
  return YES;
}
@end

static void run(void) {
  NSViewController * vc = [NSViewController new];
  // vc.view = [NSViewDelegate new];

  NSWindow * w = [NSWindow new];
  w.acceptsMouseMovedEvents = YES;
  w.contentViewController = vc;
  w.styleMask = NSWindowStyleMaskClosable;

  NSRect crect = NSMakeRect(0, 0, 64, 64);
  NSRect frect = [w frameRectForContentRect:crect];
  [w setFrame:frect display:YES];
  [w center];
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

  NSApplication * a = [NSApplication sharedApplication];
  a.delegate = [POCAppDelegate new];
  a.mainMenu = bar;
  [a activateIgnoringOtherApps:YES];
  [a run];
}

int main() {
  @autoreleasepool {
    run();
  }
}
