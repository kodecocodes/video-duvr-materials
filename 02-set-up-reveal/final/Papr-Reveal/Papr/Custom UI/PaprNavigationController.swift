//
//  PaprNavigationController.swift
//  Papr
//
//  Created by Joan Disho on 22.07.18.
//  Copyright © 2018 Joan Disho. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Nuke
import RxNuke
import Action

class PaprNavigationController: UINavigationController {

    // MARK: Properties

    private static let imagePipeline = Nuke.ImagePipeline.shared
    private let disposeBag = DisposeBag()

    private var service: UserServiceType!
    private var sceneCoordiantor: SceneCoordinatorType!

    private lazy var showUserProfileAction: CocoaAction = {
        let viewModel = UserProfileViewModel()
        return CocoaAction { [unowned self] in
            self.sceneCoordiantor.transition(to: Scene.userProfile(viewModel))
        }
    }()

    // MARK: Init

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    init(rootViewController: UIViewController,
        service: UserServiceType = UserService(),
        sceneCoordiantor: SceneCoordinatorType = SceneCoordinator.shared) {
        super.init(rootViewController: rootViewController)

        self.service = service
        self.sceneCoordiantor = sceneCoordiantor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        configureNavigationBar()
    }

    // MARK: Helpers

    private func configureNavigationBar() {
        navigationBar.tintColor = .black
        navigationBar.isTranslucent = false

        let profileImage = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        profileImage.isHidden = true
        profileImage.roundCorners(withRadius: Papr.Appearance.Style.imageCornersRadius)

        var button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        profileImage.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: profileImage.topAnchor),
            button.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor),
            button.heightAnchor.constraint(equalToConstant: profileImage.frame.size.height),
            button.widthAnchor.constraint(equalToConstant: profileImage.frame.size.width),
        ])

        let profileImageBarButtonItem = UIBarButtonItem(customView: profileImage)
        button.rx.action = showUserProfileAction

        topViewController?.navigationItem.leftBarButtonItem = profileImageBarButtonItem
        topViewController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

        service.getMe()
            .map { result -> User? in
                switch result {
                case let .success(user):
                    profileImage.isHidden = false
                    return user
                case .failure:
                    return nil
                }
            }
            .unwrap()
            .map { $0.profileImage?.medium }
            .unwrap()
            .mapToURL()
            .flatMap { PaprNavigationController.imagePipeline.rx.loadImage(with: $0) }
            .orEmpty()
            .map { $0.image }
            .bind(to: profileImage.rx.image)
            .disposed(by: disposeBag)
    }
}
