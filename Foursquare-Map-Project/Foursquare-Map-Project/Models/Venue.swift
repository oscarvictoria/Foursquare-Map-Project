//
//  Venues.swift
//  Foursquare-Map-Project
//
//  Created by Oscar Victoria Gonzalez  on 2/22/20.
//  Copyright © 2020 Oscar Victoria Gonzalez . All rights reserved.
//

import Foundation
import CoreLocation

protocol AuthorizationStatusDelegate : AnyObject{
    func authorizationStatusChanged(status: CLAuthorizationStatus)
}

enum LocationFetchingError: Error {
    case error(Error)
    case noErrorMessage
}

struct Response: Codable {
    let response: VenueData
}

struct VenueData: Codable {
    let venues: [Venue]
}

struct Venue: Codable {
    let id, name: String
    let location: Location
    let categories: [Categories]
}

struct Location: Codable {
    let address: String?
    let lat, lng: Double
    let distance: Int
    let postalCode: String?
    let cc: String
    let neighborhood: String?
    let formattedAddress: [String]
}

struct Categories: Codable {
    let id: String
    let name: String
    let pluralName: String
    let shortName: String
    let icon: Icon
}

struct Icon: Codable {
    let prefix: String
    let suffix: String
}


struct Photos: Codable {
    let response: Pictures
}

struct Pictures: Codable {
    let photos: Foto
}

struct Foto: Codable {
    let count: Int
    let items: [Items]
}

struct Items: Codable {
    let id: String
    let prefix: String
    let suffix: String
}


class CoreLocationSession: NSObject {
    
    public var locationManager: CLLocationManager!
    
    public weak var delegate: AuthorizationStatusDelegate?
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        
        
        // the following key's need to be added to the info.plist file
        // NSLocationAlwaysAndWhenInUseUsageDescription
        // NSLocationWhenInUseUsageDescription
        
        // get updates for user location
        
        startSignificantLocationChanges()
        
//         startMonitoringRegion()
    }
    
    private func startSignificantLocationChanges() {
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            return
        }

        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    public func convertCordinateToPlacemark(cordinate: CLLocationCoordinate2D) {
        // we will use the CLGeocoder() class for converting cordinate (CLLocationCoordinate2D) to placemark (CLPlacemark)

        let location = CLLocation(latitude: cordinate.latitude, longitude: cordinate.longitude)

        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("reversedGeocodeLocation: \(error)")
            }
            if let firstPlaceMark = placemarks?.first {
                print("placemark info: \(firstPlaceMark)")
            }
        }

    }
    
    public func convertPlacemarksToCordinate(adressString: String, completion: @escaping (Result<(lat: Double, long: Double), LocationFetchingError>) -> Void) {
        let geocoder = CLGeocoder()
        DispatchQueue.global(qos: .userInitiated).async {
            geocoder.geocodeAddressString(adressString){(placemarks, error) -> Void in
                DispatchQueue.main.async {
                    if let placemark = placemarks?.first, let coordinate = placemark.location?.coordinate {
                        completion(.success((coordinate.latitude, coordinate.longitude)))
                    } else {
                        let locationError: LocationFetchingError
                        if let error = error {
                            locationError = .error(error)
                        } else {
                            locationError = .noErrorMessage
                        }
                        completion(.failure(locationError))
                        
                    }
                }
            }
        }
    }
}

extension CoreLocationSession: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            delegate?.authorizationStatusChanged(status: status)
        case .authorizedWhenInUse:
            delegate?.authorizationStatusChanged(status: status)
        case .denied:
            delegate?.authorizationStatusChanged(status: status)
        case .notDetermined:
            delegate?.authorizationStatusChanged(status: status)
        case .restricted:
            delegate?.authorizationStatusChanged(status: status)
        default:
            break
        }
    }
}
