#import <UIKit/UIKit.h>
#import <notify.h>

static int tokenBack = 0;

static void ABPerformBack(void) {
    // Try standard UIKit "escape" back
    UIApplication *app = [UIApplication sharedApplication];
    [app sendAction:@selector(accessibilityPerformEscape) to:nil from:nil forEvent:nil];
}

static void ABBackCallback(uint32_t token) {
    ABPerformBack();
}

%ctor {
    notify_register_dispatch("com.space.mekabrine.androidbar.back", &tokenBack, dispatch_get_main_queue(), ^(int t){
        ABBackCallback(t);
    });
}

// Hide the home indicator in apps
%hook UIViewController
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures {
    return UIRectEdgeAll;
}
%end