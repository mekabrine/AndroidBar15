// Source/NavBarHooks.xm
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <CoreFoundation/CoreFoundation.h>

static BOOL ABEnabled(void) {
    CFStringRef domain = CFSTR("space.mekabrine.androidbar15");
    Boolean exists = false;
    Boolean enabled = CFPreferencesGetAppBooleanValue(CFSTR("Enabled"), domain, &exists);
    if (!exists) return YES;
    return (BOOL)enabled;
}

static id ABSharedInstance(Class cls) {
    if (!cls) return nil;
    SEL sel = NSSelectorFromString(@"sharedInstance");
    if ([cls respondsToSelector:sel]) {
        return ((id(*)(Class, SEL))objc_msgSend)(cls, sel);
    }
    return nil;
}

static void ABGoHome(void) {
    if (!ABEnabled()) return;
    Class SBUIController = objc_getClass("SBUIController");
    id ctrl = ABSharedInstance(SBUIController);
    SEL homeSel = NSSelectorFromString(@"handleHomeButtonSinglePressUp");
    if (ctrl && [ctrl respondsToSelector:homeSel]) {
        ((void(*)(id, SEL))objc_msgSend)(ctrl, homeSel);
        return;
    }
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(suspend)]) {
        [[UIApplication sharedApplication] suspend];
    }
}

static void ABOpenSwitcher(void) {
    if (!ABEnabled()) return;
    Class SBMainSwitcherViewController = objc_getClass("SBMainSwitcherViewController");
    id sw = ABSharedInstance(SBMainSwitcherViewController);
    SEL noninteractive = NSSelectorFromString(@"activateSwitcherNoninteractively");
    if (sw && [sw respondsToSelector:noninteractive]) {
        ((void(*)(id, SEL))objc_msgSend)(sw, noninteractive);
        return;
    }
    SEL animatedSel = NSSelectorFromString(@"activateSwitcherAnimated:");
    if (sw && [sw respondsToSelector:animatedSel]) {
        ((void(*)(id, SEL, BOOL))objc_msgSend)(sw, animatedSel, YES);
        return;
    }
    Class SBUIController = objc_getClass("SBUIController");
    id ctrl = ABSharedInstance(SBUIController);
    SEL showSwitcher = NSSelectorFromString(@"activateApplicationSwitcher");
    if (ctrl && [ctrl respondsToSelector:showSwitcher]) {
        ((void(*)(id, SEL))objc_msgSend)(ctrl, showSwitcher);
        return;
    }
}

static void ABBackOnePage(void) {
    if (!ABEnabled()) return;
    Class SBUIController = objc_getClass("SBUIController");
    id ctrl = ABSharedInstance(SBUIController);
    SEL backSel = NSSelectorFromString(@"handleBackButtonAction");
    if (ctrl && [ctrl respondsToSelector:backSel]) {
        ((void(*)(id, SEL))objc_msgSend)(ctrl, backSel);
        return;
    }
}

// Hook your existing class: 'NavBarView' with selectors tBack/tHome/tRecents
%hook NavBarView

- (void)tBack {
    ABBackOnePage();
    %orig;
}

- (void)tHome {
    ABGoHome();
    %orig;
}

- (void)tRecents {
    ABOpenSwitcher();
    %orig;
}

%end