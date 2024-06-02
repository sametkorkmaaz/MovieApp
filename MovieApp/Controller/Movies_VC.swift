//
//  Movies_VC.swift
//  MovieApp
//
//  Created by Samet Korkmaz on 31.05.2024.
//

import UIKit
import Alamofire

class Movies_VC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var moviesResults = [[String:AnyObject]]()
    var imagesResults = [String]()
    var titlesResults = [String]()
    var yearsResults = [String]()
    var typesResults = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
}

extension Movies_VC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titlesResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MovieCell
        let poster = imagesResults[indexPath.row]
        AF.request("\(poster)").responseData { (response) in
            switch response.result {
            case .success(let value):
                cell.posterView.image = UIImage(data: value)
            case .failure(_):
                cell.posterView.image = UIImage(named: "Unknown")
            }
        }
        let title = titlesResults[indexPath.row]
        let year = yearsResults[indexPath.row]
        let type = typesResults[indexPath.row]
        cell.titleLabel.text = title
        cell.yearLabel.text = year
        cell.typeLabel.text = type
        return cell
    }
}

// MARK: - Table View Delegate

extension Movies_VC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue" {
            if let destination = segue.destination as? Detail_TableVC {
                let dict = moviesResults[(tableView.indexPathForSelectedRow! as NSIndexPath).row]
                print("çalıştı")
                destination.imdbID = dict["imdbID"] as? String
            }
        }
    }
    
  /*  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let animation = AnimationFactory.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.5, delayFactor: 0.05)
        let animator = Animator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: tableView)
    }*/
}
