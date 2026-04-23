LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

# Module name
MODULE := quantum_energy_os

# Rust compiled shared library (.so)
RUST_LIB := $(TARGET_OUT_INTERMEDIATE_LIBRARIES)/libquantum_energy_os.so

# Compiler flags
LOCAL_CFLAGS := \
    -std=c99 \
    -Wall \
    -Werror \
    -fPIC \
    -DANDROID \
    -D__ANDROID_API__=$(APP_PLATFORM)

LOCAL_C_INCLUDES := \
    $(LOCAL_PATH)/../../../../rust/target/$(TARGET_ARCH_ABI)/include \
    $(LOCAL_PATH)/../../../../rust/target/$(TARGET_ARCH_ABI)/uniffi \
    $(JNI_H_INCLUDE)

# Source files
LOCAL_SRC_FILES := \
    $(RUST_LIB) \
    quantum_energy_os_jni.c

# Linker flags
LOCAL_LDLIBS := \
    -llog \
    -landroid \
    -ldl \
    -lc \
    -lm

# Link the Rust static library
LOCAL_STATIC_LIBRARIES := \
    quantum_energy_os_static \
    uniffi_quantum_energy_os_static

include $(BUILD_SHARED_LIBRARY)

# Additional STATIC library build for Rust
include $(CLEAR_VARS)
LOCAL_MODULE := quantum_energy_os_static
LOCAL_SRC_FILES := $(RUST_LIB)
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := uniffi_quantum_energy_os_static
LOCAL_SRC_FILES := $(TARGET_OUT_INTERMEDIATE_LIBRARIES)/libuniffi_quantum_energy_os.a
include $(PREBUILT_STATIC_LIBRARY)