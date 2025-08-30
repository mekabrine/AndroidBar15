ARCHS = arm64
TARGET = iphone:clang:latest:15.0
THEOS_PACKAGE_SCHEME = rootless
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AndroBar

# Add your source files here (ObjC/Logos/Swift). Example uses Logos with one file.
AndroBar_FILES = Tweak.xm
AndroBar_CFLAGS += -fobjc-arc

# Link system frameworks you actually use
AndroBar_FRAMEWORKS = UIKit CoreGraphics

# If you use third-party libs, add them:
# AndroBar_LIBRARIES = colorpicker orion

include $(THEOS_MAKE_PATH)/tweak.mk

# Optional: build & package resources from layout/ into the final .deb
after-install::
	install.exec "sbreload"
