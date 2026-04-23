/**
 * QuantumEnergyOS - iOS Swift Bridge for React Native
 *
 * This Swift module provides the bridge between React Native and the Rust
 * quantum kernel via UniFFI-generated C bindings. The Rust library is
 * compiled as a static library for iOS (arm64, x86_64 simulator).
 *
 * Performance: Sub-millisecond calls via direct Swift-C-Rust FFI chain
 * Security: Uses iOS Keychain for quantum key storage via Security.framework
 * Architecture: Supports both device (arm64) and simulator (x86_64, arm64-sim)
 */

import Foundation
import React

// MARK: - Swift Native Module for React Native

/**
 * QuantumEnergyOSBridge - React Native TurboModule for iOS
 *
 * This class exposes the quantum kernel to React Native JavaScript code.
 * All methods are async and return Promises (JSPromise).
 */
@objc(QuantumEnergyOSBridge)
class QuantumEnergyOSBridge: RCTEventEmitter, NativeQuantumEnergyOSBridgeSpec {
    
    // MARK: - Constants
    
    static let moduleName = "QuantumEnergyOS"
    
    // MARK: - Properties
    
    private var quantumHandle: OpaquePointer? = nil
    private var isInitialized: Bool = false
    
    // MARK: - React Native Module Overrides
    
    override static func requiresMainQueueSetup() -> Bool {
        // Quantum kernel does heavy computation, initialize off main thread
        return false
    }
    
    override func supportedEvents() -> [String]! {
        return [
            "quantumOptimizationComplete",
            "cuarzoStateUpdated",
            "quantumError"
        ]
    }
    
    // MARK: - Public API (React Native Interface)
    
    /**
     * Initialize the quantum kernel
     * @param configPath Path to configuration JSON file
     * @param enablePhotonicBridge Enable photonic hardware acceleration
     * @param resolver Promise resolve function
     * @param rejecter Promise reject function
     */
    @objc
    func init(_ configPath: String,
              enablePhotonicBridge: Bool,
              resolver: @escaping RCTPromiseResolveBlock,
              rejecter: @escaping RCTPromiseRejectBlock) {
        
        // Dispatch to background thread
        DispatchQueue.global(qos: .userInitiated).async {
            guard self.quantumHandle == nil else {
                resolver(true)  // Already initialized
                return
            }
            
            let success = self.initializeKernel(configPath: configPath,
                                                 photonicBridge: enablePhotonicBridge)
            
            DispatchQueue.main.async {
                if success {
                    self.isInitialized = true
                    resolver(true)
                } else {
                    rejecter("INIT_ERROR", "Failed to initialize QuantumEnergyOS", nil)
                }
            }
        }
    }
    
    /**
     * Optimize longevity scenario using quantum algorithms
     * @param params SimulationParameters JSON string
     * @returns SimulationResult JSON string
     */
    @objc
    func optimizeScenario(_ params: String,
                          resolver: @escaping RCTPromiseResolveBlock,
                          rejecter: @escaping RCTPromiseRejectBlock) {
        runQuantumTask {
            let resultJson = quantum_energy_os_optimize_scenario(
                self.quantumHandle!,
                params
            )
            return resultJson
        } resolver: resolver, rejecter: rejecter
    }
    
    /**
     * Batch optimization with photonic bridge
     * @param scenarios Array of scenario JSON strings
     * @returns Array of simulation results JSON
     */
    @objc
    func batchOptimizePhotonic(_ scenarios: String,
                               resolver: @escaping RCTPromiseResolveBlock,
                               rejecter: @escaping RCTPromiseRejectBlock) {
        runQuantumTask {
            let resultsJson = quantum_energy_os_batch_optimize_photonic(
                self.quantumHandle!,
                scenarios
            )
            return resultsJson
        } resolver: resolver, rejecter: rejecter
    }
    
