//
//  SettingsChangeViewController.swift
//  Rendering Engine
//
//  Created by AlChWi on 12/26/20.
//

import Cocoa

protocol SettingsChangeViewControllerDelegate: class {
    func changeValueOfSetting(_ data: Any?, dataIndex: Int, dataType: Any?, xVal: Float, yVal: Float, zVal: Float)
}

class SettingsChangeViewController: NSViewController {
    var data: Any? = nil
    var dataIndex: Int = 0
    var modelDataType: ModelSetting? = nil
    var lightDataType: LightSetting? = nil
    weak var delegate: SettingsChangeViewControllerDelegate? = nil
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var xTextField: NSTextField!
    @IBOutlet weak var yTextField: NSTextField!
    @IBOutlet weak var zTextField: NSTextField!
    private var isError = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaultTitle()
    }
    
    private func setDefaultTitle() {
        if let data = data as? Model {
            titleLabel.stringValue = "Model \(data.name), setting - \(modelDataType?.rawValue)"
        } else if let data = data as? Light {
            titleLabel.stringValue = "Light type \(data.type.rawValue), setting - \(lightDataType?.rawValue)"
        }
        isError = false
    }
    
    @IBAction func didPressOkButton(_ sender: NSButton) {
        //CharacterSet(["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "0", "."])
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: xTextField.stringValue)),
              CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: yTextField.stringValue)),
              CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: zTextField.stringValue)),
              !xTextField.stringValue.isEmpty,
              !yTextField.stringValue.isEmpty,
              !zTextField.stringValue.isEmpty else {
            if !isError {
                titleLabel.stringValue = "Please enter only digits"
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                    guard let self = self else { return }
                    if !self.isError {
                        self.setDefaultTitle()
                    }
                }
                isError = true
            }
            return
        }
        if let data = data as? Model {
            delegate?.changeValueOfSetting(data,
                                           dataIndex: dataIndex,
                                           dataType: modelDataType,
                                           xVal: Float(xTextField.stringValue) ?? 0,
                                           yVal: Float(yTextField.stringValue) ?? 0,
                                           zVal: Float(zTextField.stringValue) ?? 0)
        } else if let data = data as? Light {
            delegate?.changeValueOfSetting(data,
                                           dataIndex: dataIndex,
                                           dataType: lightDataType,
                                           xVal: Float(xTextField.stringValue) ?? 0,
                                           yVal: Float(yTextField.stringValue) ?? 0,
                                           zVal: Float(zTextField.stringValue) ?? 0)
        }
        dismiss(self)
    }
    
    @IBAction func didPressCancelButton(_ sender: NSButton) {
        dismiss(self)
    }
}
