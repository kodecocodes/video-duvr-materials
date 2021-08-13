//
//  HomeViewCell.swift
//  Papr
//
//  Created by Joan Disho on 07.01.18.
//  Copyright © 2018 Joan Disho. All rights reserved.
//

import UIKit
import RxSwift
import Nuke
import RxNuke
import Photos
import Hero

class HomeViewCell: UICollectionViewCell, BindableType,  ClassIdentifiable {

    // MARK: ViewModel
    var viewModel: HomeViewCellModelType! {
        didSet {
            configureUI()
        }
    }

    // MARK: Private
    private let stackView = UIStackView()
    private var headerView = HomeViewCellHeader()
    private var photoButton = UIButton()
    private let photoImageView = UIImageView()
    private var footerView = HomeViewCellFooter()

    private static let imagePipeline = Nuke.ImagePipeline.shared
    private var disposeBag = DisposeBag()

    // MARK: Overrides

    override func prepareForReuse() {
        super.prepareForReuse()

        photoImageView.image = nil
        photoButton.rx.action = nil

        disposeBag = DisposeBag()
    }

    // MARK: BindableType
    func bindViewModel() {
        let inputs = viewModel.inputs
        let outputs = viewModel.outputs
        let this = HomeViewCell.self

        headerView.bind(to: outputs.headerViewModelType)
        footerView.bind(to: outputs.footerViewModelType)

        outputs.photoStream
            .map { $0.id }
            .unwrap()
            .bind(to: photoImageView.rx.heroId)
            .disposed(by: disposeBag)

        outputs.photoStream
            .bind { [weak self] in
                self?.photoButton.rx.bind(to: inputs.photoDetailsAction, input: $0)
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            outputs.smallPhotoURL,
            outputs.regularPhotoURL,
            outputs.fullPhotoURL)
            .flatMap { smallPhotoURL, regularPhotoURL, fullPhotoURL -> Observable<ImageResponse> in
                return Observable.concat(
                    this.imagePipeline.rx.loadImage(with: smallPhotoURL).asObservable(),
                    this.imagePipeline.rx.loadImage(with: regularPhotoURL).asObservable(),
                    this.imagePipeline.rx.loadImage(with: fullPhotoURL).asObservable()
                )
        }
            .orEmpty()
            .map { $0.image }
            .bind(to: photoImageView.rx.image)
            .disposed(by: disposeBag)

        applyAccessibilityLabels(with: outputs)
    }

    private func configureUI() {

        let headerViewHeight: CGFloat = 80.0
        let footerViewHeight: CGFloat = 60.0

        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        ])

        photoButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(photoButton)
        NSLayoutConstraint.activate([
            photoButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: headerViewHeight),
            photoButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: footerViewHeight),
            photoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            photoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        ])

        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: headerViewHeight).isActive = true
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.heightAnchor.constraint(equalToConstant: footerViewHeight).isActive = true

        photoButton.isExclusiveTouch = true

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0.0

        stackView.addArrangedSubview(headerView)
        stackView.addArrangedSubview(photoImageView)
        stackView.addArrangedSubview(footerView)
    }
}

extension HomeViewCell {
    private func applyAccessibilityLabels(with outputs: HomeViewCellModelOutput) {
        outputs.photoStream
            .map(\.description)
            .unwrap()
            .subscribe(onNext: { [photoButton] in
                photoButton.accessibilityLabel = "Image: \($0)"
            })
            .disposed(by: disposeBag)
    }
}

