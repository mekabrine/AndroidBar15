#import <UIKit/UIKit.h>
#import "NavBarView.h"

static const CGFloat kBarHeight = 40.0f;

static UIWindow *abWindow;
static NavBarView *navView;

static void ABLayout(void) {
    if (!abWindow) return;
    CGRect screen = [UIScreen mainScreen].bounds;
    abWindow.frame  = CGRectMake(0, CGRectGetHeight(screen)-kBarHeight, CGRectGetWidth(screen), kBarHeight);
    navView.frame   = abWindow.bounds;
    [navView setNeedsLayout];
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
    [abWindow addSubview:navView];

    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification
                                                      object:nil queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(__unused NSNotification *n){ ABLayout(); }];

    ABLayout();
}
%end
