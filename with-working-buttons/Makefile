ARCHS = arm64
TARGET = iphone:clang:15.0:9.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AB15Hooks
AB15Hooks_FILES = Source/NavBarHooks.xm
AB15Hooks_FRAMEWORKS = UIKit
AB15Hooks_PRIVATE_FRAMEWORKS = SpringBoardUI
AB15Hooks_CFLAGS += -fobjc-arc
AB15Hooks_INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS_MAKE_PATH)/tweak.mk

# Stage original binary and prefs from layout/
after-install::
	install.exec "killall -9 SpringBoard || true"