################################################################################
#
# sdl2
#
################################################################################

SDL2_VERSION = 2.28.1
SDL2_SOURCE = SDL2-$(SDL2_VERSION).tar.gz
SDL2_SITE = http://www.libsdl.org/release
SDL2_LICENSE = Zlib
SDL2_LICENSE_FILES = LICENSE.txt
SDL2_CPE_ID_VENDOR = libsdl
SDL2_CPE_ID_PRODUCT = simple_directmedia_layer
SDL2_INSTALL_STAGING = YES
SDL2_CONFIG_SCRIPTS = sdl2-config

SDL2_CONF_OPTS += \
	--disable-rpath \
	--disable-arts \
	--disable-esd \
	--disable-dbus \
	--disable-diskaudio \
	--disable-pulseaudio \
	--disable-video-vivante \
	--disable-video-cocoa \
	--disable-video-metal \
	--disable-video-wayland \
	--disable-video-dummy \
	--disable-video-offscreen \
	--disable-video-vulkan \
	--disable-hidapi \
	--disable-ime \
	--disable-ibus \
	--disable-fcitx \
	--disable-joystick-mfi \
	--disable-directx \
	--disable-xinput \
	--disable-wasapi \
	--disable-hidapi-joystick \
	--disable-hidapi-libusb \
	--disable-joystick-virtual \
	--disable-render-d3d \
	--disable-oss

SDL2_CONF_OPTS += \
	--enable-arm-simd

SDL2_CONF_OPTS += \
	--disable-joystick \
	--disable-haptic

# We are using autotools build system for sdl2, so the sdl2-config.cmake
# include path are not resolved like for sdl2-config script.
# Change the absolute /usr path to resolve relatively to the sdl2-config.cmake location.
# https://bugzilla.libsdl.org/show_bug.cgi?id=4597
define SDL2_FIX_SDL2_CONFIG_CMAKE
	$(SED) '2iget_filename_component(PACKAGE_PREFIX_DIR "$${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)\n' \
		$(STAGING_DIR)/usr/lib/cmake/SDL2/sdl2-config.cmake
	$(SED) 's%"/usr"%$${PACKAGE_PREFIX_DIR}%' \
		$(STAGING_DIR)/usr/lib/cmake/SDL2/sdl2-config.cmake
endef
SDL2_POST_INSTALL_STAGING_HOOKS += SDL2_FIX_SDL2_CONFIG_CMAKE

# We must enable static build to get compilation successful.
SDL2_CONF_OPTS += --enable-static

ifeq ($(BR2_PACKAGE_HAS_UDEV),y)
SDL2_DEPENDENCIES += udev
SDL2_CONF_OPTS += --enable-libudev
else
SDL2_CONF_OPTS += --disable-libudev
endif

ifeq ($(BR2_X86_CPU_HAS_SSE),y)
SDL2_CONF_OPTS += --enable-sse
else
SDL2_CONF_OPTS += --disable-sse
endif

ifeq ($(BR2_X86_CPU_HAS_3DNOW),y)
SDL2_CONF_OPTS += --enable-3dnow
else
SDL2_CONF_OPTS += --disable-3dnow
endif

ifeq ($(BR2_ARM_CPU_HAS_NEON),y)
SDL2_CONF_OPTS += --enable-arm-neon
endif

ifeq ($(BR2_PACKAGE_SDL2_DIRECTFB),y)
ifeq ($(BR2_PACKAGE_DIRECTFB2),y)
SDL2_DEPENDENCIES += directfb2
else
SDL2_DEPENDENCIES += directfb2
endif
SDL2_CONF_OPTS += --enable-video-directfb --disable-directfb-shared
SDL2_CONF_ENV = ac_cv_path_DIRECTFBCONFIG=$(STAGING_DIR)/usr/bin/directfb-config
else
SDL2_CONF_OPTS += --disable-video-directfb --disable-directfb-shared
endif

ifeq ($(BR2_PACKAGE_SDL2_OPENGLES)$(BR2_PACKAGE_RPI_USERLAND),yy)
SDL2_DEPENDENCIES += rpi-userland
SDL2_CONF_OPTS += --enable-video-rpi
else
SDL2_CONF_OPTS += --disable-video-rpi
endif

# x-includes and x-libraries must be set for cross-compiling
# By default x_includes and x_libraries contains unsafe paths.
# (/usr/X11R6/include and /usr/X11R6/lib)
ifeq ($(BR2_PACKAGE_SDL2_X11),y)
SDL2_DEPENDENCIES += xlib_libX11 xlib_libXext

# X11/extensions/shape.h is provided by libXext.
SDL2_CONF_OPTS += --enable-video-x11 \
	--with-x=$(STAGING_DIR) \
	--x-includes=$(STAGING_DIR)/usr/include \
	--x-libraries=$(STAGING_DIR)/usr/lib \
	--enable-video-x11-xshape

ifeq ($(BR2_PACKAGE_XLIB_LIBXCURSOR),y)
SDL2_DEPENDENCIES += xlib_libXcursor
SDL2_CONF_OPTS += --enable-video-x11-xcursor
else
SDL2_CONF_OPTS += --disable-video-x11-xcursor
endif

