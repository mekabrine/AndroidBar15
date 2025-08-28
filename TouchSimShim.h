// TouchSimShim.h
// Minimal public interface expected by NavBarHooks.xm.
// Replace/bridge to your own injection implementation as needed.

#pragma once
#include <CoreGraphics/CoreGraphics.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef NS_ENUM(NSInteger, ABTouchType) {
    TOUCH_UP   = 0,
    TOUCH_DOWN = 1,
    TOUCH_MOVE = 2,
};

// Provide a system-wide touch at screen coordinates (in points).
// You should back this with your preferred jailbreak touch sim.
// Example: Ryu0118/TouchSimulator-iOS14 exports the exact same signature.
void simulateTouch(int type, float x, float y);

#ifdef __cplusplus
}
#endif
