// Source/NavBarHooks.xm
// Works in ANY process hosting the UI. App processes post Darwin notifications;
// SpringBoard receives them and performs the action.
// Per-button toggles in prefs: Back(off), Home(on), Switcher(on). Global Enabled on.

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <CoreFoundation/CoreFoundation.h>
#import <notify.h>

@interface UIApplication (Private)
- (void)suspend;
@end

static CFStringRef const kDomain = CFSTR("space.mekabrine.androidbar15");

// Darwin notification names
static const char *kABHomeNote     = "space.mekabrine.androidbar15.home";
static const char *kABSwitchNote   = "space.mekabrine.androidbar15.switcher";
static const char *kABBackNote     = "space.mekabrine.androidbar15.back";

static BOOL ABPrefBool(CFStringRef key, BOOL fallback) {
    Boolean exists = false;
    Boolean val = CFPreferencesGetAppBooleanValue(key, kDomain, &exists);
    return exists ? (BOOL)val : fallback;
}

static BOOL ABGloballyEnabled(void) { return ABPrefBool(CFSTR("Enabled"), YES); }
static BOOL ABBackEnabled(void)     { return ABPrefBool(CFSTR("BackEnabled"), NO); }
static BOOL ABHomeEnabled(void)     { return ABPrefBool(CFSTR("HomeEnabled"), YES); }
static BOOL ABSwitchEnabled(void)   { return ABPrefBool(CFSTR("SwitcherEnabled"), YES); }

static BOOL ABIsSpringBoard(void) {
    NSString *bid = [NSBundle mainBundle].bundleIdentifier ?: @"";
    return [bid isEqualToString:@"com.apple.springboard"];
}

// ---------- SpringBoard-side handlers

static id ABSharedInstance(Class cls) {
    if (!cls) return nil;
    SEL sel = NSSelectorFromString(@"sharedInstance");
    if ([cls respondsToSelector:sel]) {
        return ((id(*)(Class, SEL))objc_msgSend)(cls, sel);
    }
    return nil;
}

static void AB_SB_PerformHome(void) {
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

static void AB_SB_PerformSwitcher(void) {
    Class SBMainSwitcherViewController = objc_getClass("SBMainSwitcherViewController");
    id sw = ABSharedInstance(SBMainSwitcherViewController);
    SEL nonint = NSSelectorFromString(@"activateSwitcherNoninteractively");
    if (sw && [sw respondsToSelector:nonint]) {
        ((void(*)(id, SEL))objc_msgSend)(sw, nonint);
        return;
    }
    SEL anim = NSSelectorFromString(@"activateSwitcherAnimated:");
    if (sw && [sw respondsToSelector:anim]) {
        ((void(*)(id, SEL, BOOL))objc_msgSend)(sw, anim, YES);
        return;
    }
    Class SBUIController = objc_getClass("SBUIController");
    id ctrl = ABSharedInstance(SBUIController);
    SEL show = NSSelectorFromString(@"activateApplicationSwitcher");
    if (ctrl && [ctrl respondsToSelector:show]) {
        ((void(*)(id, SEL))objc_msgSend)(ctrl, show);
    }
}

static void AB_SB_PerformBack(void) {
    Class SBUIController = objc_getClass("SBUIController");
    id ctrl = ABSharedInstance(SBUIController);
    SEL backSel = NSSelectorFromString(@"handleBackButtonAction");
    if (ctrl && [ctrl respondsToSelector:backSel]) {
        ((void(*)(id, SEL))objc_msgSend)(ctrl, backSel);
    }
}

// ---------- Darwin notify bridge (fixed with C callbacks)

static void ABHomeCallback(CFNotificationCenterRef center, void *observer,
                           CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if (!ABGloballyEnabled()) return;
    if (ABHomeEnabled()) AB_SB_PerformHome();
}

static void ABSwitcherCallback(CFNotificationCenterRef center, void *observer,
                               CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if (!ABGloballyEnabled()) return;
    if (ABSwitchEnabled()) AB_SB_PerformSwitcher();
}

static void ABBackCallback(CFNotificationCenterRef center, void *observer,
                           CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if (!ABGloballyEnabled()) return;
    if (ABBackEnabled()) AB_SB_PerformBack();
}

static void ABPost(const char *name) {
    notify_post(name);
}

static void ABRegisterSpringBoardObservers(void) {
    CFNotificationCenterRef nc = CFNotificationCenterGetDarwinNotifyCenter();
    if (!nc) return;

    CFNotificationCenterAddObserver(
        nc, NULL, ABHomeCallback,
        CFSTR("space.mekabrine.androidbar15.home"), NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately
    );

    CFNotificationCenterAddObserver(
        nc, NULL, ABSwitcherCallback,
        CFSTR("space.mekabrine.androidbar15.switcher"), NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately
    );

    CFNotificationCenterAddObserver(
        nc, NULL, ABBackCallback,
        CFSTR("space.mekabrine.androidbar15.back"), NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately
    );
}

// ---------- UI hooks

%hook NavBarView

- (void)tBack {
    if (!ABGloballyEnabled()) { %orig; return; }
    if (ABIsSpringBoard()) {
        if (ABBackEnabled()) AB_SB_PerformBack();
    } else {
        ABPost(kABBackNote);
    }
    %orig;
}

- (void)tHome {
    if (!ABGloballyEnabled() || !ABHomeEnabled()) { %orig; return; }
    if (ABIsSpringBoard()) {
        AB_SB_PerformHome();
    } else {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(suspend)]) {
            [[UIApplication sharedApplication] suspend];
        }
        ABPost(kABHomeNote);
    }
    %orig;
}

- (void)tRecents {
    if (!ABGloballyEnabled() || !ABSwitchEnabled()) { %orig; return; }
    if (ABIsSpringBoard()) {
        AB_SB_PerformSwitcher();
    } else {
        ABPost(kABSwitchNote);
    }
    %orig;
}

%end

// Register observers only inside SpringBoard
%ctor {
    if (ABIsSpringBoard()) {
        ABRegisterSpringBoardObservers();
    }
}
