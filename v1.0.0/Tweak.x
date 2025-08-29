#import <UIKit/UIKit.h>
#import "NavBarView.h"

// Fixed bar height (no prefs)
static const CGFloat kBarHeight = 40.0f;

// Forward declaration to avoid headers; we’ll call selectors if they exist.
@interface SpringBoard : UIApplication
- (void)_simulateHomeButtonPress;
@end

static UIWindow *abWindow;
static NavBarView *navView;

static void ABLayout(void) {
    if (!abWindow) return;
    CGRect screen = [UIScreen mainScreen].bounds;
    abWindow.frame  = CGRectMake(0, CGRectGetHeight(screen)-kBarHeight, CGRectGetWidth(screen), kBarHeight);
    navView.frame   = abWindow.bounds;
    [navView setNeedsLayout];
}

// Send user to Home using a best-effort private call on SpringBoard.
static void ABGoHome(void) {
    UIApplication *app = UIApplication.sharedApplication;
    if ([app isKindOfClass:%c(SpringBoard)] && [app respondsToSelector:@selector(_simulateHomeButtonPress)]) {
        // SpringBoard has a private method that simulates the Home button
        [(SpringBoard *)app _simulateHomeButtonPress];
        return;
    }
    // Fallback: try via selector (future-proof if class name changes)
    if ([app respondsToSelector:@selector(_simulateHomeButtonPress)]) {
        [app performSelector:@selector(_simulateHomeButtonPress)];
        return;
    }
    // Last resort: ask SpringBoard to activate itself (returns to the Home UI)
    [app activateIgnoringOtherApps:YES];
}

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg {
    %orig;

    CGRect s = [UIScreen mainScreen].bounds;
    abWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(s)-kBarHeight, CGRectGetWidth(s), kBarHeight)];
    abWindow.windowLevel = UIWindowLevelStatusBar + 2000;
    abWindow.backgroundColor = UIColor.clearColor;
    abWindow.userInteractionEnabled = YES;
    abWindow.hidden = NO;

    navView = [[NavBarView alloc] initWithFrame:abWindow.bounds];

    // Wire HOME action
    __weak typeof(navView) weakView = navView;
    navView.onHome = ^{
        (void)weakView; // keep capture alive
        ABGoHome();
    };

    [abWindow addSubview:navView];

    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification
                                                      object:nil queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(__unused NSNotification *n){ ABLayout(); }];

    ABLayout();
}
%end
