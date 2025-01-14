PRODUCT_BRAND ?= LineageOS

ifdef CM_NIGHTLY
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=lineageosnightly
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=lineageos
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=dd-MM-yyyy \
    ro.com.android.dataroaming=false

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# Disable multithreaded dexopt by default
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.dalvik.multithread=false

# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Backup Tool
ifneq ($(WITH_GMS),true)
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/bin/backuptool.sh:system/bin/backuptool.sh \
    vendor/cm/prebuilt/common/bin/backuptool.functions:system/bin/backuptool.functions \
    vendor/cm/prebuilt/common/bin/50-cm.sh:system/addon.d/50-cm.sh \
    vendor/cm/prebuilt/common/bin/blacklist:system/addon.d/blacklist
endif

# init.d support
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/cm/prebuilt/common/bin/sysinit:system/bin/sysinit

# userinit support
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

# CM-specific init file
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.local.rc:root/init.cm.rc

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# This is CM!
PRODUCT_COPY_FILES += \
    vendor/cm/config/permissions/com.cyanogenmod.android.xml:system/etc/permissions/com.cyanogenmod.android.xml

# Themes provider
PRODUCT_PACKAGES += \
    ThemesProvider

# Bootanimation
PRODUCT_PACKAGES += \
    bootanimation.zip

# Required CM packages
PRODUCT_PACKAGES += \
    LatinIME \
    BluetoothExt

# Optional CM packages
PRODUCT_PACKAGES += \
    libemoji

# Custom CM packages
PRODUCT_PACKAGES += \
    Trebuchet \
    DSPManager \
    libcyanogen-dsp \
    audio_effects.conf \
    Apollo \
    CMFileManager \
    LockClock

# Custom prebuilt apps
PRODUCT_PACKAGES += \
    Fennec

# CM Hardware Abstraction Framework
PRODUCT_PACKAGES += \
    org.cyanogenmod.hardware \
    org.cyanogenmod.hardware.xml

# Extra tools in CM
PRODUCT_PACKAGES += \
    libsepol \
    openvpn \
    e2fsck \
    mke2fs \
    tune2fs \
    bash \
    nano \
    htop \
    powertop \
    lsof \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat \
    mkfs.f2fs \
    fsck.f2fs \
    fibmap.f2fs \
    ntfsfix \
    ntfs-3g

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libstagefright_soft_ffmpegadec \
    libstagefright_soft_ffmpegvdec \
    libFFmpegExtractor \
    libnamparser

# These packages are excluded from user builds
PRODUCT_PACKAGES_DEBUG += \
    gdbserver \
    micro_bench \
    oprofiled \
    procmem \
    procrank \
    sqlite3 \
    strace

# Conditionally build in su
ifneq ($(TARGET_BUILD_VARIANT),user)
ifeq ($(WITH_SU),true)
PRODUCT_PACKAGES += \
    su
endif
endif

PRODUCT_PACKAGE_OVERLAYS += vendor/cm/overlay/common

PRODUCT_VERSION_MAJOR = 11
PRODUCT_VERSION_MINOR = 0
PRODUCT_VERSION_MAINTENANCE = 1

# Set CM_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat

ifndef CM_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "CM_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^CM_||g')
        CM_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif

# Filter out random types, so it'll reset to customized
ifeq ($(filter RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL,$(CM_BUILDTYPE)),)
    CM_BUILDTYPE :=
endif

ifdef CM_BUILDTYPE
    ifneq ($(CM_BUILDTYPE), SNAPSHOT)
        ifdef CM_EXTRAVERSION
            # Force build type to EXPERIMENTAL
            CM_BUILDTYPE := EXPERIMENTAL
            # Remove leading dash from CM_EXTRAVERSION
            CM_EXTRAVERSION := $(shell echo $(CM_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to CM_EXTRAVERSION
            CM_EXTRAVERSION := -$(CM_EXTRAVERSION)
        endif
    else
        ifndef CM_EXTRAVERSION
            # Force build type to EXPERIMENTAL, SNAPSHOT mandates a tag
            CM_BUILDTYPE := EXPERIMENTAL
        else
            # Remove leading dash from CM_EXTRAVERSION
            CM_EXTRAVERSION := $(shell echo $(CM_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to CM_EXTRAVERSION
            CM_EXTRAVERSION := -$(CM_EXTRAVERSION)
        endif
    endif
else
    # If CM_BUILDTYPE is not defined, set to customized
    CM_BUILDTYPE := customized
    CM_EXTRAVERSION :=
endif

ifeq ($(CM_BUILDTYPE), customized)
    ifneq ($(TARGET_CUSTOMIZED_BUILD_ID),)
        CM_EXTRAVERSION := -$(TARGET_CUSTOMIZED_BUILD_ID)
    endif
endif

ifeq ($(CM_BUILDTYPE), RELEASE)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
        LINEAGE_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(CM_BUILD)
    else
        ifeq ($(TARGET_BUILD_VARIANT),user)
            LINEAGE_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(CM_BUILD)
        else
            LINEAGE_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(CM_BUILD)
        endif
    endif
else
    ifeq ($(PRODUCT_VERSION_MINOR),0)
        LINEAGE_VERSION := $(PRODUCT_VERSION_MAJOR)-$(shell date -u +%Y%m%d)-$(CM_BUILDTYPE)$(CM_EXTRAVERSION)-$(CM_BUILD)
    else
        LINEAGE_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d)-$(CM_BUILDTYPE)$(CM_EXTRAVERSION)-$(CM_BUILD)
    endif
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.cm.version=$(LINEAGE_VERSION) \
  ro.cm.releasetype=$(CM_BUILDTYPE) \
  ro.modversion=$(LINEAGE_VERSION) \
  ro.cmlegal.url=https://lineageos.org/legal

CM_DISPLAY_VERSION := $(LINEAGE_VERSION)
TARGET_VENDOR_RELEASE_BUILD_ID := $(LINEAGE_VERSION)

# by default, do not update the recovery with system updates
PRODUCT_PROPERTY_OVERRIDES += persist.sys.recovery_update=false

PRODUCT_PROPERTY_OVERRIDES += \
  ro.cm.display.version=$(CM_DISPLAY_VERSION)

-include $(WORKSPACE)/build_env/image-auto-bits.mk

$(call prepend-product-if-exists, vendor/extra/product.mk)
