ACLOCAL_AMFLAGS = -I m4

if OS_WINDOWS_CROSSCOMPILE
# for leveldb
AM_MAKEFLAGS = TARGET_OS=OS_WINDOWS_CROSSCOMPILE
endif

TOKENPAY_QT_BIN=$(top_builddir)/src/tokenpay

OSX_APP=tokenpay-qt.app
OSX_VOLNAME = $(subst $(space),-,$(PACKAGE_NAME))
OSX_DMG = $(OSX_VOLNAME).dmg
OSX_BACKGROUND_SVG=background.svg
OSX_BACKGROUND_IMAGE=background.tiff
OSX_BACKGROUND_IMAGE_DPIS=36 72
OSX_DSSTORE_GEN=$(top_srcdir)/contrib/macdeploy/custom_dsstore.py
OSX_DEPLOY_SCRIPT=$(top_srcdir)/contrib/macdeploy/macdeployqtplus
OSX_FANCY_PLIST=$(top_srcdir)/contrib/macdeploy/fancy.plist
OSX_INSTALLER_ICONS=$(top_srcdir)/src/qt/res/icons/tokenpay.icns
OSX_PLIST=$(top_builddir)/share/qt/Info.plist #not installed
OSX_QT_TRANSLATIONS = da,de,es,hu,ru,uk,zh_CN,zh_TW

OSX_PACKAGING = $(OSX_DEPLOY_SCRIPT) $(OSX_FANCY_PLIST) $(OSX_INSTALLER_ICONS) \
  $(top_srcdir)/contrib/macdeploy/$(OSX_BACKGROUND_SVG) \
  $(OSX_DSSTORE_GEN) \
  $(top_srcdir)/contrib/macdeploy/detached-sig-apply.sh \
  $(top_srcdir)/contrib/macdeploy/detached-sig-create.sh

export CC CXX AR LD
SUBDIRS = tor leveldb src src/secp256k1

$(OSX_APP)/Contents/PkgInfo:
	$(MKDIR_P) $(@D)
	@echo "APPL????" > $@

$(OSX_APP)/Contents/Resources/empty.lproj:
	$(MKDIR_P) $(@D)
	@touch $@ 

$(OSX_APP)/Contents/Info.plist: $(OSX_PLIST)
	$(MKDIR_P) $(@D)
	$(INSTALL_DATA) $< $@

$(OSX_APP)/Contents/Resources/tokenpay.icns: $(OSX_INSTALLER_ICONS)
	$(MKDIR_P) $(@D)
	$(INSTALL_DATA) $< $@

$(OSX_APP)/Contents/MacOS/tokenpay-qt: all-recursive
	$(MKDIR_P) $(@D)
	STRIPPROG="$(STRIP)" $(INSTALL_STRIP_PROGRAM)  $(TOKENPAY_QT_BIN) $@

$(OSX_APP)/Contents/Resources/Base.lproj/InfoPlist.strings:
	$(MKDIR_P) $(@D)
	echo '{	CFBundleDisplayName = "$(PACKAGE_NAME)"; CFBundleName = "$(PACKAGE_NAME)"; }' > $@

OSX_APP_BUILT=$(OSX_APP)/Contents/PkgInfo $(OSX_APP)/Contents/Resources/empty.lproj \
  $(OSX_APP)/Contents/Resources/tokenpay.icns $(OSX_APP)/Contents/Info.plist \
  $(OSX_APP)/Contents/MacOS/tokenpay-qt $(OSX_APP)/Contents/Resources/Base.lproj/InfoPlist.strings

TokenPay.app: all-am
	mkdir -p TokenPay.app/Contents/{MacOS,Resources}
	cp Info.plist TokenPay.app/Contents
	cp tokenpay.icns TokenPay.app/Contents/Resources
	cp src/tokenpay TokenPay.app/Contents/MacOS/TokenPay
	echo "APPL????" > TokenPay.app/Contents/PkgInfo
	@MACDEPLOYQT@ TokenPay.app @MACDEPLOYQT_LIBPATH@ 

.PHONY: tokenPay.app
