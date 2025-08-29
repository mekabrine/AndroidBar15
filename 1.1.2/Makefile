TARGET := iphone:clang:latest:15.0
ARCHS := arm64 arm64e
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AndroidBarSB
AndroidBarSB_FILES = logos/TweakSB.xm logos/ABBarWindow.m
AndroidBarSB_FRAMEWORKS = UIKit
AndroidBarSB_PRIVATE_FRAMEWORKS = SpringBoardUI FrontBoardServices
AndroidBarSB_CFLAGS += -fobjc-arc

TWEAK_NAME += AndroidBarApp
AndroidBarApp_FILES = logos/TweakApp.xm
AndroidBarApp_FRAMEWORKS = UIKit
AndroidBarApp_PRIVATE_FRAMEWORKS = FrontBoardServices
AndroidBarApp_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"