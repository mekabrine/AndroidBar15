// NavBarHooks.xm
// Hooks NavBarView’s action methods without altering UI.
// Build: theos Logos, SpringBoard only.

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <substrate.h>
#import <dispatch/dispatch.h>
#import <unistd.h>

// Minimal shim header; see TouchSimShim.h below (or your own touch sim).
#import "TouchSimShim.h"

// ---------- Helpers

static inline CGSize ABScreenSize(void) {
    return [UIScreen mainScreen].bounds.size;
}

static inline useconds_t ABStepDelay(NSTimeInterval total, NSUInteger steps) {
    if (steps < 1) steps = 1;
    double per = total / (double)steps;
    if (per < 0.00001) per = 0.00001;
    return (useconds_t)(per * 1000000.0);
}

static void ABSwipe(CGPoint start, CGPoint end, NSTimeInterval duration, NSUInteger steps) {
    if (steps < 2) steps = 2;

    simulateTouch(TOUCH_DOWN, start.x, start.y);
    useconds_t us = ABStepDelay(duration, steps);

    for (NSUInteger i = 1; i < steps; i++) {
        CGFloat t = (CGFloat)i / (CGFloat)(steps - 1);
        CGFloat x = start.x + (end.x - start.x) * t;
        CGFloat y = start.y + (end.y - start.y) * t;
        simulateTouch(TOUCH_MOVE, x, y);
        usleep(us);
    }
    simulateTouch(TOUCH_UP, end.x, end.y);
}

// ---------- Actions (gestures)

static void ABGoHome(void) {
    // Bottom-edge quick swipe up (~0.20s) → Home
    CGSize s = ABScreenSize();
    CGFloat y0 = s.height - 2.0;
    CGPoint a = CGPointMake(s.width * 0.5, y0);
    CGPoint b = CGPointMake(s.width * 0.5, MAX(0, y0 - 320.0));
    ABSwipe(a, b, 0.20, 10);
}

static void ABOpenSwitcher(void) {
    // Bottom-edge swipe up and pause before lifting → App Switcher
    CGSize s = ABScreenSize();
    CGFloat y0 = s.height - 2.0;
    CGPoint a = CGPointMake(s.width * 0.5, y0);
    CGPoint mid = CGPointMake(s.width * 0.5, MAX(0, y0 - 220.0));

    simulateTouch(TOUCH_DOWN, a.x, a.y);

    // ease up to mid
    NSUInteger steps = 10;
    useconds_t us = ABStepDelay(0.30, steps);
    for (NSUInteger i = 1; i <= steps; i++) {
        CGFloat t = (CGFloat)i / (CGFloat)steps;
        CGFloat x = a.x + (mid.x - a.x) * t;
        CGFloat y = a.y + (mid.y - a.y) * t;
        simulateTouch(TOUCH_MOVE, x, y);
        usleep(us);
    }

    // small hold to trigger switcher
    usleep(250000); // ~0.25s
    simulateTouch(TOUCH_UP, mid.x, mid.y);
}

static void ABBackOnePage(void) {
    // Left-edge → right swipe (~0.20s) → "Back" in most apps
    CGSize s = ABScreenSize();
    CGFloat x0 = 2.0;
    CGPoint a = CGPointMake(x0, s.height * 0.5);
    CGPoint b = CGPointMake(MIN(s.width * 0.66, x0 + 260.0), a.y);
    ABSwipe(a, b, 0.20, 10);
}

// ---------- Hook: NavBarView

%hook NavBarView

// The binary exposes -[NavBarView tBack], tHome, tRecents (no params).
// We replace them to run system gestures while keeping the UI unchanged.

- (void)tBack {
    ABBackOnePage();
}

- (void)tHome {
    ABGoHome();
}

- (void)tRecents {
    ABOpenSwitcher();
}

%end
