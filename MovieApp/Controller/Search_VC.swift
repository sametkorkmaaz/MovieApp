//
//  Search_VC.swift
//  MovieApp
//
//  Created by Samet Korkmaz on 31.05.2024.
//

import UIKit
import Alamofire
import SwiftyJSON

class Search_VC: UIViewController {

    @IBOutlet weak var search_TextField: UITextField!
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 100 ,y: 200, width: 50, height: 50)) as UIActivityIndicatorView
    
    var moviesResultsSelf = [[String:AnyObject]]()
    var moviesResults = [[String:AnyObject]]()
    var imagesResults = [String]()
    var titlesResults = [String]()
    var yearsResults = [String]()
    var typesResults = [String]()
    
    var totalResult: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.backgroundColor = (UIColor (white: 0.3, alpha: 0.8))
        activityIndicator.layer.cornerRadius = 10
        self.view.addSubview(activityIndicator)
        activityIndicator.isHidden = true
    }
    
    
    @IBAction func searchButton(_ sender: Any) {
        
        moviesResults = [[String:AnyObject]]()
        imagesResults = [String]()
        titlesResults = [String]()
        yearsResults = [String]()
        typesResults = [String]()
        
        if search_TextField.text!.count < 3 {
            return
        }
        
        guard let search = search_TextField.text else { return }
        let updatedSearch = search.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let apiKey = "&apikey=e4f84105"
        let pageLink = "http://www.omdbapi.com/?s=" + updatedSearch + apiKey
        
        guard let pageUrl = URL(string: pageLink) else { return }
        print(pageUrl)
        AF.request(pageUrl).validate().responseJSON { (response) in
            
            let errorJson = JSON(response.data!)
            if errorJson["Response"].stringValue == "False" {
                AlertManager.shared.showAlert(title: "Tekrar Dene", message: "Aranan metine uygun film veya dizi bulunamadı.", viewController: self)
            } else {
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                
                switch response.result {
                case .success(let value):
                    do {
                        let myGroup = DispatchGroup()
                        
                        let json = JSON(value)
                        let result = json["totalResults"].intValue
                        
                        let res = result % 10

                        if res > 0 {
                            self.totalResult = result / 10
                            self.totalResult += 1
                        } else {
                            self.totalResult = result / 10
                        }
                        
                        for i in 1...self.totalResult! {
                            myGroup.enter()
                            
                            let page = "&page="
                            let link = "http://www.omdbapi.com/?s=" + updatedSearch + apiKey + page + "\(i)"

                            guard let url = URL(string: link) else { return }

                            AF.request(url).validate().responseJSON { (response) in

                                switch response.result {
                                case .success(let value):
                                    do {
                                        let json = JSON(value)

                                        if let result = json["Search"].arrayObject {
                                            let search = result as! [[String:AnyObject]]
                                            self.moviesResultsSelf = result as! [[String:AnyObject]]
                                            self.moviesResults.append(contentsOf: search)
                                        }

                                        for parametr in self.moviesResultsSelf {
                                            self.imagesResults.append(parametr["Poster"] as! String)
                                            self.titlesResults.append(parametr["Title"] as! String)
                                            self.yearsResults.append(parametr["Year"] as! String)
                                            self.typesResults.append(parametr["Type"] as! String)
                                        }
                                        myGroup.leave()
                                    } catch {
                                        print(error)
                                    }
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        }
                        
                        myGroup.notify(queue: .main) {
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.isHidden = true
                            self.performSegue(withIdentifier: "searchSegue", sender: self)
                        }
                    } catch {
                        print("catch hata\(error)")
                    }
                case .failure(let error):
                    AlertManager.shared.showAlert(title: "OPSS!", message: "Aranan metine uygun film veya dizi bulunamadı.", viewController: self)
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    print("case hata\(error)")
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchSegue" {
            if let destination = segue.destination as? Movies_VC {
                destination.moviesResults = self.moviesResults
                destination.imagesResults = self.imagesResults
                destination.titlesResults = self.titlesResults
                destination.yearsResults = self.yearsResults
                destination.typesResults = self.typesResults
            }
        }
    }
}
