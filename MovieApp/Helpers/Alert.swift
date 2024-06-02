//
//  Alert.swift
//  MovieApp
//
//  Created by Samet Korkmaz on 1.06.2024.
//

import Foundation
import UIKit

class AlertManager {
    
    static let shared = AlertManager() // Singleton instance
    
    private init() {}
    
    func showAlert(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
