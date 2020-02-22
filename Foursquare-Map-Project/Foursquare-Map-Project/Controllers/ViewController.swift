//
//  ViewController.swift
//  Foursquare-Map-Project
//
//  Created by Oscar Victoria Gonzalez  on 2/21/20.
//  Copyright © 2020 Oscar Victoria Gonzalez . All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemYellow
        VenuesAPIClient.getVenues { (result) in
            switch result {
            case .failure(let appError):
                print("error \(appError)")
            case .success(let venue):
                dump(venue)
            }
        }
    }


}

