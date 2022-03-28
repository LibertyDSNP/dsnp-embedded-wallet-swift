/// Source: https://github.com/MoonfishApp/VivoPayEncryption

import Foundation
import LocalAuthentication
import CryptoKit

struct WalletEncryption {
    
    fileprivate var publicKey: SecKey!
    fileprivate var privateKey: SecKey?
    
    fileprivate static let encryptionAlgorithm = SecKeyAlgorithm.eciesEncryptionCofactorX963SHA256AESGCM
    fileprivate static let tag = "com.dsnp.wallet"
        
    init() throws {
        try restoreKey()
    }
}

extension WalletEncryption {

    /// Encrypts string using the Secure Enclave
    /// - Parameter string: clear text to be encrypted
    /// - Throws: CryptoKit error
    /// - Returns: cipherText encrypted string
    func encrypt(_ string: String) throws -> Data {
        
        let data = string.data(using: .utf8)!
        
        // Verify public key can be used to encrypt
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, WalletEncryption.encryptionAlgorithm) else {
            throw DSNPWalletError.encryption("Error verifying public key")
        }
        
        // Encrypt
        var error: Unmanaged<CFError>?
        guard let cipherText = SecKeyCreateEncryptedData(publicKey, WalletEncryption.encryptionAlgorithm, data as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }

        // Return encrypted data
        return cipherText
    }
    
    /// Decrypts cipher text using the Secure Enclave
    /// - Parameter cipherText: encrypted cipher text
    /// - Throws: CryptoKit error
    /// - Returns: cleartext string
    func decrypt(_ cipherText: Data) throws -> String {
        
        // Verify private key can be used to decrypt
        guard let privateKey = privateKey, SecKeyIsAlgorithmSupported(privateKey, .decrypt, WalletEncryption.encryptionAlgorithm) else {
            throw DSNPWalletError.encryption("Error fetching private key")
        }
        
        // Decrypt data
        var error: Unmanaged<CFError>?
        guard let clearText = SecKeyCreateDecryptedData(privateKey, WalletEncryption.encryptionAlgorithm, cipherText as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }
        
        // Return clear text
        return String(data: clearText, encoding: .utf8)!
    }
    
    /// Removes existing key.
    /// - Throws: CryptoKit error message
    func deleteKey() throws {
        
        // Create deletion query
        let query = [kSecClass: kSecClassKey,
                     kSecUseDataProtectionKeychain: true,
                     kSecAttrApplicationTag: WalletEncryption.tag] as [String: Any]
        
        // Delete key
        let result = SecItemDelete(query as CFDictionary)
        
        // Throws error if deletion wasn't successful
        if result != errSecSuccess {
            throw DSNPWalletError.encryption("Unexpected error deleting key: \(result)")
        }
    }
}

// MARK: - Key
extension WalletEncryption {
    
    /// Fetches key pair. If no key pair is found, a new keypair is created
    /// - Throws: CryptoKit error
    fileprivate mutating func restoreKey() throws {
        
        // Try to find existing key in the Secure Enclave
        if let key = try loadKey() {
            privateKey = key
            publicKey = SecKeyCopyPublicKey(key)
        
        } else {
        
            // If no key is found, create a new pair
            let keyTuple = try createKeys()
            self.publicKey = keyTuple.public
            self.privateKey = keyTuple.private
        }
    }
    
    /// Attempt to find and load existing key from the Secure Enclave
    /// If no secure enclave is available (e.g. iPod Touch), the method falls back to the iOS Keychain
    /// - Throws: CryptoKit error
    /// - Returns: Private key if found, nil if no existing key pair was found
    fileprivate func loadKey() throws -> SecKey? {

        // Create query
        var query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: WalletEncryption.tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true
        ]
        
        // Search for the key in Secure Enclave if possible (otherwise
        // search will fall back to the iOS Keychain
        if SecureEnclave.isAvailable {
            query[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
        }
        
        // Copy reference to private key from the Secure Enclave
        var key: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &key) == errSecSuccess {
            return (key as! SecKey)
        }
        
        // Return nil if no key was found
        return nil
    }
    
    /// Creates a new private key in the Secure Enclave. If no Secure Enclave is available,
    /// the method falls back to the iOS Keychain
    /// - Throws: CryptoKit error
    /// - Returns: Tuple of public and private key
    fileprivate func createKeys() throws  -> (public: SecKey, private: SecKey?) {
        
        var error: Unmanaged<CFError>?
        
        // Private key access control
        let privateKeyAccessControl: SecAccessControlCreateFlags = SecureEnclave.isAvailable ?  [.privateKeyUsage] : []

        guard let privateKeyAccess = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, privateKeyAccessControl, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        
        var privateKeyAttributes: [String: Any] = [
            kSecAttrApplicationTag as String:       WalletEncryption.tag,
            kSecAttrIsPermanent as String:          true,
            kSecUseAuthenticationContext as String: LAContext(),
            kSecAttrAccessControl as String:        privateKeyAccess,
        ]
        var commonKeyAttributes: [String: Any] = [
            kSecAttrKeyType as String:              kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String:        256,
            kSecPrivateKeyAttrs as String:          privateKeyAttributes,
        ]
                
        // Set secure enclave specific attributes
        if SecureEnclave.isAvailable {
            commonKeyAttributes[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
            commonKeyAttributes[kSecPrivateKeyAttrs as String] = privateKeyAttributes
            privateKeyAttributes[kSecAttrAccessControl as String] = privateKeyAccessControl
        }
        
        // Create a new random private key
        guard let privateKey = SecKeyCreateRandomKey(commonKeyAttributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        
        // Obtain the public key
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw DSNPWalletError.encryption("Error creating public key")
        }
        
        return (public: publicKey, private: privateKey)
    }
}
