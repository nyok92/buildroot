################################################################################
#
# tensorflow-lite
#
################################################################################

TENSORFLOW_LITE_VERSION = 2.21.0
TENSORFLOW_LITE_SITE =  $(call github,tensorflow,tensorflow,v$(TENSORFLOW_LITE_VERSION))
TENSORFLOW_LITE_INSTALL_STAGING = YES
TENSORFLOW_LITE_LICENSE = Apache-2.0
TENSORFLOW_LITE_LICENSE_FILES = LICENSE
TENSORFLOW_LITE_SUBDIR = tensorflow/lite
TENSORFLOW_LITE_SUPPORTS_IN_SOURCE_BUILD = NO
TENSORFLOW_LITE_DEPENDENCIES += \
	host-pkgconf \
	host-flatbuffers \
	cpuinfo \
	eigen \
	farmhash \
	fft2d \
	flatbuffers \
	gemmlowp \
	libabseil-cpp \
	neon-2-sse

TENSORFLOW_LITE_CONF_OPTS = \
	-Dabsl_DIR=$(STAGING_DIR)/usr/lib/cmake/absl \
	-DBUILD_SHARED_LIBS=ON \
	-DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) -I$(STAGING_DIR)/usr/include/gemmlowp" \
	-DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DEigen3_DIR=$(STAGING_DIR)/usr/share/eigen3/cmake \
	-DFETCHCONTENT_FULLY_DISCONNECTED=ON \
	-DFETCHCONTENT_QUIET=OFF \
	-DFFT2D_SOURCE_DIR=$(STAGING_DIR)/usr/include/fft2d \
	-DFlatBuffers_DIR=$(STAGING_DIR)/usr/lib/cmake/flatbuffers \
	-DNEON_2_SSE_DIR=$(STAGING_DIR)/usr/lib/cmake/NEON_2_SSE \
	-DSYSTEM_FARMHASH=ON \
	-DTFLITE_ENABLE_EXTERNAL_DELEGATE=ON \
	-DTFLITE_ENABLE_GPU=OFF \
	-DTFLITE_ENABLE_INSTALL=ON \
	-DTFLITE_ENABLE_MMAP=ON \
	-DTFLITE_ENABLE_NNAPI=OFF \
	-DTFLITE_HOST_TOOLS_DIR=$(HOST_DIR)/bin

TENSORFLOW_LITE_CONF_OPTS += -DTENSORFLOW_SOURCE_DIR=$(@D)

define TENSORFLOW_LITE_FFT2D_FIX
	mkdir -p $(@D)/tensorflow/lite/buildroot-build/fft2d
	touch $(@D)/tensorflow/lite/buildroot-build/fft2d/readme2d.txt
endef
TENSORFLOW_LITE_PRE_CONFIGURE_HOOKS += TENSORFLOW_LITE_FFT2D_FIX

TENSORFLOW_LITE_ML_DTYPES_COMMIT = 00d98cd92ade342fef589c0470379abb27baebe9
TENSORFLOW_LITE_EXTRA_DOWNLOADS = \
	https://github.com/jax-ml/ml_dtypes/archive/$(TENSORFLOW_LITE_ML_DTYPES_COMMIT).tar.gz
define TENSORFLOW_LITE_ML_DTYPES_FIX
	mkdir -p $(@D)/tensorflow/lite/buildroot-build/ml_dtypes
	tar -xf $(TENSORFLOW_LITE_DL_DIR)/$(TENSORFLOW_LITE_ML_DTYPES_COMMIT).tar.gz \
		--strip-components=1 \
		-C $(@D)/tensorflow/lite/buildroot-build/ml_dtypes
endef
TENSORFLOW_LITE_PRE_CONFIGURE_HOOKS += TENSORFLOW_LITE_ML_DTYPES_FIX

ifeq ($(BR2_PACKAGE_RUY),y)
TENSORFLOW_LITE_DEPENDENCIES += ruy
TENSORFLOW_LITE_CONF_OPTS += -DTFLITE_ENABLE_RUY=ON
else
TENSORFLOW_LITE_CONF_OPTS += -DTFLITE_ENABLE_RUY=OFF
endif

ifeq ($(BR2_PACKAGE_XNNPACK),y)
TENSORFLOW_LITE_DEPENDENCIES += xnnpack
TENSORFLOW_LITE_CONF_OPTS += -DTFLITE_ENABLE_XNNPACK=ON -Dxnnpack_POPULATED=ON
else
TENSORFLOW_LITE_CONF_OPTS += -DTFLITE_ENABLE_XNNPACK=OFF
endif

$(eval $(cmake-package))
