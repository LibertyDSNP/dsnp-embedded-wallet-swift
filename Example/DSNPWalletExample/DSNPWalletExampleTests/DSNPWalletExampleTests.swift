//
//  DSNPWalletExampleTests.swift
//  DSNPWalletExampleTests
//
//  Created by Rigo Carbajal on 3/28/22.
//

import XCTest
import DSNPWallet
@testable import DSNPWalletExample

class DSNPWalletExampleTests: XCTestCase {
    
    func test_createKeysIsSuccessful() {
        let keys = try? DSNPWallet().createKeys()
        XCTAssertNotNil(keys)
        XCTAssertNotNil(keys?.publicKeyRaw)
    }
    
    func test_loadKeysIsSuccessfulWhenKeysAreAvailable() {
        let _ = try? DSNPWallet().createKeys()
        let keys = try? DSNPWallet().loadKeys()
        XCTAssertNotNil(keys)
        XCTAssertNotNil(keys?.publicKeyRaw)
    }
    
    func test_loadKeysThrowsErrorWhenKeysAreUnavailable() {
        try? DSNPWallet().deleteKeys()
        let keys = try? DSNPWallet().loadKeys()
        XCTAssertNil(keys)
    }
    
    func test_exportKeysThrowsErrorWhenKeysAreUnavailable() {
        try? DSNPWallet().deleteKeys()
        let keys = try? DSNPWallet().exportKeys(password: "password")
        XCTAssertNil(keys)
    }
    
    func test_exportKeysIsSuccessfulWhenKeysAreAvailable() {
        let _ = try? DSNPWallet().createKeys()
        let data = try? DSNPWallet().exportKeys(password: "password")
        XCTAssertNotNil(data)
        XCTAssertTrue((data?.count ?? 0) > 0)
    }
    
    func test_importKeysIsSuccessful() {
        let _ = try? DSNPWallet().createKeys()
        let password = "password"
        guard let data = try? DSNPWallet().exportKeys(password: password) else {
            XCTFail()
            return
        }
        let keys = try? DSNPWallet().importKeys(data: data, password: password)
        XCTAssertNotNil(keys)
        XCTAssertNotNil(keys?.publicKeyRaw)
    }
    
    func test_exportMnemonicIsSuccessful() {
        let _ = try? DSNPWallet().createKeys()
        
        do {
            let mnemonic = try DSNPWallet().exportMnemonic()
            XCTAssertNotNil(mnemonic)
        } catch {
            XCTFail("Error Thrown exporting mnemonic")
        }
    }
    
    func test_signMessageIsSuccessfulWhenKeysAreAvailable() {
        let _ = try? DSNPWallet().createKeys()
        let data = try? DSNPWallet().sign("Hello World")
        XCTAssertNotNil(data)
        XCTAssertTrue((data?.count ?? 0) > 0)
    }
    
    func test_signMessageThrowsErrorWhenKeysAreUnavailable() {
        try? DSNPWallet().deleteKeys()
        let data = try? DSNPWallet().sign("Hello World")
        XCTAssertNil(data)
    }
    
    func test_deleteKeysIsSuccessful() {
        let newKeys = try? DSNPWallet().createKeys()
        XCTAssertNotNil(newKeys)
        try? DSNPWallet().deleteKeys()
        let oldKeys = try? DSNPWallet().loadKeys()
        XCTAssertNil(oldKeys)
    }
}
