# QuantumEnergyOS - Security Architecture Guide

## Overview

QuantumEnergyOS implements multi-layered security optimized for quantum-resistant operations and secure handling of sensitive energy grid data. This document outlines the security model for mobile deployments.

---

## 1. Quantum-Resistant Cryptography

### 1.1 Key Algorithms

**Ed25519 ( Edwards-curve Digital Signature Algorithm )**
- Purpose: Digital signatures for API authentication and data integrity
- Security: 128-bit security level, resistant to quantum attacks when combined with large key sizes
- Implementation: Ring crate (constant-time implementations)

**X25519 ( Elliptic Curve Diffie-Hellman over Curve25519 )**
- Purpose: Key agreement for encrypted communication with Flask/Azure backend
- Security: Forward secrecy via ECDH key exchange
- Implementation: RustCrypto elliptic-curve crate

### 1.2 Key Sizes & Security Levels

| Algorithm  | Classical Security | Post-Quantum Security | Key Size | Use Case            |
|-----------|-------------------|----------------------|-----------|-------------------|
| Ed25519   | 128-bit           | 64-bit               | 32 B      | Signatures         |
| X25519    | 128-bit           | 64-bit               | 32 B      | Key exchange       |
| AES-256   | 256-bit           | 256-bit              | 32 B      | Data encryption    |
| ChaCha20  | 256-bit           | 256-bit              | 32 B      | Stream encryption  |

---

## 2. Platform-Specific Secure Storage

### 2.1 iOS: Secure Enclave + Keychain

**Architecture:**
```
App -> QuantumEnergyOS Bridge -> Security.framework -> Secure Enclave (A7+ chips)
     -> Keychain Services (fallback)
```

**Implementation:**
- Private keys generated on-device, never leave Secure Enclave
- Stored in Keychain with `kSecAttrTokenIDSecureEnclave` attribute
- Access controlled by Touch ID / Face ID biometrics
- Hardware-backed key wrapping prevents extraction even if device is compromised

**Keychain Configuration:**
```swift
let query: [String: Any] = [
    kSecClass as String: kSecClassKey,
    kSecAttrApplicationTag as String: keyId,
    kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
    kSecValueRef as String: keyData as CFData,
    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
    kSecUseAuthenticationUI as String: kSecUseAuthenticationUIAllow,
]
```

**Fallback for Simulator:**
- Keys stored in encrypted keychain (hardware unavailable)
- Development-only, not used in production builds

### 2.2 Android: Keystore + StrongBox (if available)

**Architecture:**
```
App -> QuantumEnergyOS Bridge -> Android Keystore -> TEE / StrongBox
     -> EncryptedSharedPreferences (fallback)
```

**Implementation:**
- Keys generated via `KeyGenParameterSpec` with `setUserAuthenticationRequired(true)`
- Stored in hardware-backed keystore when device supports TEE
- StrongBox support on Pixel 3+ devices (dedicated secure chip)
- Biometric authentication enforced via `FingerprintManager`

**KeyStore Configuration:**
```java
KeyGenParameterSpec spec = new KeyGenParameterSpec.Builder(
    keyAlias,
    KeyProperties.PURPOSE_SIGN | KeyProperties.PURPOSE_VERIFY
)
.setKeySize(256)
.setUserAuthenticationRequired(true)
.setInvalidatedByBiometricEnrollment(true)
.build();
```

**Gradle Configuration:**
```gradle
android {
    defaultConfig {
        ndk {
            abiFilters 'arm64-v8a', 'armeabi-v7a'
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

---

## 3. Secure Communication

### 3.1 Transport Layer Security

All communication with Flask/Azure backend uses:
- **TLS 1.3** (minimum) with forward secrecy (ECDHE)
- Certificate pinning to prevent MITM attacks
- Mutual TLS (mTLS) for service-to-service authentication
- Implementation: `reqwest` with `rustls-tls` on Rust side, `react-native-quick-crypto` on RN side

**Backend API Security:**
```typescript
const secureClient = axios.create({
  baseURL: 'https://api.calico2050.quantum',
  httpsAgent: new HttpsAgent({
    cert: await getPinnedCertificate(),
    rejectUnauthorized: true,
    minVersion: 'TLSv1.3'
  }),
  timeout: 5000  // 5s timeout for sub-1ms requirement (network separate)
});
```

### 3.2 API Authentication Flow

```
1. Mobile App → Backend: Register device (generate device keypair)
2. Backend → Mobile: Challenge nonce
3. Mobile: Sign nonce with Ed25519 private key (Secure Enclave)
4. Backend: Verify signature using public key → Issue JWT token
5. All subsequent requests: JWT in Authorization header + request signature
```

---

## 4. Data Protection

### 4.1 At-Rest Encryption (Local Storage)

**Sensitive data encrypted using:**
- AES-256-GCM for symmetric encryption
- Random IV per encryption (unique per data item)
- Keys derived from device-specific keychain entry

**Storage locations:**
```
iOS:
├── Keychain (quantum keys) - Secure Enclave
├── Encrypted Realm database (simulation results)
└── File-protected directories (NSFileProtectionComplete)

