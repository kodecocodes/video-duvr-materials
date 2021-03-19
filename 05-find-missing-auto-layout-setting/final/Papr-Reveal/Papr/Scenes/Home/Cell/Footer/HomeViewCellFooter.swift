//
//  HomeViewCellFooter.swift
//  Papr
//
//  Created by Joan Disho on 27.04.19.
//  Copyright © 2019 Joan Disho. All rights reserved.
//

import UIKit
import RxSwift
import Nuke

class HomeViewCellFooter: UIView, BindableType {

    var viewModel: HomeViewCellFooterModelType! {
        didSet {
            configureUI()
        }
    }

    private lazy var stackViewContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0.0

        stackView.addArrangedSubview(leftViewContainer)
        stackView.addArrangedSubview(rightViewContainer)

        return stackView
    }()

    private lazy var leftViewContainer: UIView = {
        let view = UIView()

        likeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(likeButton)
        NSLayoutConstraint.activate([
            likeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16.0),
            likeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            likeButton.heightAnchor.constraint(equalToConstant: 30.0),
            likeButton.widthAnchor.constraint(equalToConstant: 30.0),
        ])

        likesNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(likesNumberLabel)
        NSLayoutConstraint.activate([
            likesNumberLabel.leftAnchor.constraint(equalTo: likeButton.rightAnchor, constant: 4.0),
            likesNumberLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }()

    private lazy var rightViewContainer: UIView = {
        let view = UIView()

        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        NSLayoutConstraint.activate([
            saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16.0),
            saveButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 30.0),
            saveButton.widthAnchor.constraint(equalToConstant: 30.0),
        ])

        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(downloadButton)
        NSLayoutConstraint.activate([
            downloadButton.rightAnchor.constraint(equalTo: saveButton.leftAnchor, constant: -16.0),
            downloadButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            downloadButton.heightAnchor.constraint(equalToConstant: 30.0),
            downloadButton.widthAnchor.constraint(equalToConstant: 30.0),
        ])

        return view
    }()

    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        return button
    }()

    private lazy var likesNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(Papr.Appearance.Icon.bookmark, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    private lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(Papr.Appearance.Icon.squareAndArrowDownMedium, for: .normal)
        return button
    }()


    // MARK: Private
    private static let imagePipeline = Nuke.ImagePipeline.shared
    private var disposeBag = DisposeBag()
    private let dummyImageView = UIImageView()

    func bindViewModel() {
        let inputs = viewModel.inputs
        let outputs = viewModel.outputs

        inputs.downloadPhotoAction.elements
            .subscribe { [unowned self] result in
                guard let linkString = result.element, let url = URL(string: linkString) else { return }
                Nuke.loadImage(with: url, into: self.dummyImageView) { result in
                    guard case let .success(response) = result else { return }
                    inputs.writeImageToPhotosAlbumAction.execute(response.image)
                }
            }
            .disposed(by: disposeBag)

        Observable.combineLatest(outputs.isLikedByUser, outputs.photo)
            .bind { [weak self] in
                self?.likeButton.rx.bind(to: $0 ? inputs.unlikePhotoAction: inputs.likePhotoAction, input: $1)
            }
            .disposed(by: disposeBag)

        outputs.photo
            .bind { [weak self] in
                self?.saveButton.rx.bind(to: inputs.userCollectionsAction, input: $0)
            }
            .disposed(by: disposeBag)

        outputs.photo
            .bind { [weak self] in
                self?.downloadButton.rx.bind(to: inputs.downloadPhotoAction, input: $0)
            }
            .disposed(by: disposeBag)

        outputs.likesNumber
            .bind(to: likesNumberLabel.rx.text)
            .disposed(by: disposeBag)

        outputs.isLikedByUser
            .map { $0 ? Papr.Appearance.Icon.heartFillMedium : Papr.Appearance.Icon.heartMedium }
            .bind(to: likeButton.rx.image())
            .disposed(by: disposeBag)

        applyAccessibilityLabels(with: outputs)
    }

    private func configureUI() {
        stackViewContainer.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(stackViewContainer)
        NSLayoutConstraint.activate([
            stackViewContainer.topAnchor.constraint(equalTo: self.topAnchor),
            stackViewContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackViewContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackViewContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        ])
    }
}

extension HomeViewCellFooter {
    func applyAccessibilityLabels(with outputs: HomeViewCellFooterModelOutput) {
        outputs.isLikedByUser
            .subscribe(onNext: { [likeButton] in
                likeButton.accessibilityLabel = $0 ? "UnLike": "Like"
            })
            .disposed(by: disposeBag)

        outputs.likesNumber
            .subscribe(onNext: { [likesNumberLabel] in
                likesNumberLabel.accessibilityLabel = "Likes: \($0)"
            })
            .disposed(by: disposeBag)

        downloadButton.accessibilityLabel = "Download"
    }
}
