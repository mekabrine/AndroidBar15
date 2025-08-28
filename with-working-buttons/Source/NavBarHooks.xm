// Source/NavBarHooks.xm
// Home + Switcher actions; Back behind a prefs toggle (default OFF).
// Respects global "Enabled" (space.mekabrine.androidbar15).

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>   // for objc_msgSend
#import <CoreFoundation/CoreFoundation.h>

// Declare private selector so clang is happy on modern SDKs.
@interface UIApplication (Private)
- (void)suspend;
@end

static CFStringRef const kDomain = CFSTR("space.mekabrine.androidbar15");

// ---------- Pref helpers

static BOOL ABPrefBool(CFStringRef key, BOOL fallback) {
    Boolean exists = false;
    Boolean val = CFPreferencesGetAppBooleanValue(key, kDomain, &exists);
    return exists ? (BOOL)val : fallback;
}

static BOOL ABGloballyEnabled(void)   { return ABPrefBool(CFSTR("Enabled"), YES); }
static BOOL ABBackEnabled(void)       { return ABPrefBool(CFSTR("BackEnabled"), NO); }   // default OFF
static BOOL ABHomeEnabled(void)       { return ABPrefBool(CFSTR("HomeEnabled"), YES); }
static BOOL ABSwitcherEnabled(void)   { return ABPrefBool(CFSTR("SwitcherEnabled"), YES); }

// ---------- SB helpers

static id ABSharedInstance(Class cls) {
    if (!cls) return nil;
    SEL sel = NSSelectorFromString(@"sharedInstance");
    if ([cls respondsToSelector:sel]) {
        return ((id(*)(Class, SEL))objc_msgSend)(cls, sel);
    }
    return nil;
}

// ---------- Actions

static void ABBackOnePage(void) {
    if (!ABGloballyEnabled() || !ABBackEnabled()) return;

    // Conservative: call a system "back" handler only if present.
    Class SBUIController = objc_getClass("SBUIController");
    id ctrl = ABSharedInstance(SBUIController);
    SEL backSel = NSSelectorFromString(@"handleBackButtonAction");
    if (ctrl && [ctrl respondsToSelector:backSel]) {
        ((void(*)(id, SEL))objc_msgSend)(ctrl, backSel);
    }
    // else: no-op (avoids crashes on builds that lack it)
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

    // Fallback when built against newer SDKs:
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

    // Last-chance fallback
    Class SBUIController = objc_getClass("SBUIController");
    id ctrl = ABSharedInstance(SBUIController);
    SEL showSwitcher = NSSelectorFromString(@"activateApplicationSwitcher");
    if (ctrl && [ctrl respondsToSelector:showSwitcher]) {
        ((void(*)(id, SEL))objc_msgSend)(ctrl, showSwitcher);
        return;
    }
}

// ---------- Hook your navbar view (UI untouched)

%hook NavBarView

- (void)tBack {
    ABBackOnePage();   // guarded; default OFF
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
