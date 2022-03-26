//
//  DSNPWallet.swift
//  DSNPWallet
//
//  Created by Rigo Carbajal on 2/14/22.
//

import Foundation
import KeychainSwift

public struct DSNPWallet {

    private let kKeysEncryptionKey = "encrypted_mnemonic_data"

    public init() {}

    public func createKeys() throws -> DSNPKeys? {
        try? WalletEncryption().deleteKey()
        
        // Create encrypted mnemonic
        let mnemonic = Mnemonic.generate()
        let encryptedMnemonic = try WalletEncryption().encrypt(mnemonic)
        let keychain = KeychainSwift()
        keychain.set(encryptedMnemonic, forKey: kKeysEncryptionKey)
        
        // Initialize keys from decrypted mnemonic
        let keys = DSNPKeys(mnemonic: mnemonic)
        return keys
    }

    public func loadKeys() throws -> DSNPKeys? {
        let keychain = KeychainSwift()
        guard let data = keychain.getData(kKeysEncryptionKey) else {
            throw DSNPWalletError.keysNotFound
        }

        // Initialize keys from decrypted mnemonic
        let decryptedMnemonic = try WalletEncryption().decrypt(data)
        let keys = DSNPKeys(mnemonic: decryptedMnemonic)
        return keys
    }
    
    public func exportKeys(password: String) throws -> Data? {
        let keychain = KeychainSwift()
        guard let data = keychain.getData(kKeysEncryptionKey) else {
            throw DSNPWalletError.keysNotFound
        }

        // Re-encrypt decrypted mnemonic with password
        let decryptedMnemonic = try WalletEncryption().decrypt(data)
        let encrypted = try BackupEncryption().encrypt(decryptedMnemonic, with: password)
        return encrypted
    }
    
    public func importKeys(data: Data, password: String) throws -> DSNPKeys? {
        try WalletEncryption().deleteKey()

        // Create encrypted mnemonic
        let mnemonic = try BackupEncryption().decrypt(data, with: password)
        let encryptedMnemonic = try WalletEncryption().encrypt(mnemonic!)
        let keychain = KeychainSwift()
        keychain.set(encryptedMnemonic, forKey: kKeysEncryptionKey)

        // Initialize keys from decrypted mnemonic
        let keys = DSNPKeys(mnemonic: mnemonic)
        return keys
    }
    
    public func sign(_ message: String) throws -> Data? {
        guard let keys = try self.loadKeys() else { throw DSNPWalletError.keysNotFound }
        let data = message.data(using: .utf8)
        let hash = Crypto.sha3keccak256(data: data!)
        return keys.sign(hash: hash)
    }
    
    public func deleteKeys() throws {
        let keychain = KeychainSwift()
        keychain.delete(kKeysEncryptionKey)
        try WalletEncryption().deleteKey()
    }
}

enum DSNPWalletError: Error {
    
    case keysNotFound
    case encryption(String)
    
    var errorDescription: String? {
        switch self {
        case .keysNotFound:
            return ""
        case .encryption(let message):
            return message
        }
    }
}
