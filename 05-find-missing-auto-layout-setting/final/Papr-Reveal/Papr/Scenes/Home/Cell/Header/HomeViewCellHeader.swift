//
//  HomeViewCellHeader.swift
//  Papr
//
//  Created by Joan Disho on 27.04.19.
//  Copyright © 2019 Joan Disho. All rights reserved.
//

import UIKit
import RxSwift
import Nuke

class HomeViewCellHeader: UIView, BindableType {

    var viewModel: HomeViewCellHeaderModelType! {
        didSet {
            configureUI()
        }
    }

    private lazy var profileImageView = UIImageView()
    private lazy var stackView = UIStackView()

    private lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17.0, weight: .regular)
        return label
    }()

    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15.0, weight: .regular)
        label.textColor = .darkGray
        return label
    }()

    private lazy var updatedTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 15.0, weight: .regular)
        label.textColor = .darkGray
        return label
    }()

    private static let imagePipeline = Nuke.ImagePipeline.shared
    private let disposeBag = DisposeBag()

    func bindViewModel() {
        let outputs = viewModel.outputs
        let this = HomeViewCellHeader.self

        outputs.profileImageURL
            .flatMap { this.imagePipeline.rx.loadImage(with: $0) }
            .orEmpty()
            .map { $0.image }
            .bind(to: profileImageView.rx.image)
            .disposed(by: disposeBag)

        outputs.fullName
            .bind(to: fullNameLabel.rx.text)
            .disposed(by: disposeBag)

        outputs.userName
            .bind(to: userNameLabel.rx.text)
            .disposed(by: disposeBag)

        outputs.updatedTime
            .bind(to: updatedTimeLabel.rx.text)
            .disposed(by: disposeBag)

        applyAccessibilityLabels(with: outputs)
    }

    private func configureUI() {
        profileImageView.roundCorners(withRadius: Papr.Appearance.Style.imageCornersRadius)

        stackView.axis = .vertical
        stackView.spacing = 4.0
        stackView.distribution = .fill
        stackView.alignment = .fill

        stackView.addArrangedSubview(fullNameLabel)
        stackView.addArrangedSubview(userNameLabel)

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(profileImageView)
        NSLayoutConstraint.activate([
            profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16.0),
            profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 48.0),
            profileImageView.widthAnchor.constraint(equalToConstant: 48.0),
        ])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        stackView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 16.0).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
      
        updatedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(updatedTimeLabel)
        NSLayoutConstraint.activate([
            updatedTimeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16.0),
            updatedTimeLabel.leftAnchor.constraint(equalTo: stackView.rightAnchor, constant: 8.0),
          updatedTimeLabel.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
        ])
    }
}

extension HomeViewCellHeader {
    private func applyAccessibilityLabels(with outputs: HomeViewCellHeaderModelOutput) {
        outputs.fullName
            .subscribe(onNext: { [fullNameLabel] in
                fullNameLabel.accessibilityLabel = "Full Name: \($0)"
            })
            .disposed(by: disposeBag)

        outputs.userName
            .subscribe(onNext: { [userNameLabel] in
                userNameLabel.accessibilityLabel = "User Name: \($0)"
            })
            .disposed(by: disposeBag)

        outputs.updatedTime
            .subscribe(onNext: { [updatedTimeLabel] in
                updatedTimeLabel.accessibilityLabel = "Upload date: \($0)"
            })
            .disposed(by: disposeBag)
    }
}
