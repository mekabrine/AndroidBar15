export ARCHS = arm64
export TARGET = iphone:clang:latest:15.0
export THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AndroidBar15
AndroidBar15_FILES = Tweak.x NavBarView.m
AndroidBar15_CFLAGS = -fobjc-arc -Wno-error=deprecated-declarations
AndroidBar15_FRAMEWORKS = UIKit QuartzCore

SUBPROJECTS += AndroidBar15Prefs

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "uicache -a"
	install.exec "sbreload || killall -9 SpringBoard"