Android:
├── Keystore (quantum keys) - TEE
├── Encrypted SQLCipher database
└── Internal storage with MODE_PRIVATE
```

### 4.2 In-Memory Protection

- Quantum kernel heap memory cleared via `explicit_bzero` after use
- Sensitive strings use `SecretString` type (zeroizes on drop)
- No sensitive data logged in production (log level set to WARN)

---

## 5. Quantum Key Management

### 5.1 Key Lifecycle

```
Generate → Store in Secure Enclave/Keystore → Use (sign/verify) → Rotate → Destroy
```

**Rotation Policy:**
- Ed25519 keys rotated every 90 days
- X25519 ephemeral keys per session (Perfect Forward Secrecy)
- Immediate key revocation on device compromise detection

### 5.2 Key Backup & Recovery

**Recovery Mechanism:**
1. `generateQuantumKeypair(..., backupRecovery=true)` → creates Shamir Secret Share
2. Shares distributed across: device keychain, iCloud Key-Values, Azure Key Vault (encrypted)
3. Recovery requires M-of-N shares (e.g., 3-of-5)

---

## 6. Threat Model & Mitigations

| Threat                              | Risk Level | Mitigation                                       |
|-------------------------------------|------------|-------------------------------------------------|
| Physical device theft               | HIGH       | Secure Enclave/StrongBox prevents key extraction; device passcode required |
| Network eavesdropping               | MEDIUM     | TLS 1.3 + pinning + mTLS                        |
 API tampering                          | MEDIUM     | Request signing; timestamp validation           |
| Malware/rooted device               | HIGH       | Root/jailbreak detection; key invalidation      |
| Side-channel attacks on crypto      | LOW        | Constant-time implementations; Ring crate       |
| Supply chain compromise (3rd party) | MEDIUM     | Dependency pinning; reproducible builds         |
| Quantum computer attack (future)    | LOW        | Post-quantum crypto research; hybrid signatures |

---

## 7. Secure Development Practices

### 7.1 Rust Side (Kernel)
- `#![forbid(unsafe_code)]` where possible (most FFI requires `unsafe`)
- All unsafe blocks audited with `cargo audit`
- Dependencies scanned for CVEs: `cargo audit --deny warnings`
- Memory safety via ownership model

### 7.2 React Native Side
- Code signed with enterprise certificate (distribution)
- Third-party libs audited via `npm audit`
- No sensitive data in Redux store (controlled via middleware)

### 7.3 Build & Release
- Reproducible builds via locked dependencies
- Binary signing with Apple Developer ID / Android keystore
- OTA updates via CodePush (Microsoft signed packages)

---

## 8. Compliance & Auditing

**Standards Compliance:**
- NIST FIPS 140-2 Level 2 (cryptographic module)
- GDPR Art. 32 (security of processing)
- ISO 27001 (information security management)
- SOC 2 Type II (service organization controls)

**Audit Trail:**
- All key operations logged to secure audit log
- Tamper-evident signing of log entries
- Retention: 1 year (configurable)

---

## 9. Performance vs Security Trade-offs

| Security Feature                    | Performance Impact     | Mitigation                              |
|-------------------------------------|-----------------------|-----------------------------------------|
| Secure Enclave operations           | ~2ms per operation    | Batch operations; caching               |
| TLS 1.3 handshake                   | ~50ms (first use)     | Session resumption; keep-alive          |
| AES-GCM encryption                  | <0.1ms (hardware accel)| Offloaded to CPU crypto extensions      |
| Biometric auth prompt               | User-dependent        | Pre-auth caching for 5min window        |

---

## 10. Emergency Procedures

**Compromised Key Response:**
1. Backend revokes key via `/api/v1/keys/revoke` endpoint
2. All devices receive push notification to regenerate keys
3. Affected user must re-enroll biometric data
4. Audit log entry created with severity "CRITICAL"

**Device Loss:**
- Remote wipe via MDM (Mobile Device Management)
- Key revocation across all backend services
- Account flagged for suspicious activity

---

## Appendix A: Key Derivation Functions

```rust
// Derive encryption key from device-specific secret
fn derive_key(device_secret: &[u8], salt: &[u8]) -> [u8; 32] {
    use ring::pbkdf2;
    let mut key = [0u8; 32];
    pbkdf2::derive(
        pbkdf2::PBKDF2_HMAC_SHA256,
        std::num::NonZeroU32::new(100_000).unwrap(),
        salt,
        device_secret,
        &mut key,
    );
    key
}
```

---

*Document Version: 0.1.0 | Last Updated: 2025-04-22 | Classification: INTERNAL*