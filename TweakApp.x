#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

// ====== Prefs ======
static NSString * const kPrefsPath = @"/var/mobile/Library/Preferences/space.mekabrine.androidbar15.plist";
static CFStringRef const kReloadNote = CFSTR("space.mekabrine.androidbar15/ReloadPrefs");
static NSDictionary *ABPrefs(void) { return [NSDictionary dictionaryWithContentsOfFile:kPrefsPath] ?: @{}; }
static BOOL ABEnabled(void) { NSNumber *n = ABPrefs()[@"Enabled"]; return n ? n.boolValue : YES; }
static CGFloat ABHeight(void){ NSNumber *n = ABPrefs()[@"BarHeight"]; return n ? n.floatValue : 40.f; }

// ====== Window helper (no deprecated APIs) ======
static UIWindow *ABActiveWindow(void) {
    // Prefer the key window from the foreground-active scene
    NSSet<UIScene *> *scenes = UIApplication.sharedApplication.connectedScenes;
    for (UIScene *scene in scenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive &&
            [scene isKindOfClass:[UIWindowScene class]]) {

            UIWindowScene *ws = (UIWindowScene *)scene;
            for (UIWindow *w in ws.windows) {
                if (w.isKeyWindow) return w;
            }
            if (ws.windows.count) return ws.windows.firstObject;
        }
    }
    // Fallbacks (should rarely be hit)
    for (UIScene *scene in scenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *ws = (UIWindowScene *)scene;
            if (ws.windows.count) return ws.windows.firstObject;
        }
    }
    return nil;
}

// ====== Layout helpers ======
static void ABApplyLayoutToWindow(UIWindow *w) {
    if (!w || !w.rootViewController) return;

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
    UIWindow *key = ABActiveWindow();
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

// ====== Darwin notifications from SB ======
static void ABNote(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    (void)center; (void)observer; (void)object; (void)userInfo;
    NSString *n = (__bridge NSString *)name;
    if ([n hasSuffix:@"/BACK"]) {
        ABSmartBack();
    } else if ([n hasSuffix:@"/ReloadPrefs"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ABApplyLayoutToWindow(ABActiveWindow());
        });
    }
}

// ====== Hooks ======
%hook UIApplication
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL r = %orig(application, launchOptions);
    dispatch_async(dispatch_get_main_queue(), ^{
        ABApplyLayoutToWindow(ABActiveWindow());
    });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        ABApplyLayoutToWindow(ABActiveWindow());
    });
}
%end
