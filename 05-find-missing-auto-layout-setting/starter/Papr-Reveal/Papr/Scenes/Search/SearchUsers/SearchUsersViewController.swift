//  
//  SearchUsersViewController.swift
//  Papr
//
//  Created by Joan Disho on 12.05.18.
//  Copyright © 2018 Joan Disho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SearchUsersViewController: UIViewController, BindableType {

    typealias SearchUsersSectionModel = SectionModel<String, UserCellModelType>

    // MARK: ViewModel
    var viewModel: SearchUsersViewModel!

    // MARK: Private
    private var tableView: UITableView!
    private var loadingView: LoadingView!
    private var dataSource: RxTableViewSectionedReloadDataSource<SearchUsersSectionModel>!
    private let disposeBag = DisposeBag()

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        configureLoadingView()
    }

    // MARK: - BindableType

    func bindViewModel() {
        let inputs = viewModel.input
        let outputs = viewModel.output

        outputs.navTitle
            .bind(to: rx.title)
            .disposed(by: disposeBag)

        outputs.usersViewModel
            .map { [SearchUsersSectionModel(model: "", items: $0)] }
            .execute { [unowned self] _ in
                self.loadingView.stopAnimating()
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx.reachedBottom()
            .bind(to: inputs.loadMore)
            .disposed(by: disposeBag)
    }

    // MARK: UI
    private func configureLoadingView() {
        loadingView = LoadingView(frame: tableView.frame)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func configureTableView() {
        tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        tableView.register(cellType: UserCell.self)
        tableView.rowHeight = 60
        dataSource = RxTableViewSectionedReloadDataSource<SearchUsersSectionModel>(
            configureCell:  tableViewDataSource
        )
    }

    private var tableViewDataSource: RxTableViewSectionedReloadDataSource<SearchUsersSectionModel>.ConfigureCell {
        return { _, tableView, indexPath, cellModel in
            var cell = tableView.dequeueResuableCell(withCellType: UserCell.self, forIndexPath: indexPath)
            cell.bind(to: cellModel)

            return cell
        }
    }
}
