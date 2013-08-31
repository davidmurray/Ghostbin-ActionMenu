include theos/makefiles/common.mk

LIBRARY_NAME = Ghostbin
Ghostbin_FILES = DMGhostbinPlugin.m DMGhostbinUploader.m
Ghostbin_INSTALL_PATH = /Library/ActionMenu/Plugins
Ghostbin_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/library.mk
