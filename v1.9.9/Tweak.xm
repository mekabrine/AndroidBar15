#import <UIKit/UIKit.h>
#import <rootless.h>

// Scene-safe key window helper (iOS 13+)
static UIWindow *ABActiveWindow(void) {
    if (@available(iOS 13.0, *)) {
        NSSet<UIScene *> *scenes = [UIApplication sharedApplication].connectedScenes;
        for (UIScene *scene in scenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) continue;
            UIWindowScene *ws = (UIWindowScene *)scene;
            if (ws.activationState != UISceneActivationStateForegroundActive) continue;

            // Prefer the key window if present
            for (UIWindow *w in ws.windows) {
                if (w.isKeyWindow) return w;
            }
            // Fallback to the first window
            if (ws.windows.count) return ws.windows.firstObject;
        }
        // Global fallback if no foreground scene yet
        return [UIApplication sharedApplication].windows.firstObject;
    } else {
        // iOS 12 and below (not really needed for Dopamine, but harmless)
        return [UIApplication sharedApplication].keyWindow;
    }
}

%hook SBIconController   // replace with your actual target(s)

- (void)viewDidLoad {
    %orig;

    // Rootless-aware path to your themes (old /Library/... works through the macro)
    NSString *themesDir = ROOT_PATH_NS(@"/Library/Application Support/AndroBar/Themes");

    // Use the variable so it isn't optimized away; this also verifies path exists
    BOOL isDir = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:themesDir isDirectory:&isDir];
    NSLog(@"[AndroBar] themesDir=%@ exists=%d isDir=%d", themesDir, exists, isDir);

    // Minimal visual indicator that the tweak loaded
    UIWindow *win = ABActiveWindow();
    if (win) {
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
}

%end
