#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "NavBarView.h"

static UIWindow *barWindow;
static NavBarView *navView;

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
    %orig;

    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat barHeight = 40.0;
    barWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(screen)-barHeight, CGRectGetWidth(screen), barHeight)];
    barWindow.windowLevel = UIWindowLevelStatusBar + 2000;
    barWindow.backgroundColor = UIColor.clearColor;
    barWindow.hidden = NO;
    barWindow.userInteractionEnabled = YES;

    navView = [[NavBarView alloc] initWithFrame:barWindow.bounds];
    [barWindow addSubview:navView];
}
%end