ifeq ($(BR2_PACKAGE_XLIB_LIBXINERAMA),y)
SDL2_DEPENDENCIES += xlib_libXinerama
SDL2_CONF_OPTS += --enable-video-x11-xinerama
else
SDL2_CONF_OPTS += --disable-video-x11-xinerama
endif

ifeq ($(BR2_PACKAGE_XLIB_LIBXI),y)
SDL2_DEPENDENCIES += xlib_libXi
SDL2_CONF_OPTS += --enable-video-x11-xinput
else
SDL2_CONF_OPTS += --disable-video-x11-xinput
endif

ifeq ($(BR2_PACKAGE_XLIB_LIBXRANDR),y)
SDL2_DEPENDENCIES += xlib_libXrandr
SDL2_CONF_OPTS += --enable-video-x11-xrandr
else
SDL2_CONF_OPTS += --disable-video-x11-xrandr
endif

ifeq ($(BR2_PACKAGE_XLIB_LIBXSCRNSAVER),y)
SDL2_DEPENDENCIES += xlib_libXScrnSaver
SDL2_CONF_OPTS += --enable-video-x11-scrnsaver
else
SDL2_CONF_OPTS += --disable-video-x11-scrnsaver
endif

ifeq ($(BR2_PACKAGE_XLIB_LIBXXF86VM),y)
SDL2_DEPENDENCIES += xlib_libXxf86vm
SDL2_CONF_OPTS += --enable-video-x11-vm
else
SDL2_CONF_OPTS += --disable-video-x11-vm
endif

else
SDL2_CONF_OPTS += --disable-video-x11 --without-x
endif

ifeq ($(BR2_PACKAGE_SDL2_OPENGL),y)
SDL2_CONF_OPTS += --enable-video-opengl
SDL2_DEPENDENCIES += libgl
else
SDL2_CONF_OPTS += --disable-video-opengl
endif

ifeq ($(BR2_PACKAGE_SDL2_OPENGLES),y)
SDL2_CONF_OPTS += \
	--enable-video-opengles \
	--enable-video-opengles1 \
	--enable-video-opengles2
SDL2_DEPENDENCIES += libgles
else
SDL2_CONF_OPTS += \
	--disable-video-opengles \
	--disable-video-opengles1 \
	--disable-video-opengles2
endif

ifeq ($(BR2_PACKAGE_ALSA_LIB),y)
SDL2_DEPENDENCIES += alsa-lib
SDL2_CONF_OPTS += --enable-alsa
SDL2_CONF_OPTS += --disable-alsa-shared
else
SDL2_CONF_OPTS += --disable-alsa
SDL2_CONF_OPTS += --disable-alsa-shared
endif

ifeq ($(BR2_PACKAGE_SDL2_KMSDRM),y)
SDL2_DEPENDENCIES += libdrm mesa3d libegl
SDL2_CONF_OPTS += --enable-video-kmsdrm
else
SDL2_CONF_OPTS += --disable-video-kmsdrm
endif

ifeq ($(BR2_PACKAGE_SDL2_ATOMIC),y)
SDL2_CONF_OPTS += --enable-atomic
else
SDL2_CONF_OPTS += --disable-atomic
endif

ifeq ($(BR2_PACKAGE_SDL2_POWER),y)
SDL2_CONF_OPTS += --enable-power
else
SDL2_CONF_OPTS += --disable-power
endif

ifeq ($(BR2_PACKAGE_SDL2_RENDER),y)
SDL2_CONF_OPTS += --enable-render
else
SDL2_CONF_OPTS += --disable-render
endif

ifeq ($(BR2_PACKAGE_SDL2_EVENTS),y)
SDL2_CONF_OPTS += --enable-events
else
SDL2_CONF_OPTS += --disable-events
endif

ifeq ($(BR2_PACKAGE_SDL2_JOYSTICK),y)
SDL2_CONF_OPTS += --enable-joystick
else
SDL2_CONF_OPTS += --disable-joystick
endif

ifeq ($(BR2_PACKAGE_SDL2_SENSOR),y)
SDL2_CONF_OPTS += --enable-sensor
else
SDL2_CONF_OPTS += --disable-sensor
endif

ifeq ($(BR2_PACKAGE_SDL2_HAPTIC),y)
SDL2_CONF_OPTS += --enable-haptic
else
SDL2_CONF_OPTS += --disable-haptic
endif

ifeq ($(BR2_PACKAGE_SDL2_CPUINFO),y)
SDL2_CONF_OPTS += --enable-cpuinfo
else
SDL2_CONF_OPTS += --disable-cpuinfo
endif

SDL2_CFLAGS = -O3

# Build with LTO. This increases the code size a lot!
# but the cpu usage when running chocolate-doom is reduced
# from ~73% to ~62%.
ifeq ($(BR2_GCC_ENABLE_LTO),y)
SDL2_CFLAGS += -flto
endif

SDL2_CONF_ENV += CFLAGS="$(SDL2_CFLAGS)"

$(eval $(autotools-package))
