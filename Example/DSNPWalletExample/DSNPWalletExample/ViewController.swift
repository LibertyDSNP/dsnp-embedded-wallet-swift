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
        
        refreshView()
    }
    
    private func refreshView() {
        let keys = try? DSNPWallet().loadKeys()
        let keysExist = (keys != nil) ? true : false
        stackView?.refreshView(keysExist: keysExist)
    }
    
    private func loadKeys() {
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
    
    private func createNewKeys() {
        do {
            let _ = try DSNPWallet().createKeys()
            refreshView()
        } catch {
            let alert = UIAlertController.ok(title: "Error Creating New Keys")
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func resetKeys() {
        do {
            try DSNPWallet().deleteKeys()
            refreshView()
        } catch {
            let alert = UIAlertController.ok(title: "Keys Not Found")
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func exportKeys() {
        let alert = UIAlertController(title: "Export Key", message: "Enter Password", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            let textInput = alert.textFields?.first
            do {
                let export = try DSNPWallet().exportKeys(password: textInput?.text ?? "")
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = dir.appendingPathComponent("dsnp_keys.txt")
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
    
    private func importKeys() {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let documentBrowserController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.text], asCopy: true)
            documentBrowserController.directoryURL = dir
            documentBrowserController.allowsMultipleSelection = false
            documentBrowserController.delegate = self
            self.present(documentBrowserController, animated: true, completion: nil)
            // Import will occur in UIDocumentPickerDelegate:didPickDocumentsAt
        }
    }
    
    private func signMessage() {
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
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first,
           FileManager.default.fileExists(atPath: url.path) {
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
