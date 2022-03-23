//
//  ViewController.swift
//  DSNPWalletExample
//
//  Created by Rigo Carbajal on 3/22/22.
//

import UIKit
import DSNPWallet
import UniformTypeIdentifiers

class View: UIView {
    
    private var loadKeyButton: UIButton?
    private var createKeyButton: UIButton?
    private var importKeyButton: UIButton?
    private var exportKeyButton: UIButton?
    private var resetKeyButton: UIButton?
    private var signMessageButton: UIButton?
    
    public var didPressLoadKeys: (() -> Void)?
    public var didPressCreateKeys: (() -> Void)?
    public var didPressImportKeys: (() -> Void)?
    public var didPressExportKeys: (() -> Void)?
    public var didPressResetKeys: (() -> Void)?
    public var didPressSignMessage: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupView() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.text = "Wallet"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        stackView.addArrangedSubview(titleLabel)
        
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        stackView.addArrangedSubview(divider)
        
        let loadKeyButton = UIButton(title: "View Key", target: self, action: #selector(loadKeys))
        stackView.addArrangedSubview(loadKeyButton)
        self.loadKeyButton = loadKeyButton
        
        let createKeyButton = UIButton(title: "Create Key", target: self, action: #selector(createNewKeys))
        stackView.addArrangedSubview(createKeyButton)
        self.createKeyButton = createKeyButton

        let importKeyButton = UIButton(title: "Import Key", target: self, action: #selector(importKeys))
        stackView.addArrangedSubview(importKeyButton)
        self.importKeyButton = importKeyButton
        
        let exportKeyButton = UIButton(title: "Export Key", target: self, action: #selector(exportKeys))
        stackView.addArrangedSubview(exportKeyButton)
        self.exportKeyButton = exportKeyButton
        
        let resetKeyButton = UIButton(title: "Reset Key", target: self, action: #selector(resetKeys))
        stackView.addArrangedSubview(resetKeyButton)
        self.resetKeyButton = resetKeyButton
        
        let signMessageButton = UIButton(title: "Sign Message", target: self, action: #selector(signMessage))
        stackView.addArrangedSubview(signMessageButton)
        self.signMessageButton = signMessageButton
        
        self.refreshView()
    }
    
    public func refreshView() {
        let keys = try? DSNPWallet().loadKeys()
        let keysExist = (keys != nil) ? true : false
        loadKeyButton?.isHidden = !keysExist
        createKeyButton?.isHidden = keysExist
        importKeyButton?.isHidden = keysExist
        exportKeyButton?.isHidden = !keysExist
        resetKeyButton?.isHidden = !keysExist
        signMessageButton?.isHidden = !keysExist
    }
    
    @objc private func loadKeys() { self.didPressLoadKeys?() }
    @objc private func createNewKeys() { self.didPressCreateKeys?() }
    @objc private func importKeys() { self.didPressImportKeys?() }
    @objc private func exportKeys() { self.didPressExportKeys?() }
    @objc private func resetKeys() { self.didPressResetKeys?() }
    @objc private func signMessage() { self.didPressSignMessage?() }
}

extension UIButton {
    
    convenience init(title: String?, target: Any?, action: Selector) {
        self.init(type: .roundedRect)
        self.setTitle(title, for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.addTarget(target, action: action, for: .touchUpInside)
    }
}

class ViewController: UIViewController {
    
    private var stackView: View?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stackView = View()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.didPressLoadKeys = { self.loadKeys() }
        stackView.didPressCreateKeys = { self.createNewKeys() }
        stackView.didPressImportKeys = { self.importKeys() }
        stackView.didPressExportKeys = { self.exportKeys() }
        stackView.didPressResetKeys = { self.resetKeys() }
        stackView.didPressSignMessage = { self.signMessage() }
        self.stackView = stackView
    }
    
    func loadKeys() {
        do {
            let keys = try DSNPWallet().loadKeys()
            let alert = UIAlertController.ok(title: "Public Key", message: keys?.publicKeyRaw)
            present(alert, animated: true, completion: nil)
            stackView?.refreshView()
        } catch {
            let alert = UIAlertController.ok(title: "Error Loading Keys")
            present(alert, animated: true, completion: nil)
        }
    }
    
    func createNewKeys() {
        do {
            let _ = try DSNPWallet().createKeys()
            stackView?.refreshView()
        } catch {
            let alert = UIAlertController.ok(title: "Error Creating New Keys")
            present(alert, animated: true, completion: nil)
        }
    }
    
    func resetKeys() {
        do {
            try DSNPWallet().deleteKeys()
            stackView?.refreshView()
        } catch {
            let alert = UIAlertController.ok(title: "Keys Not Found")
            present(alert, animated: true, completion: nil)
        }
    }
    
    func exportKeys() {
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
    
    func importKeys() {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let documentBrowserController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.text], asCopy: true)
            documentBrowserController.directoryURL = dir
            documentBrowserController.allowsMultipleSelection = false
            documentBrowserController.delegate = self
            self.present(documentBrowserController, animated: true, completion: nil)
        }
    }
    
    func signMessage() {
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
                    self.stackView?.refreshView()
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
