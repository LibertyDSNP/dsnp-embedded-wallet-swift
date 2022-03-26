//
//  MnemonicTests.swift
//  DSNPWalletTests
//
//  Created by Rigo Carbajal on 3/25/22.
//

import XCTest
import Bip39
@testable import DSNPWallet

class MnemonicTests: XCTestCase {
    
    func test_verifyMnemonicPhraseIsGeneratedCorrectly() {
        let mnemonicPhrase = Mnemonic.generate()
        XCTAssertFalse(mnemonicPhrase.isEmpty)
        let mnemonicArray = mnemonicPhrase.split(separator: " ")
        XCTAssertEqual(mnemonicArray.count, 15)
    }
}
