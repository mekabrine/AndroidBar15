#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

// Prefs
static NSString * const kPrefsPath = @"/var/mobile/Library/Preferences/space.mekabrine.androidbar15.plist";
static CFStringRef const kReloadNote = CFSTR("space.mekabrine.androidbar15/ReloadPrefs");
static NSDictionary *ABPrefs(void) { return [NSDictionary dictionaryWithContentsOfFile:kPrefsPath] ?: @{}; }
static BOOL ABEnabled(void) { NSNumber *n = ABPrefs()[@"Enabled"]; return n ? n.boolValue : YES; }
static CGFloat ABHeight(void){ NSNumber *n = ABPrefs()[@"BarHeight"]; return n ? n.floatValue : 40.f; }

static void ABApplyLayoutToWindow(UIWindow *w) {
    if (!w) return;
    if (!w.rootViewController) return;
    if (!ABEnabled()) {
        w.rootViewController.additionalSafeAreaInsets = UIEdgeInsetsZero;
        w.rootViewController.view.transform = CGAffineTransformIdentity;
        return;
    }
    CGFloat h = fmaxf(28.f, fminf(60.f, ABHeight()));
    w.rootViewController.additionalSafeAreaInsets = (UIEdgeInsets){.top=0,.left=0,.bottom=h,.right=0};
    CGAffineTransform scale = CGAffineTransformMakeScale(0.97, 0.97);
    CGAffineTransform shift = CGAffineTransformMakeTranslation(0, -h*0.5);
    w.rootViewController.view.transform = CGAffineTransformConcat(scale, shift);
}

static BOOL ABWebViewGoBack(UIView *view) {
    if ([view isKindOfClass:[WKWebView class]]) {
        WKWebView *w = (WKWebView *)view;
        if (w.canGoBack) { [w goBack]; return YES; }
    }
    for (UIView *sub in view.subviews) if (ABWebViewGoBack(sub)) return YES;
    return NO;
}

static BOOL ABSmartBack(void) {
    UIWindow *key = UIApplication.sharedApplication.keyWindow ?: UIApplication.sharedApplication.windows.firstObject;
    if (!key) return NO;
    UIViewController *root = key.rootViewController;
    if (!root) return NO;

    UIViewController *top = root;
    while (top.presentedViewController) top = top.presentedViewController;

    if (top.presentingViewController) { [top dismissViewControllerAnimated:YES completion:nil]; return YES; }

    UINavigationController *nav = (UINavigationController *)top;
    if ([nav isKindOfClass:[UINavigationController class]] && nav.viewControllers.count > 1) {
        [nav popViewControllerAnimated:YES];
        return YES;
    }
    if (top.navigationController && top.navigationController.viewControllers.count > 1) {
        [top.navigationController popViewControllerAnimated:YES];
        return YES;
    }
    if (ABWebViewGoBack(key)) return YES;

    return NO;
}

static void ABNote(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSString *n = (__bridge NSString *)name;
    if ([n hasSuffix:@"/BACK"]) {
        ABSmartBack();
    } else if ([n hasSuffix:@"/ReloadPrefs"]) {
        dispatch_async(dispatch_get_main_queue(), ^{ ABApplyLayoutToWindow(UIApplication.sharedApplication.keyWindow); });
    }
}

%hook UIApplication
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL r = %orig(application, launchOptions);
    dispatch_async(dispatch_get_main_queue(), ^{ ABApplyLayoutToWindow(UIApplication.sharedApplication.keyWindow); });
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, ABNote,
        CFSTR("space.mekabrine.androidbar15/BACK"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, ABNote,
        kReloadNote, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    return r;
}
%end

%hook UIScene
- (void)sceneDidActivate:(id)scene {
    %orig(scene);
    dispatch_async(dispatch_get_main_queue(), ^{ ABApplyLayoutToWindow(UIApplication.sharedApplication.keyWindow); });
}
%end
