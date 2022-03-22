//
//  Mnemonic.swift
//  UsNative
//
//  Created by Rigo Carbajal on 6/7/21.
//

import Foundation
import Bip39

private enum MnemonicLength: Int {
    case _12 = 12
    case _15 = 15
    case _18 = 18
    case _21 = 21
    case _24 = 24
}

extension Mnemonic {
    
    static private func entropy(wordLength: MnemonicLength) -> Int {
        // Entropy is a measure of the randomness of the mnemonic.
        // It must be an interval of 3 between 12 and 24.
        return wordLength.rawValue / 3 * 32
    }
    
    static private func generateAsArray(count: MnemonicLength = ._15) -> [String] {
        // We are defaulting to a mnemonic length of 15 words.
        let mnemonic = try! Bip39.Mnemonic(strength: self.entropy(wordLength: count))
        return mnemonic.mnemonic()
    }
    
    static public func generate() -> String {
        return self.generateAsArray().joined(separator: " ")
    }
}
