//
//  MapViewController.swift
//  Papr
//
//  Created by Decheng Ma on 3/9/20.
//  Copyright © 2020 Joan Disho. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import Nuke
import SwiftRandom

class MapViewController: UIViewController, BindableType {

    typealias ViewModelType = MapViewModel

    @IBOutlet var dismissButton: UIButton!
    @IBOutlet var mapView: MKMapView!

    var viewModel: MapViewModel!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func bindViewModel() {
        let inputs = viewModel.inputs

        dismissButton.rx.action = inputs.dismissAction

        viewModel.photo.take(1).subscribe(onNext: { [mapView] in
            guard
                let latitude = $0.location?.position?.latitude,
                let longitude = $0.location?.position?.longitude else {
                    return
            }

            let region = MKCoordinateRegion(
                center: CLLocation(latitude: latitude, longitude: longitude).coordinate,
                latitudinalMeters: 50000,
                longitudinalMeters: 60000
            )

            mapView?.setRegion(region, animated: true)

            let artwork = PhotoAnnotation(
                title: $0.user?.fullName,
                subtitle: $0.created,
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                photoUrl: $0.urls?.regular ?? $0.urls?.small ?? ""
            )

            mapView?.addAnnotation(artwork)
        })
        .disposed(by: disposeBag)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "PhotoAnnotation")

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "PhotoAnnotation")

            if let photoAnnotation = annotation as? PhotoAnnotation {
                let baseAnnotationView = BaseAnnotationView(photoAnnotation)

                annotationView?.image = baseAnnotationView.renderSelfAsImage()

                Randoms.randomGravatar { (image, error) in
                    DispatchQueue.main.async {
                        annotationView?.leftCalloutAccessoryView = UIImageView(image: image)
                    }
                }
            }
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.canShowCallout = true
        annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

        return annotationView
    }
}
