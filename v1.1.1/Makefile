ARCHS = arm64
TARGET := iphone:clang:latest:latest
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AB15Hooks
AB15Hooks_FILES = Source/NavBarHooks.xm
AB15Hooks_FRAMEWORKS = UIKit
AB15Hooks_PRIVATE_FRAMEWORKS = SpringBoardUI
AB15Hooks_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

# Ensure bundled binaries are executable in the final .deb
internal-stage::
	$(ECHO_NOTHING)chmod 0755 $(THEOS_STAGING_DIR)/var/jb/Library/PreferenceBundles/AndroidBar15Prefs.bundle/AndroidBar15Prefs 2>/dev/null || true$(ECHO_END)
	$(ECHO_NOTHING)chmod 0644 $(THEOS_STAGING_DIR)/var/jb/Library/PreferenceBundles/AndroidBar15Prefs.bundle/Root.plist 2>/dev/null || true$(ECHO_END)
	$(ECHO_NOTHING)chmod 0644 $(THEOS_STAGING_DIR)/var/jb/Library/PreferenceBundles/AndroidBar15Prefs.bundle/Info.plist 2>/dev/null || true$(ECHO_END)
	$(ECHO_NOTHING)chmod 0644 $(THEOS_STAGING_DIR)/var/jb/Library/PreferenceLoader/Preferences/AndroidBar15Prefs.plist 2>/dev/null || true$(ECHO_END)

after-install::
	install.exec "sbreload"
