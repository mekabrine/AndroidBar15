#import <UIKit/UIKit.h>
#import "NavBarView.h"

static NSString * const kPrefsPath = @"/var/mobile/Library/Preferences/space.mekabrine.androidbar15.plist";
static NSDictionary *ABPrefs(void) { return [NSDictionary dictionaryWithContentsOfFile:kPrefsPath] ?: @{}; }
static BOOL ABEnabled(void) { NSNumber *n = ABPrefs()[@"Enabled"]; return n ? n.boolValue : YES; }
static CGFloat ABHeight(void){ NSNumber *n = ABPrefs()[@"BarHeight"]; return n ? n.floatValue : 40.f; }
static CFStringRef const kReloadNote = CFSTR("space.mekabrine.androidbar15/ReloadPrefs");

static UIWindow *abWindow;
static NavBarView *navView;

static void ABLayout(void) {
    if (!abWindow) return;
    BOOL on = ABEnabled();
    CGFloat h = fmaxf(28.f, fminf(60.f, ABHeight()));
    CGRect screen = [UIScreen mainScreen].bounds;
    abWindow.hidden = !on;
    abWindow.frame  = CGRectMake(0, CGRectGetHeight(screen)-h, CGRectGetWidth(screen), h);
    navView.frame   = abWindow.bounds;
    [navView setNeedsLayout];
}

static void ABReloadCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    (void)center; (void)observer; (void)name; (void)object; (void)userInfo;
    dispatch_async(dispatch_get_main_queue(), ^{ ABLayout(); });
}

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)app {
    %orig;

    CGRect s = [UIScreen mainScreen].bounds;
    CGFloat h = fmaxf(28.f, fminf(60.f, ABHeight()));
    abWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(s)-h, CGRectGetWidth(s), h)];
    abWindow.windowLevel = UIWindowLevelStatusBar + 2000;
    abWindow.backgroundColor = UIColor.clearColor;
    abWindow.userInteractionEnabled = YES;
    abWindow.hidden = !ABEnabled();

    navView = [[NavBarView alloc] initWithFrame:abWindow.bounds];
    [abWindow addSubview:navView];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, ABReloadCallback,
        kReloadNote, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification
                                                      object:nil queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(__unused NSNotification *n){ ABLayout(); }];

    ABLayout();
}
%end
