// UniFFI Build Script
// Generates FFI bindings for Kotlin (Android), Swift (iOS), and TypeScript (React Native)

use std::env;
use std::path::PathBuf;

fn main() {
    // Tell Cargo to re-run if the UDL file changes
    println!("cargo:rerun-if-changed=quantum_energy_bridge.udl");

    // Generate bindings
    let udl_path = PathBuf::from("quantum_energy_bridge.udl");
    let out_dir = PathBuf::from(env::var("OUT_DIR").unwrap());

    uniffi_build::generate_scaffolding(&udl_path).unwrap();
    uniffi_build::generate_bindings(&udl_path, &out_dir).unwrap();

    // Print configuration
    println!("cargo:rustc-link-lib=static=c++"); // For C++ ABI compatibility on Android
    println!("cargo:rustc-link-lib=stdc++"); // Android NDK C++ standard library

    // Platform-specific linker flags
    if cfg!(target_os = "android") {
        println!("cargo:rustc-link-arg=-Wl,--exclude-libs,libgcc");
        println!("cargo:rustc-link-arg=-Wl,--exclude-libs,libgcc_real");
    }

    if cfg!(target_os = "ios") {
        // iOS requires "-liconv" for some C functions
        println!("cargo:rustc-link-lib=iconv");
    }
}
