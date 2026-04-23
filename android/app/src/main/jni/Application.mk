# QuantumEnergyOS - Android NDK Configuration
# Platform: Android API 24+ (required for 64-bit support)
# Target ABIs: arm64-v8a (primary), armeabi-v7a (legacy), x86_64 (emulator)

APP_ABI := arm64-v8a armeabi-v7a x86_64
APP_PLATFORM := android-24
APP_STL := c++_shared
APP_CPPFLAGS := \
    -std=c++17 \
    -frtti \
    -fexceptions \
    -Wno-error=deprecated-declarations \
    -Wno-error=unknown-pragmas

# Use clang compiler (required for Rust interop)
NDK_TOOLCHAIN_VERSION := clang

# Enable LTO for production builds
APP_LTO := thin

# Enable position-independent code for dynamic loading
APP_PIE := true

# Keep debug symbols for crash reporting
APP_DEBUG := true
APP_OPTIM := release

# Enable NEON SIMD instructions for ARM64 (required for photonic-bridge acceleration)
APP_ARM_MODE := thumb
APP_ARM_NEON := true

# Rust compilation targets
RUST_TARGETS := \
    aarch64-linux-android \
    armv7-linux-androideabi \
    x86_64-linux-android

# Build for release by default
BUILD_MODE := Release

# Include path for UniFFI generated headers
UNIFFI_INCLUDE := $(LOCAL_PATH)/../../../../rust/target/$(TARGET_ARCH_ABI)/include

# Photonic bridge acceleration flags
APP_CFLAGS += -DPHOTOIC_BRIDGE_ENABLED=1
APP_CPPFLAGS += -DQUANTUM_KERNEL_ACCELERATION=1

# Logging configuration
APP_CFLAGS += -DQUANTUM_LOG_LEVEL=3  # 0=none, 3=debug

# Memory alignment for quantum state vectors
APP_CFLAGS += -DQUANTUM_STATE_ALIGNMENT=64

# Parallelism
APP_CPPFLAGS += -DRAYON_NUM_THREADS=$(shell nproc)