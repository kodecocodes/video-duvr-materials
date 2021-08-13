//
//  PhotoAnnotation.swift
//  Papr
//
//  Created by Decheng Ma on 4/9/20.
//  Copyright © 2020 Joan Disho. All rights reserved.
//

import MapKit
import SwiftRandom

class PhotoAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let photoUrl: String

    init(
        title: String?,
        subtitle: String?,
        coordinate: CLLocationCoordinate2D,
        photoUrl: String
    ) {
        self.title = Randoms.randomFakeName()
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.photoUrl = photoUrl

        super.init()
    }
}
