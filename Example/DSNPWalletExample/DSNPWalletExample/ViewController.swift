//
//  ViewController.swift
//  DSNPWalletExample
//
//  Created by Rigo Carbajal on 3/22/22.
//

import UIKit
import DSNPWallet

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? DSNPWallet().deleteKeys()
        let _ = try? DSNPWallet().createKeys()
        
        do {
            let message = "hello world"
            let signature = try DSNPWallet().sign(message)
            print("Signature:", signature ?? "<nil>")
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
}
