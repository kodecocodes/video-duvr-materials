//
//  MapViewModel.swift
//  Papr
//
//  Created by Decheng Ma on 3/9/20.
//  Copyright © 2020 Joan Disho. All rights reserved.
//

import Action
import Foundation
import RxSwift

protocol MapViewModelInput {
    var dismissAction: CocoaAction { get }
}

protocol MapViewModelOutput {
    var photo: Observable<Photo> { get }
}

final class MapViewModel: MapViewModelInput, MapViewModelOutput {
    private let sceneCoordinator: SceneCoordinatorType
    private var popCancelable: Disposable?

    lazy var dismissAction: CocoaAction = {
        CocoaAction { [unowned self] _ in
            self.popCancelable = self.sceneCoordinator.pop(animated: true).subscribe()
            return .empty()
        }
    }()

    // MARK: Inputs
    var inputs: MapViewModelInput { return self }

    // MARK: Outputs
    let photo: Observable<Photo>

    init(sceneCoordinator: SceneCoordinatorType = SceneCoordinator.shared,
         photo: Observable<Photo>) {
        self.sceneCoordinator = sceneCoordinator
        self.photo = photo
    }
}
