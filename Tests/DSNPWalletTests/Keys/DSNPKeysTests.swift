//
//  DSNPKeysTests.swift
//  DSNPWalletTests
//
//  Created by Rigo Carbajal on 3/25/22.
//

import XCTest
import Bip39
@testable import DSNPWallet

class DSNPKeysTests: XCTestCase {
    
    func test_verifyThatPublicAndPrivateKeyAreGeneratedCorrectly() {
        let mnemonicPhrase = "model ranch account frozen believe connect extend romance include embrace adult nominee ill minor guess"
        let keys = DSNPKeys(mnemonic: mnemonicPhrase)
        XCTAssertEqual(keys.publicKeyRaw, "031bf2ebac3ec8fd3013fd54190a2e4a7ee5d25b8a0978cf647a84c52fed8642fe")
        XCTAssertEqual(keys.privateKeyRaw, "a497c8c30b321239dbefd5e086e4717f9d483858e9f8fecfa75b651f85756035")
    }
    
    func test_verifyThatPublicKeyAddressIsGeneratedCorrectly() {
        let mnemonicPhrase = "model ranch account frozen believe connect extend romance include embrace adult nominee ill minor guess"
        let keys = DSNPKeys(mnemonic: mnemonicPhrase)
        XCTAssertEqual(keys.address, "0x9b81ca9285661e5998f403a23d46dc326b8b7efb")
    }
    
    func test_verifyThatSignatureIsNilWhenHashIsNil() {
        let mnemonicPhrase = "model ranch account frozen believe connect extend romance include embrace adult nominee ill minor guess"
        let keys = DSNPKeys(mnemonic: mnemonicPhrase)
        let signature = keys.sign(hash: nil)
        XCTAssertNil(signature)
    }
    
    func test_verifyThatSignatureIsGeneratedCorrectly() {
        let mnemonicPhrase = "model ranch account frozen believe connect extend romance include embrace adult nominee ill minor guess"
        let keys = DSNPKeys(mnemonic: mnemonicPhrase)
        let message = "Hello World"
        let data = message.data(using: .utf8)
        let hash = Crypto.sha3keccak256(data: data!)
        let signature = keys.sign(hash: hash)
        XCTAssertEqual(signature?.base64EncodedString(), "FVSBhdAb3g7PtknWtHrc2TbnjlHYYYIZDdfeSN9fgdMAS1F8U5lOpLZA2B5TEonxuonzAOEnvRCVlyOMjoKCsQA=")
    }
}
