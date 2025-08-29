#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface ABBarWindow : UIWindow
- (instancetype)initOverlay;
@end

static ABBarWindow *ABSharedWindow;

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!ABSharedWindow) {
            ABSharedWindow = [[%c(ABBarWindow) alloc] initOverlay];
            [ABSharedWindow makeKeyAndVisible];
        }
    });
}
%end

// Disable system Home/App Switcher gestures globally by telling the system they are deferred
%hook UIScreenEdgePanGestureRecognizer
- (BOOL)_shouldReceiveTouch:(id)touch forEvent:(id)event recognizerView:(id)view {
    // Block left/right/bottom edge pans that would trigger system gestures
    return NO;
}
%end