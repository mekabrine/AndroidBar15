#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "NavBarView.h"

// Let the compiler know these methods exist on SpringBoard.
@interface SpringBoard : UIApplication
- (void)_ab_recentsAction;
- (void)_ab_homeAction;
- (void)_ab_backAction;
@end

// Prefs
static NSString * const kPrefsPath = @"/var/mobile/Library/Preferences/space.mekabrine.androidbar15.plist";
static NSDictionary *ABPrefs(void) {
    NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:kPrefsPath];
    return d ?: @{};
}
static BOOL PrefEnabled(void) {
    NSNumber *n = ABPrefs()[@"Enabled"];
    return n ? n.boolValue : YES;
}
static CGFloat PrefBarHeight(void) {
    NSNumber *n = ABPrefs()[@"BarHeight"];
    return n ? n.floatValue : 40.0f;
}

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
    CGFloat h = fmaxf(28.f, fminf(60.f, PrefBarHeight()));
    CGRect screen = [UIScreen mainScreen].bounds;
    abWindow.hidden = !on;
    abWindow.frame = CGRectMake(0, CGRectGetHeight(screen)-h, CGRectGetWidth(screen), h);
    navView.frame = abWindow.bounds;
    [navView setNeedsLayout];
}

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
    %orig;

    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat h = fmaxf(28.f, fminf(60.f, PrefBarHeight()));
    abWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(screen)-h, CGRectGetWidth(screen), h)];
    abWindow.windowLevel = UIWindowLevelStatusBar + 2000;
    abWindow.backgroundColor = UIColor.clearColor;
    abWindow.userInteractionEnabled = YES;
    abWindow.hidden = !PrefEnabled();

    navView = [[NavBarView alloc] initWithFrame:abWindow.bounds];
    [abWindow addSubview:navView];

    __weak SpringBoard *weakSelf = (SpringBoard *)self;
    navView.onBack    = ^{ [(SpringBoard *)weakSelf _ab_backAction];    };
    navView.onHome    = ^{ [(SpringBoard *)weakSelf _ab_homeAction];    };
    navView.onRecents = ^{ [(SpringBoard *)weakSelf _ab_recentsAction]; };

    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification
                                                      object:nil queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(__unused NSNotification *n){ ABUpdateUI(); }];

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
