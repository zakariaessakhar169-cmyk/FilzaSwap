TARGET := iphone:clang:latest:15.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = Filza

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FilzaSwap
FilzaSwap_FILES = Tweak.x
FilzaSwap_FRAMEWORKS = UIKit Foundation
FilzaSwap_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk

#after-install::
# install.exec "killall -9 Filza"
