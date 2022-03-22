//
//  ViewController.swift
//  DSNPWalletExample
//
//  Created by Rigo Carbajal on 3/22/22.
//

import UIKit
import DSNPWallet
import UniformTypeIdentifiers

class ViewController: UIViewController {
    
    private var loadKeyButton: UIButton?
    private var createKeyButton: UIButton?
    private var importKeyButton: UIButton?
    private var exportKeyButton: UIButton?
    private var resetKeyButton: UIButton?
    private var signMessageButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Wallet"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        stackView.addArrangedSubview(titleLabel)
        
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        stackView.addArrangedSubview(divider)
        
        let loadKeyButton = UIButton(type: .roundedRect)
        loadKeyButton.setTitle("View Key", for: .normal)
        loadKeyButton.translatesAutoresizingMaskIntoConstraints = false
        loadKeyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stackView.addArrangedSubview(loadKeyButton)
        loadKeyButton.addTarget(self, action: #selector(loadKeys), for: .touchUpInside)
        self.loadKeyButton = loadKeyButton
        
        let createKeyButton = UIButton(type: .roundedRect)
        createKeyButton.setTitle("Create Key", for: .normal)
        createKeyButton.translatesAutoresizingMaskIntoConstraints = false
        createKeyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stackView.addArrangedSubview(createKeyButton)
        createKeyButton.addTarget(self, action: #selector(createNewKeys), for: .touchUpInside)
        self.createKeyButton = createKeyButton
        
        let importKeyButton = UIButton(type: .roundedRect)
        importKeyButton.setTitle("Import Key", for: .normal)
        importKeyButton.translatesAutoresizingMaskIntoConstraints = false
        importKeyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stackView.addArrangedSubview(importKeyButton)
        importKeyButton.addTarget(self, action: #selector(importKeys), for: .touchUpInside)
        self.importKeyButton = importKeyButton
        
        let exportKeyButton = UIButton(type: .roundedRect)
        exportKeyButton.setTitle("Export Key", for: .normal)
        exportKeyButton.translatesAutoresizingMaskIntoConstraints = false
        exportKeyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stackView.addArrangedSubview(exportKeyButton)
        exportKeyButton.addTarget(self, action: #selector(exportKeys), for: .touchUpInside)
        self.exportKeyButton = exportKeyButton
        
        let resetKeyButton = UIButton(type: .roundedRect)
        resetKeyButton.setTitle("Reset Key", for: .normal)
        resetKeyButton.translatesAutoresizingMaskIntoConstraints = false
        resetKeyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stackView.addArrangedSubview(resetKeyButton)
        resetKeyButton.addTarget(self, action: #selector(resetKeys), for: .touchUpInside)
        self.resetKeyButton = resetKeyButton
        
        let signMessageButton = UIButton(type: .roundedRect)
        signMessageButton.setTitle("Sign Message", for: .normal)
        signMessageButton.translatesAutoresizingMaskIntoConstraints = false
        signMessageButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stackView.addArrangedSubview(signMessageButton)
        signMessageButton.addTarget(self, action: #selector(signMessage), for: .touchUpInside)
        self.signMessageButton = signMessageButton
        
        refreshView()
    }
    
    private func refreshView() {
        let keys = try? DSNPWallet().loadKeys()
        let keysExist = (keys != nil) ? true : false
        loadKeyButton?.isHidden = !keysExist
        createKeyButton?.isHidden = keysExist
        importKeyButton?.isHidden = keysExist
        exportKeyButton?.isHidden = !keysExist
        resetKeyButton?.isHidden = !keysExist
        signMessageButton?.isHidden = !keysExist
    }
    
    @objc func loadKeys() {
        do {
            let keys = try DSNPWallet().loadKeys()
            let alert = UIAlertController.ok(title: "Public Key", message: keys?.publicKeyRaw)
            present(alert, animated: true, completion: nil)
            refreshView()
        } catch {
            let alert = UIAlertController.ok(title: "Error Loading Keys")
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func createNewKeys() {
        do {
            let _ = try DSNPWallet().createKeys()
            refreshView()
        } catch {
            let alert = UIAlertController.ok(title: "Error Creating New Keys")
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func resetKeys() {
        do {
            try DSNPWallet().deleteKeys()
            refreshView()
        } catch {
            let alert = UIAlertController.ok(title: "Keys Not Found")
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func exportKeys() {
        let alert = UIAlertController(title: "Export Key", message: "Enter Password", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            let textInput = alert.textFields?.first
            do {
                let export = try DSNPWallet().exportKeys(password: textInput?.text ?? "")
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = dir.appendingPathComponent("export.txt")
                    try export?.write(to: fileURL)
                    let documentController = UIDocumentPickerViewController(forExporting: [fileURL])
                    self.present(documentController, animated: true, completion: nil)
                }
            } catch {
                let alert = UIAlertController.ok(title: "Error Exporting Keys")
                self.present(alert, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func importKeys() {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let documentBrowserController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.text], asCopy: true)
            documentBrowserController.directoryURL = dir
            documentBrowserController.allowsMultipleSelection = false
            documentBrowserController.delegate = self
            self.present(documentBrowserController, animated: true, completion: nil)
        }
    }
    
    @objc func signMessage() {
        do {
            let signature = try DSNPWallet().sign("Hello World")
            let string = signature?.base64EncodedString()
            let alert = UIAlertController.ok(title: "\"Hello World\"", message: string ?? "<nil>")
            present(alert, animated: true, completion: nil)
        } catch {
            let alert = UIAlertController.ok(title: "Error Loading Keys")
            present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        self.uploadDataFromUrl(url: url)
    }
    
    func uploadDataFromUrl(url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            let alert = UIAlertController(title: "Import Key", message: "Enter Password", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.isSecureTextEntry = true
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                let textInput = alert.textFields?.first
                do {
                    let data = try Data(contentsOf: url)
                    let _ = try DSNPWallet().importKeys(data: data, password: textInput?.text ?? "")
                    self.refreshView()
                } catch {
                    self.present(UIAlertController.ok(title: "Error", message: error.localizedDescription), animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController.ok(title: "Error Loading File")
            present(alert, animated: true, completion: nil)
        }
    }
}

extension UIAlertController {
    
    static func ok(title: String? = nil, message: String? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
}
