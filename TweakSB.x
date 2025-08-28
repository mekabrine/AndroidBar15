#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "NavBarView.h"

// Prefs
static NSString * const kPrefsPath = @"/var/mobile/Library/Preferences/space.mekabrine.androidbar15.plist";
static CFStringRef const kReloadNote = CFSTR("space.mekabrine.androidbar15/ReloadPrefs");
static NSDictionary *ABPrefs(void) { return [NSDictionary dictionaryWithContentsOfFile:kPrefsPath] ?: @{}; }
static BOOL ABEnabled(void) { NSNumber *n = ABPrefs()[@"Enabled"]; return n ? n.boolValue : YES; }
static CGFloat ABHeight(void){ NSNumber *n = ABPrefs()[@"BarHeight"]; return n ? n.floatValue : 40.f; }

// Switcher/Home private
@interface SBSwitcherSystemService : NSObject
+ (id)sharedInstance;
- (void)activateSwitcher;
- (void)activateSwitcherNoninteractively;
@end

// SpringBoard category we call
@interface SpringBoard : UIApplication
- (void)_ab_recentsAction;
- (void)_ab_homeAction;
- (void)_ab_backAction;
@end

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

static void ABPostDarwin(CFStringRef name) {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), name, NULL, NULL, true);
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

    __weak SpringBoard *weakSelf = (SpringBoard *)self;
    navView.onBack    = ^{ [(SpringBoard *)weakSelf _ab_backAction];    };
    navView.onHome    = ^{ [(SpringBoard *)weakSelf _ab_homeAction];    };
    navView.onRecents = ^{ [(SpringBoard *)weakSelf _ab_recentsAction]; };

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, ^(CFNotificationCenterRef, void *observer, CFStringRef name, const void *, CFDictionaryRef){
        dispatch_async(dispatch_get_main_queue(), ^{ ABLayout(); });
    }, kReloadNote, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(__unused NSNotification *n){ ABLayout(); }];

    ABLayout();
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
    ABPostDarwin(CFSTR("space.mekabrine.androidbar15/RECENTS"));
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
    ABPostDarwin(CFSTR("space.mekabrine.androidbar15/HOME"));
}
%new
- (void)_ab_backAction {
    ABPostDarwin(CFSTR("space.mekabrine.androidbar15/BACK"));
}
%end