    /**
     * Real-time power grid optimization
     * Target: <1ms execution time
     * @param gridMetrics PowerGridMetrics JSON string
     * @param weights Constraint weightings as JS dictionary (converted to JSON)
     * @returns Optimized PowerGridMetrics JSON string
     */
    @objc
    func optimizePowerGridRealtime(_ gridMetrics: String,
                                   weights: [String: Any],
                                   resolver: @escaping RCTPromiseResolveBlock,
                                   rejecter: @escaping RCTPromiseRejectBlock) {
        runQuantumTask {
            let weightsData = try! JSONSerialization.data(
                withJSONObject: weights,
                options: []
            )
            let weightsJson = String(data: weightsData, encoding: .utf8)!
            
            let startTime = CFAbsoluteTimeGetCurrent()
            
            let optimizedJson = quantum_energy_os_optimize_power_grid_realtime(
                self.quantumHandle!,
                gridMetrics,
                weightsJson
            )
            
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            if elapsed > 0.001 {  // 1ms threshold
                print("⚠️ Power grid optimization took \(elapsed * 1000)ms (target <1ms)")
            }
            
            return optimizedJson
        } resolver: resolver, rejecter: rejecter
    }
    
    /**
     * Get Cuarzo 4D holographic state
     * @returns Cuarzo4DState JSON string for visualization
     */
    @objc
    func getCuarzo4DState(_ resolver: @escaping RCTPromiseResolveBlock,
                          rejecter: @escaping RCTPromiseRejectBlock) {
        runQuantumTask {
            let stateJson = quantum_energy_os_get_cuarzo_4d_state(
                self.quantumHandle!
            )
            return stateJson
        } resolver: resolver, rejecter: rejecter
    }
    
    /**
     * Update Cuarzo 4D storage dimensions
     * @param newDimensions [Double] 4-element array representing 4D space
     * @param resolutionMultiplier Resolution scaling factor
     */
    @objc
    func updateCuarzoDimensions(_ newDimensions: [Double],
                                resolutionMultiplier: Double,
                                resolver: @escaping RCTPromiseResolveBlock,
                                rejecter: @escaping RCTPromiseRejectBlock) {
        runQuantumTask {
            // Convert Swift array to Rust array
            quantum_energy_os_update_cuarzo_dimensions(
                self.quantumHandle!,
                newDimensions,
                resolutionMultiplier
            )
            return ()  // Void return
        } resolver: resolver, rejecter: rejecter
    }
    
    /**
     * Generate quantum-resistant keypair (Ed25519/X25519)
     * Uses iOS Secure Enclave when available (A7+ chips)
     *
     * @param keyType "ed25519" or "x25519"
     * @param useSecureEnclave Encrypt key in Secure Enclave if true
     * @returns Encrypted key identifier stored in Keychain
     */
    @objc
    func generateQuantumKeypair(_ keyType: String,
                                useSecureEnclave: Bool,
                                resolver: @escaping RCTPromiseResolveBlock,
                                rejecter: @escaping RCTPromiseRejectBlock) {
        runQuantumTask {
            let keyId = quantum_energy_os_generate_quantum_keypair(
                self.quantumHandle!,
                keyType,
                useSecureEnclave
            )
            return keyId
        } resolver: resolver, rejecter: rejecter
    }
    
    /**
     * Verify quantum-resistant signature
     *
     * @param message Original signed message
     * @param signature Base64-encoded Ed25519 signature
     * @param publicKeyId Key identifier from keychain/keystore
     * @returns true if signature valid
     */
    @objc
    func verifyQuantumSignature(_ message: String,
                                signature: String,
                                publicKeyId: String,
                                resolver: @escaping RCTPromiseResolveBlock,
                                rejecter: @escaping RCTPromiseRejectBlock) {
        runQuantumTask {
            let isValid = quantum_energy_os_verify_quantum_signature(
                self.quantumHandle!,
                message,
                signature,
                publicKeyId
            )
            return isValid
        } resolver: resolver, rejecter: rejecter
    }
    
    /**
     * Shutdown quantum kernel and release resources
     */
    @objc
    func shutdown(_ resolver: @escaping RCTPromiseResolveBlock,
                  rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.global(qos: .utility).async {
            if let handle = self.quantumHandle {
                quantum_energy_os_shutdown(handle)
                self.quantumHandle = nil
                self.isInitialized = false
            }
            DispatchQueue.main.async {
                resolver(true)
            }
        }
    }
    
    // MARK: - Private Helper Methods
    
