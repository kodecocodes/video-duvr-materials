//
//  BaseAnnotationView.swift
//  Papr
//
//  Created by Decheng Ma on 4/9/20.
//  Copyright © 2020 Joan Disho. All rights reserved.
//

import UIKit

class BaseAnnotationView: UIView {
    let photoAnnotation: PhotoAnnotation

    var imageView: UIImageView {
        guard
            let url = URL(string: photoAnnotation.photoUrl),
            let data = try? Data(contentsOf: url) else {
                return UIImageView()
        }

        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 50, height: 30))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(data: data)

        return imageView
    }

    init(_ photoAnnotation: PhotoAnnotation) {
        self.photoAnnotation = photoAnnotation
        super.init(frame: CGRect(x: 0, y: 0, width: 60, height: 60))

        setupUI()
    }

    private func setupUI() {
        let pinIconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        pinIconView.image = UIImage(named: "map-pin-icon")

        self.clipsToBounds = true
        self.addSubview(imageView)
        self.addSubview(pinIconView)
    }

    func photoView() -> UIImageView {
        self.imageView
    }

    func renderSelfAsImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { rendererContext in
            self.layer.render(in: rendererContext.cgContext)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
}
