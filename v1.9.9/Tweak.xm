#import <UIKit/UIKit.h>
#import <rootless.h>

// Scene-safe key window helper with no deprecated references on iOS 15 SDK builds
static UIWindow *ABActiveWindow(void) {
    if (@available(iOS 13.0, *)) {
        // 1) Prefer a key window from a foreground-active UIWindowScene
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class]) continue;
            UIWindowScene *ws = (UIWindowScene *)scene;
            if (ws.activationState != UISceneActivationStateForegroundActive) continue;

            for (UIWindow *w in ws.windows) {
                if (w.isKeyWindow && !w.hidden) return w;
            }
            // 2) Fallback: any visible window in that scene
            for (UIWindow *w in ws.windows) {
                if (!w.hidden) return w;
            }
        }
        // 3) Last resort: first window from any UIWindowScene
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class]) continue;
            UIWindowScene *ws = (UIWindowScene *)scene;
            if (ws.windows.count) return ws.windows.firstObject;
        }
        return nil;
    } else {
        // iOS 12 and below — compile this only when building with older SDKs
        #if __IPHONE_OS_VERSION_MAX_ALLOWED < 130000
        return UIApplication.sharedApplication.keyWindow;
        #else
        return nil;
        #endif
    }
}

%hook SBIconController

- (void)viewDidLoad {
    %orig;

    NSString *themesDir = ROOT_PATH_NS(@"/Library/Application Support/AndroBar/Themes");
    BOOL isDir = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:themesDir isDirectory:&isDir];
    NSLog(@"[AndroBar] themesDir=%@ exists=%d isDir=%d", themesDir, exists, isDir);

    UIWindow *win = ABActiveWindow();
    if (!win) return;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, win.bounds.size.width - 20, 28)];
    label.text = @"AndroBar (rootless) loaded";
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    label.textColor = [UIColor whiteColor];
    label.layer.cornerRadius = 8.0;
    label.clipsToBounds = YES;
    [win addSubview:label];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [label removeFromSuperview];
    });
}

%end