    /**
     * Initialize Rust quantum kernel
     */
    private func initializeKernel(configPath: String, photonicBridge: Bool) -> Bool {
        guard quantumHandle == nil else {
            return true  // Already initialized
        }
        
        // Call UniFFI-generated C function
        quantumHandle = quantum_energy_os_create_quantum_energy_os(
            configPath,
            photonicBridge
        )
        
        return quantumHandle != nil
    }
    
    /**
     * Run quantum task on background queue with performance monitoring
     */
    private func runQuantumTask<T: Any>(_ task: @escaping () -> T,
                                         resolver: @escaping RCTPromiseResolveBlock,
                                         rejecter: @escaping RCTPromiseRejectBlock) {
        // Use dedicated quantum compute queue
        let quantumQueue = DispatchQueue(
            label: "com.calico2050.quantum.queue",
            qos: .userInitiated,
            attributes: .concurrent
        )
        
        quantumQueue.async {
            let startTime = CFAbsoluteTimeGetCurrent()
            
            do {
                let result = try task()
                let elapsed = CFAbsoluteTimeGetCurrent() - startTime
                
                // Log performance metrics for sub-1ms target verification
                if elapsed > 0.002 {  // 2ms warning threshold
                    print("⚡ Quantum task took \(elapsed * 1000)ms")
                }
                
                DispatchQueue.main.async {
                    resolver(result)
                }
            } catch {
                DispatchQueue.main.async {
                    rejecter("QUANTUM_ERROR", error.localizedDescription, error)
                }
            }
        }
    }
    
    // MARK: - Secure Enclave Key Storage (iOS-specific)
    
    /**
     * Store quantum key in iOS Keychain with Secure Enclave protection
     * - Parameters:
     *   - keyId: Unique identifier for the key
     *   - keyData: Binary key material
     *   - useSecureEnclave: Store in Secure Enclave (requires device with A7+)
     */
    private func storeKeyInSecureEnclave(keyId: String, keyData: Data, useSecureEnclave: Bool) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyId,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecValueRef as String: keyData as CFData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecUseAuthenticationUI as String: kSecUseAuthenticationUIAllow,
        ]
        
        // Add Secure Enclave specific attributes
        if useSecureEnclave {
            var mutableQuery = query
            mutableQuery[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
            mutableQuery[kSecUseAuthenticationUI as String] = kSecUseAuthenticationUIAllow
            
            let status = SecItemAdd(mutableQuery as CFDictionary, nil)
            guard status != errSecDuplicateItem else {
                // Key already exists, update it
                let updateQuery: [String: Any] = [
                    kSecClass as String: kSecClassKey,
                    kSecAttrApplicationTag as String: keyId
                ]
                let attributes: [String: Any] = [
                    kSecValueRef as String: keyData as CFData
                ]
                let updateStatus = SecItemUpdate(
                    updateQuery as CFDictionary,
                    attributes as CFDictionary
                )
                guard updateStatus == errSecSuccess else {
                    throw NSError(domain: NSOSStatusErrorDomain, code: Int(updateStatus), userInfo: nil)
                }
                return
            }
            
            guard status == errSecSuccess else {
                throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
            }
        } else {
            // Standard Keychain storage
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess || status == errSecDuplicateItem else {
                throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
            }
        }
    }
}

// MARK: - React Native Module C Bridge Wrapper

/**
 * C-compatible wrapper for Swift bridge
 * Provides C ABI for React Native's RCTBridgeModule protocol
 */
@objc
class QuantumEnergyOSBridgeCWrapper: NSObject, NativeQuantumEnergyOSBridgeSpecBridge {
    
    private var swiftBridge: QuantumEnergyOSBridge?
    
    override init() {
        super.init()
        self.swiftBridge = QuantumEnergyOSBridge()
    }
    
    func init(_ configPath: String,
              enablePhotonicBridge: Bool,
              resolver: @escaping RCTPromiseResolveBlock,
              rejecter: @escaping RCTPromiseRejectBlock) {
        swiftBridge?.init(configPath,
                          enablePhotonicBridge: enablePhotonicBridge,
                          resolver: resolver,
                          rejecter: rejecter)
    }
    
    // Forward all other methods to swiftBridge...
    // (Implementation similar to above)
}