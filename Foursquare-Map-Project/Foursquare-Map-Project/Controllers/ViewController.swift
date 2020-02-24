//
//  ViewController.swift
//  Foursquare-Map-Project
//
//  Created by Oscar Victoria Gonzalez  on 2/21/20.
//  Copyright © 2020 Oscar Victoria Gonzalez . All rights reserved.
//

import UIKit
import ImageKit
import MapKit

class ViewController: UIViewController {
    
    var mainView = MainView()
    
    var venues = [Venues]() {
        didSet {
            DispatchQueue.main.async {
                self.loadMapView()
            }
        }
    }
    
  
    
    var latLong = "" {
        didSet {

        }
        
    }
    

    //    var item = [Items]() {
    //        didSet {
    //            DispatchQueue.main.async {
    //                self.mainView.collectionView.reloadData()
    //            }
    //        }
    //    }
    
    private let locationSession = CoreLocationSession()
    
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Search"
        tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 0)
        configureMapView()
        configureSearchBar()
        loadMapView()
        mainView.cancelButton.addTarget(self, action: #selector(detailButtonWasPressed(_:)), for: .touchUpInside)
    }
    
    func getLocation(query: String, location: String) {
        locationSession.convertPlacemarksToCordinate(adressString: location) { (result) in
            switch result {
            case .failure(let appError):
                print("app Error \(appError)")
            case .success(let latLong):
                self.latLong = "\(latLong.lat),\(latLong.long)"
            }
        }
        fetchVenues(query: query, location: latLong)
    }
    
    
    
    private func configureSearchBar() {
        mainView.searchBar.delegate = self
        mainView.locationSearchBar.delegate = self
    }
    
    private func configureMapView() {
        mainView.mapView.showsUserLocation = true
        mainView.mapView.delegate = self
    }
    
    private func fetchVenues(query: String, location: String) {
        VenuesAPIClient.getVenues(query: query, latLong: location) { (result) in
            switch result {
            case .failure(let appError):
                print("app error \(appError)")
            case .success(let venues):
                self.venues = venues
            }
        }
    }
    
    func makeAnnotations() -> [MKPointAnnotation] {
        var annotations = [MKPointAnnotation]()
        for locations in venues {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: locations.location.lat, longitude: locations.location.lng)
            annotation.title = locations.name
            annotations.append(annotation)
        }
        return annotations
    }
    
    
    private func loadMapView() {
        let annotations = makeAnnotations()
        mainView.mapView.addAnnotations(annotations)
        mainView.mapView.showAnnotations(annotations, animated: true)
    }
    
    
    //    private func configureCollectionView() {
    //        mainView.collectionView.dataSource = self
    //        mainView.collectionView.delegate = self
    //        mainView.collectionView.register(LocationsCell.self, forCellWithReuseIdentifier: "venueCell")
    //    }
    
    //    func loadPhotoData() {
    //        VenuesAPIClient.getVenues(query: "tacos") { (result) in
    //            switch result {
    //            case .failure(let appError):
    //                print("app error \(appError)")
    //            case .success(let venues):
    //                self.venues = venues
    //                var venueIDs = ""
    //                for value in venues {
    //                    venueIDs = value.id
    //                }
    //                print(venueIDs.count)
    //                VenuesAPIClient.getPhotos(venuesID: venueIDs) { (result) in
    //                       switch result {
    //                       case .failure(let appError):
    //                           print("app error \(appError)")
    //                       case .success(let items):
    //                           self.item = items
    //                       }
    //                   }
    //            }
    //        }
    //    }
    
    //    func getPhotos() {
    //        VenuesAPIClient.getPhotos(venuesID: "" ) { (result) in
    //            switch result {
    //            case .failure(let appError):
    //                print("app error \(appError)")
    //            case .success(let items):
    //                self.item = items
    //            }
    //        }
    //
    //    }
    
    @objc
    func detailButtonWasPressed(_ input: UIButton) {
        let resultsVC = ResultsViewController()
        navigationController?.pushViewController(resultsVC, animated: true)
    }
    
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("didSelect")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else {
            return nil
        }
        
        let identifier = "LocatioAnnotation"
        var annotationView: MKPinAnnotationView
        // try to deque
        if let dequeView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            annotationView = dequeView
        } else {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccesoryControllTaped")
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar == mainView.searchBar {
            getLocation(query: mainView.searchBar.text ?? "", location: mainView.locationSearchBar.text ?? "")
            searchBar.resignFirstResponder()
        } else if searchBar == mainView.locationSearchBar {
            getLocation(query: mainView.searchBar.text ?? "", location: mainView.locationSearchBar.text ?? "")
            searchBar.resignFirstResponder()
        }
        
    }
}





//extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return item.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "venueCell", for: indexPath) as? LocationsCell else {
//            fatalError("could not get cell")
//        }
//
//
////        let venue = venues[indexPath.row]
//
//        let photo = item[indexPath.row]
//
//        cell.venueImage.getImage(with: "\(photo.prefix)400x400\(photo.suffix)") { (result) in
//            switch result {
//            case .failure(let appError):
//                print("app error \(appError)")
//            case .success(let image):
//                DispatchQueue.main.async {
//                    cell.venueImage.image = image
//                }
//            }
//        }
//
//        cell.backgroundColor = .gray
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 300, height: 300)
//    }
//}


