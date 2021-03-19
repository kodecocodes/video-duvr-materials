//
//  LoadingView.swift
//  Papr
//
//  Created by Joan Disho on 18.09.18.
//  Copyright © 2018 Joan Disho. All rights reserved.
//

import Foundation
import UIKit

class LoadingView: UIView {

    private let activityIndicatorView = UIActivityIndicatorView(style: .gray)

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 30),
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 30),
        ])

        activityIndicatorView.startAnimating()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func stopAnimating() {
        activityIndicatorView.stopAnimating()
        isHidden = true
    }
}
