// Source/NavBarHooks.xm
// Home + Switcher actions; Back is behind a prefs toggle (default OFF).
// Also respects the global "Enabled" switch in this domain.

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <CoreFoundation/CoreFoundation.h>

static CFStringRef const kDomain = CFSTR("space.mekabrine.androidbar15");

static BOOL ABPrefBool(CFStringRef key, BOOL fallback) {
    Boolean exists = false;
    Boolean val = CFPreferencesGetAppBooleanValue(key, kDomain, &exists);
    return exists ? (BOOL)val : fallback;
}

static BOOL ABGloballyEnabled(void) {
    // Global master switch (default ON if missing)
    return ABPrefBool(CFSTR("Enabled"), YES);
}

static BOOL ABBackEnabled(void) {
    // Default OFF per your request
    return ABPrefBool(CFSTR("BackEnabled"), NO);
}

static BOOL ABHomeEnabled(void) {
    // Default ON
    return ABPrefBool(CFSTR("HomeEnabled"), YES);
}

static BOOL ABSwitcherEnabled(void) {
    // Default ON
    return ABPrefBool(CFSTR("SwitcherEnabled"), YES);
}

static id ABSharedInstance(Class cls) {
    if (!cls) return nil;
    SEL sel = NSSelectorFromString(@"sharedInstance");
    if ([cls respondsToSelector:sel]) {
        return ((id(*)(Class, SEL))objc_msgSend)(cls, sel);
    }
    return nil;
}

// --- Actions (Back is gated; can be no-op) ---

static void ABBackOnePage(void) {
    if (!ABGloballyEnabled() || !ABBackEnabled()) return;

    // We intentionally keep this conservative to avoid safemode:
    // Try a system "back" handler if it exists; otherwise do nothing.
    Class SBUIController = objc_getClass("SBUIController");
    id ctrl = ABSharedInstance(SBUIController);
    SEL backSel = NSSelectorFromString(@"handleBackButtonAction");
    if (ctrl && [ctrl respondsToSelector:backSel]) {
        ((void(*)(id, SEL))objc_msgSend)(ctrl, backSel);
    }
}

static void ABGoHome(void) {
    if (!ABGloballyEnabled() || !ABHomeEnabled()) return;

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
    if (!ABGloballyEnabled() || !ABSwitcherEnabled()) return;

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

// --- Hook your navbar view (method names unchanged; UI not touched) ---

%hook NavBarView

- (void)tBack {
    ABBackOnePage();   // will no-op unless BackEnabled == YES
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
