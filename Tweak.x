#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "NavBarView.h"

// Prefs
static NSString * const kPrefsPath = @"/var/mobile/Library/Preferences/space.mekabrine.androidbar15.plist";
static NSDictionary *ABPrefs() {
    return [NSDictionary dictionaryWithContentsOfFile:kPrefsPath] ?: @{};
}
static BOOL PrefEnabled(void) { return [ABPrefs()[@"Enabled"] ?: @YES boolValue]; }
static CGFloat PrefBarHeight(void) { return [[ABPrefs()[@"BarHeight"] ?: @40.0] floatValue]; }

// Switcher service (for Recents/Home-ish behavior)
@interface SBSwitcherSystemService : NSObject
+ (id)sharedInstance;
- (void)activateSwitcher;
- (void)activateSwitcherNoninteractively;
@end

static UIWindow *abWindow;
static NavBarView *navView;

static void ABUpdateUI(void) {
    if (!abWindow) return;
    BOOL on = PrefEnabled();
    CGFloat h = MAX(28.f, MIN(60.f, PrefBarHeight()));
    CGRect screen = [UIScreen mainScreen].bounds;
    abWindow.hidden = !on;
    abWindow.frame = CGRectMake(0, CGRectGetHeight(screen)-h, CGRectGetWidth(screen), h);
    navView.frame = abWindow.bounds;
    [navView setNeedsLayout];
}

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
    %orig;

    // Create window & bar
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat h = MAX(28.f, MIN(60.f, PrefBarHeight()));
    abWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(screen)-h, CGRectGetWidth(screen), h)];
    abWindow.windowLevel = UIWindowLevelStatusBar + 2000;
    abWindow.backgroundColor = UIColor.clearColor;
    abWindow.userInteractionEnabled = YES;
    abWindow.hidden = !PrefEnabled();

    navView = [[NavBarView alloc] initWithFrame:abWindow.bounds];
    [abWindow addSubview:navView];

    __weak typeof(self) weakSelf = self;
    navView.onBack = ^{ [weakSelf _ab_backAction]; };
    navView.onHome = ^{ [weakSelf _ab_homeAction]; };
    navView.onRecents = ^{ [weakSelf _ab_recentsAction]; };

    // Orientation/size changes
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(__unused NSNotification *n){
        ABUpdateUI();
    }];

    ABUpdateUI();
}
%new
- (void)_ab_recentsAction {
    Class svc = objc_getClass("SBSwitcherSystemService");
    if (svc && [svc respondsToSelector:@selector(sharedInstance)]) {
        id s = ((id (*)(id, SEL))objc_msgSend)(svc, @selector(sharedInstance));
        if ([s respondsToSelector:@selector(activateSwitcher)]) {
            ((void (*)(id, SEL))objc_msgSend)(s, @selector(activateSwitcher));
        }
    }
}
%new
- (void)_ab_homeAction {
    Class svc = objc_getClass("SBSwitcherSystemService");
    if (svc && [svc respondsToSelector:@selector(sharedInstance)]) {
        id s = ((id (*)(id, SEL))objc_msgSend)(svc, @selector(sharedInstance));
        if ([s respondsToSelector:@selector(activateSwitcherNoninteractively)]) {
            ((void (*)(id, SEL))objc_msgSend)(s, @selector(activateSwitcherNoninteractively));
        }
        if ([s respondsToSelector:@selector(activateSwitcher)]) {
            ((void (*)(id, SEL))objc_msgSend)(s, @selector(activateSwitcher));
        }
    }
}
%new
- (void)_ab_backAction {
    [self _ab_recentsAction];
}
%end
