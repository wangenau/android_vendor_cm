# Inherit common CM stuff
$(call inherit-product, vendor/cm/config/common.mk)

# Include CM audio files
include vendor/cm/config/cm_audio.mk

# Include CM LatinIME dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/cm/overlay/dictionaries

 # Optional CM packages
 PRODUCT_PACKAGES += \
    LiveWallpapersPicker

# Extra tools in CM
PRODUCT_PACKAGES += \
    vim \
    zip \
    unrar
