//
//  DSNPKeys.swift
//  UsNative
//
//  Created by Rigo Carbajal on 6/7/21.
//

import Foundation

public struct DSNPKeys {
    
    internal var privateKey: PrivateKey?
    internal var privateKeyRaw: String? {
        return self.privateKey?.get()
    }
    
    public var publicKey: PublicKey? {
        // Public key does not need to be derived. It is
        // accessed directly from private key.
        return self.privateKey?.publicKey
    }
    public var publicKeyRaw: String? {
        return self.publicKey?.get()
    }
    
    public var address: String? {
        // This is also known as the Ethereum Address.
        return self.publicKey?.address.lowercased()
    }
    
    init(mnemonic: String?) {
        self.privateKey = self.derivePrivateKey(mnemonic: mnemonic)
    }
    
    private func derivePrivateKey(mnemonic: String?) -> PrivateKey? {
        guard let mnemonic = mnemonic else { return nil }
        
        // The private key is derived from the mnemonic.
        // From the private key, we can access the private key data,
        // the public key data, and the public ethereum address.
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let privateKey = PrivateKey(seed: seed, coin: .ethereum)
        
        // BIP44 key derivation - m/44'/60'/0'/0/0
        let purpose = privateKey.derived(at: .hardened(44))
        let coinType = purpose.derived(at: .hardened(60))
        let account = coinType.derived(at: .hardened(0))
        let change = account.derived(at: .notHardened(0))
        let firstPrivateKey = change.derived(at: .notHardened(0))
        
        return firstPrivateKey
    }
    
    public func sign(hash: Data?) -> Data? {
        guard let hash = hash else { return nil }
        return try? self.privateKey?.sign(hash: hash)
    }
}
