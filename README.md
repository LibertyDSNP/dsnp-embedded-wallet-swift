<a href="https://github.com/LibertyDSNP/dsnp-embedded-wallet-swift/actions">
  <img src="https://github.com/LibertyDSNP/dsnp-embedded-wallet-swift/actions/workflows/swift.yml/badge.svg" alt="Continuous Integration">
</a>

## DSNP Embedded Wallet

The DNSP Embedded Wallet is a Swift Package that supports the following basic features:
* Creating new keys
* Loading existing keys
* Importing keys
* Exporting keys
* Signing messages

## Installation

### Swift Package Manager

1. From XCode, select File > Add Packages. Enter `https://github.com/LibertyDSNP/dsnp-embedded-wallet-swift` as the package URL.
2. Once the SDK has been added to your project, import using:

```swift
import DSNPWallet
```

## Usage

### Creating a New Key
1. Generate seed phrase. Example: offer work butter trick cart stereo merit direct soon leader estate hint brown hidden patch
2. Get key from Secure Enclave (load existing or create new).
3. Encrypt seed phrase against this key.
4. Store encrypted phrase in keychain.

#### Example

```swift
do {
    let keys = try DSNPWallet().createKeys()
} catch {
    // error
}
```

### Loading an Existing Key
1. Get encrypted seed phrase from keychain.
2. Get key from Secure Enclave.
3. Decrypt seed phrase against this key.
4. Create key from seed phrase.

#### Example

```swift
do {
    let keys = try DSNPWallet().loadKeys()
} catch {
    // error
}
```

### Exporting Keys
1. Decrypt seed phrase against Secure Enclave key.
2. Create a symmetric key using a user-provided password.
3. “Seal” the seed phrase with password using ChaChaPoly (a ChaCha20-Poly1305 cipher).
4. Save encrypted data to file and offer user the ability to save file to desired storage. 

#### Example

```swift
do {
    let exportData = try? DSNPWallet().exportKeys(password: PASSWORD)
} catch {
    // error
}
```

### Importing Keys
1. Provide ability to attach encrypted data file, along with password input. 
2. Create a symmetric key using a user-provided password.
3. Decrypt the file with password using ChaChaPoly.
4. Create a new key using decrypted seed phrase.

#### Example

```swift
do {
    let keys = try DSNPWallet().importKeys(data: ENCRYPTED_DATA, password: PASSWORD)
} catch {
    // error
}
```

## License

        Copyright 2022 Unfinished Labs LLC

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
