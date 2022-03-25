//
//  View.swift
//  DSNPWalletExample
//
//  Created by Rigo Carbajal on 3/22/22.
//

import UIKit

class View: UIView {
    
    private var loadKeyButton: UIButton!
    private var createKeyButton: UIButton!
    private var importKeyButton: UIButton!
    private var exportKeyButton: UIButton!
    private var resetKeyButton: UIButton!
    private var signMessageButton: UIButton!
    
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
        
        loadKeyButton = UIButton(title: "View Key", target: self, action: #selector(loadKeys))
        createKeyButton = UIButton(title: "Create Key", target: self, action: #selector(createNewKeys))
        importKeyButton = UIButton(title: "Import Key", target: self, action: #selector(importKeys))
        exportKeyButton = UIButton(title: "Export Key", target: self, action: #selector(exportKeys))
        resetKeyButton = UIButton(title: "Reset Key", target: self, action: #selector(resetKeys))
        signMessageButton = UIButton(title: "Sign Message", target: self, action: #selector(signMessage))
        
        stackView.addArrangedSubview(loadKeyButton)
        stackView.addArrangedSubview(createKeyButton)
        stackView.addArrangedSubview(importKeyButton)
        stackView.addArrangedSubview(exportKeyButton)
        stackView.addArrangedSubview(resetKeyButton)
        stackView.addArrangedSubview(signMessageButton)
        
        self.refreshView(keysExist: false)
    }
    
    public func refreshView(keysExist: Bool) {
        loadKeyButton.isHidden = !keysExist
        createKeyButton.isHidden = keysExist
        importKeyButton.isHidden = keysExist
        exportKeyButton.isHidden = !keysExist
        resetKeyButton.isHidden = !keysExist
        signMessageButton.isHidden = !keysExist
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
