//
//  SettingController.swift
//  Ampel Pilot
//
//  Created by Patrick Valenta on 20.10.17.
//  Copyright © 2017 Patrick Valenta. All rights reserved.
//

import UIKit
import AVFoundation

class SettingsViewController: UITableViewController {
    
    private let CAM_SECTION = 3
    private let RES_ROW = 0
    
    var viewModel: SettingsViewModel!
    
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var vibrationSwitch: UISwitch!
    @IBOutlet weak var confidenceSlider: UISlider!
    @IBOutlet weak var iouSlider: UISlider!
    @IBOutlet weak var resolutionLabel: UILabel!
    
    lazy var closeButton: UIBarButtonItem = {
        let bi = UIBarButtonItem(title: "Schließen", style: UIBarButtonItemStyle.plain, target: self, action: #selector(closeBtnPressed))
        return bi
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Einstellungen"
        
        navigationItem.rightBarButtonItems = [closeButton]
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Initialization
    
    func setupViewModel() {
        
        viewModel.confidenceThreshold.bind {
            self.confidenceSlider.setValue($0, animated: true)
        }
        
        viewModel.iouThreshold.bind {
            self.iouSlider.setValue($0, animated: true)
        }
        
        viewModel.sound.bind {
            self.soundSwitch.setOn($0, animated: true)
        }
        
        viewModel.vibrate.bind {
            self.vibrationSwitch.setOn($0, animated: true)
        }
        
        viewModel.cPreset.bind {
            self.resolutionLabel.text = self.viewModel.formatCapturePresetToText(preset: $0)
        }
        
        viewModel?.initFetch()
    }
    
    // MARK: - Actions
    @objc func closeBtnPressed() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func soundSwitchValueChanged(_ sender: UISwitch, forEvent event: UIEvent) {
        viewModel.updateSound(new: sender.isOn)
    }
    
    @IBAction func vibrationSwitchValueChanged(_ sender: UISwitch) {
        viewModel.updateVibrate(new: sender.isOn)
    }
    
    @IBAction func confidenceSliderValueChanged(_ sender: UISlider) {
        viewModel.updateConfidenceThreshold(new: sender.value)
    }
    
    @IBAction func iouSliderValueChanged(_ sender: UISlider) {
        viewModel.updateIOUThreshold(new: sender.value)
    }
    
    // MARK: - Delegates
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == CAM_SECTION && indexPath.row == RES_ROW {
            // Nav to selection screen
            if let vc = storyboard?.instantiateViewController(withIdentifier: "selectionVC") as? SelectionViewController{
                let cells = viewModel.availableResolutions
                vc.viewModel = SelectionViewModel(title: "Auflösung", cells: Box(cells))
                
                vc.viewModel.cells.bind(listener: { (fasdf) in
                    let selectedCell = fasdf.first(where: { (cellViewModel) -> Bool in
                        return cellViewModel.selected
                    })
                    
                    if let resolution = selectedCell?.value as? AVCaptureSession.Preset {
                        self.viewModel.updateCapturePreset(new: resolution)
                    }
                })
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
}