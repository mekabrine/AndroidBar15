include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AndroidBar15Prefs
AndroidBar15Prefs_FILES = ABRootListController.m
AndroidBar15Prefs_INSTALL_PATH = /Library/PreferenceBundles
AndroidBar15Prefs_FRAMEWORKS = UIKit
AndroidBar15Prefs_PRIVATE_FRAMEWORKS = Preferences
AndroidBar15Prefs_CFLAGS = -fobjc-arc
AndroidBar15Prefs_BUNDLE_EXTENSION = bundle

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/AndroidBar15Prefs.plist$(ECHO_END)
