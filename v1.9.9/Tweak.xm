#import <UIKit/UIKit.h>
#import <rootless.h>

static UIWindow *ABActiveWindow(void) {
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class]) continue;
            UIWindowScene *ws = (UIWindowScene *)scene;
            if (ws.activationState != UISceneActivationStateForegroundActive) continue;

            for (UIWindow *w in ws.windows) { if (w.isKeyWindow && !w.hidden) return w; }
            for (UIWindow *w in ws.windows) { if (!w.hidden) return w; }
        }
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class]) continue;
            UIWindowScene *ws = (UIWindowScene *)scene;
            if (ws.windows.count) return ws.windows.firstObject;
        }
        return nil;
    } else {
        #if __IPHONE_OS_VERSION_MAX_ALLOWED < 130000
        return UIApplication.sharedApplication.keyWindow;
        #else
        return nil;
        #endif
    }
}

// Hook SpringBoard’s delegate method so we always run
%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;

    NSString *themesDir = ROOT_PATH_NS(@"/Library/Application Support/AndroBar/Themes");
    BOOL isDir = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:themesDir isDirectory:&isDir];
    NSLog(@"[AndroBar] Loaded. themesDir=%@ exists=%d isDir=%d", themesDir, exists, isDir);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = ABActiveWindow();
        if (!win) return;

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, win.bounds.size.width - 20, 28)];
        label.text = @"AndroBar (rootless) active";
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        label.textColor = [UIColor whiteColor];
        label.layer.cornerRadius = 8.0;
        label.clipsToBounds = YES;
        [win addSubview:label];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [label removeFromSuperview];
        });
    });
}

%end
