//
//  Splash_VC.swift
//  MovieApp
//
//  Created by Samet Korkmaz on 1.06.2024.
//

import UIKit
import Firebase
import FirebaseRemoteConfig

class Splash_VC: UIViewController {

    @IBOutlet weak var splashLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var network = NetworkMonitor.shared
        setupRemoteConfigDefaults()
        updateSplashLabelValue()
        fetchRemoteConfig()
        
        // Do any additional setup after loading the view.
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.checkNetworkAndProceed()
        }
    }
    
    func updateSplashLabelValue(){
        let splashLabelText = RemoteConfig.remoteConfig().configValue(forKey: "splash_text").stringValue ?? ""
        splashLabel.text = splashLabelText
    }
    
    func setupRemoteConfigDefaults(){
        let defaultValues = [
            "splashText": "Default text!" as NSObject,
            "labelConstrainConstant": 50 as NSObject
        ]
        RemoteConfig.remoteConfig().setDefaults(defaultValues)
    }
    
    func fetchRemoteConfig(){
        let debugSettings = RemoteConfigSettings()
        RemoteConfig.remoteConfig().configSettings = debugSettings
        
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: 0) {[unowned self] (status, error )in
            guard error == nil else {
                print("fetch remote values: \(error)")
                return
            }
            print("Rettieved values from the cloud!")
            RemoteConfig.remoteConfig().activate()
            self.updateSplashLabelValue()
        }
    }
    
    func splash() {
        self.performSegue(withIdentifier: "splashSegue", sender: self)
    }
    
    func checkNetworkAndProceed() {
        if NetworkMonitor.shared.isConnected {
            self.splash()
        } else {
            self.showNoInternetAlert()
        }
    }
    
    func showNoInternetAlert() {
        let alert = UIAlertController(title: "İnternet Bağlantısı Yok", message: "Lütfen internet bağlantınızı kontrol edin.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
