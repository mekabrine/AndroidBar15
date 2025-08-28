export ARCHS = arm64
export TARGET = iphone:clang:latest:15.0
export THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

# SpringBoard tweak: shows the bar and triggers Home/Recents/Back (via Darwin notes)
TWEAK_NAME = AndroidBar15SB
AndroidBar15SB_FILES = TweakSB.x NavBarView.m
AndroidBar15SB_CFLAGS = -fobjc-arc -Wno-error=deprecated-declarations
AndroidBar15SB_FRAMEWORKS = UIKit CoreGraphics QuartzCore
AndroidBar15SB_PRIVATE_FRAMEWORKS = SpringBoardServices FrontBoardServices
# Default plist name is AndroidBar15SB.plist

# App tweak: smart back + safe-area & scale so bar doesn't cover content
TWEAK_NAME += AndroidBar15App
AndroidBar15App_FILES = TweakApp.x
AndroidBar15App_CFLAGS = -fobjc-arc
AndroidBar15App_FRAMEWORKS = UIKit WebKit
# Default plist name is AndroidBar15App.plist

SUBPROJECTS += AndroidBar15Prefs

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "uicache -a"
	install.exec "sbreload || killall -9 SpringBoard"
