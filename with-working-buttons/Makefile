ARCHS = arm64

# Let Theos use whatever SDK & deployment it has:
TARGET := iphone:clang:latest:latest
# We’re packaging for rootless (your layout/var/jb/... paths):
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AB15Hooks
AB15Hooks_FILES = Source/NavBarHooks.xm
AB15Hooks_FRAMEWORKS = UIKit
AB15Hooks_PRIVATE_FRAMEWORKS = SpringBoardUI
AB15Hooks_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "sbreload"
