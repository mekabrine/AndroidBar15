ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0
THEOS_PACKAGE_SCHEME = rootless
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

# Orion (Swift hooking)
ORION = $(THEOS)/vendor/Orion
include $(THEOS_MAKE_PATH)/orion.mk

TWEAK_NAME = AndroidBar15
AndroidBar15_FILES = Sources/Tweak.swift Sources/BarWindow.swift Sources/Preferences.swift Sources/Haptics.swift Sources/AppHook.swift
AndroidBar15_SWIFTFLAGS = -ISources/include
AndroidBar15_FRAMEWORKS = UIKit CoreGraphics
AndroidBar15_PRIVATE_FRAMEWORKS = SpringBoardServices FrontBoardServices
AndroidBar15_CFLAGS += -fobjc-arc

SUBPROJECTS += AndroidBar15Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
