//
//  NotificationListViewController.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import UIKit
import RxSwift
import RxCocoa

final class NotificationListViewController: BaseViewController {
    
    private struct Config {
        static let estimatedCellHeight: CGFloat = 80.0
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var notificationsTableView: UITableView!
    
    @IBOutlet private weak var searchView: UIView!
    @IBOutlet private weak var searchBarView: UIView!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var closeSearchButton: UIButton!
    @IBOutlet private weak var searchResultsTableView: UITableView!
    
    // MARK: - Other properties
    private let viewModel = NotificationListViewModel()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
        
        viewModel.fetchNotificationList()
            .subscribe(onCompleted: {
                // TODO: - Loading finish go here
            }, onError: { _ in
                // TODO: - Handle error in real project
            })
            .disposed(by: disposeBag)
    }

}

extension NotificationListViewController {
    private func setupUI() {
        navigationController?.navigationBar.isHidden = true
        setupMainView()
        setupSearchView()
        
    }
    
    private func setupMainView() {
        titleLabel.textColor = Colors.primaryTextColor
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.text = "Thông báo"

        notificationsTableView.backgroundColor = Colors.screenBackgroundColor
        notificationsTableView.rowHeight = UITableView.automaticDimension
        notificationsTableView.estimatedRowHeight = Config.estimatedCellHeight
        notificationsTableView.showsVerticalScrollIndicator = false
        notificationsTableView.separatorStyle = .none
        notificationsTableView.register(NotificationItemCell.nib, forCellReuseIdentifier: NotificationItemCell.identifier)
    }
    
    private func setupSearchView() {
        searchBarView.clipsToBounds = true
        searchBarView.layer.cornerRadius = 20.0
        searchTextField.font = .systemFont(ofSize: 16, weight: .regular)
        searchTextField.textColor = Colors.primaryTextColor
        searchTextField.autocorrectionType = .no
        searchTextField.spellCheckingType = .no
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.placeholder = "Tìm kiếm"
        
        searchResultsTableView.rowHeight = UITableView.automaticDimension
        searchResultsTableView.estimatedRowHeight = Config.estimatedCellHeight
        searchResultsTableView.showsVerticalScrollIndicator = false
        searchResultsTableView.separatorStyle = .none
        searchResultsTableView.register(NotificationItemCell.nib, forCellReuseIdentifier: NotificationItemCell.identifier)
    }
    
    private func bindUI() {
        let rowDidTapObs = notificationsTableView.rx.itemSelected.asObservable()
        let searchTextObs = searchTextField.rx.text.orEmpty.asObservable()
        let searchRowDidTapObs = searchResultsTableView.rx.itemSelected.asObservable()
        
        let input = viewModel.getInput(mainListDidTap: rowDidTapObs,
                                       searchText: searchTextObs,
                                       searchListDidTap: searchRowDidTapObs)
        
        let output = viewModel.transformInput(input)
        
        output.notificationItems
            .drive(notificationsTableView.rx.items) { tbv, idx, item in
                let cell = tbv.dequeueReusableCell(withIdentifier: item.reusable.identifier, for: IndexPath(row: idx, section: 0))
                item.configCell(cell)
                return cell
            }
            .disposed(by: disposeBag)
        
        output.mainListItemToBeUpdated
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in
                self?.notificationsTableView.reloadRows(at: [indexPath], with: .automatic)
            })
            .disposed(by: disposeBag)
        
        output.searchItems
            .drive(searchResultsTableView.rx.items) { tbv, idx, item in
                let cell = tbv.dequeueReusableCell(withIdentifier: item.reusable.identifier, for: IndexPath(row: idx, section: 0))
                item.configCell(cell)
                return cell
            }
            .disposed(by: disposeBag)
        
        output.searchListItemToBeUpdated
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in
                self?.searchResultsTableView.reloadRows(at: [indexPath], with: .automatic)
            })
            .disposed(by: disposeBag)
        
        searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.searchTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        closeSearchButton.rx.tap
            .debounce(.microseconds(150), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.hideSearchView()
            })
            .disposed(by: disposeBag)
        
        searchButton.rx.tap
            .debounce(.microseconds(150), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.showSearchView()
            })
            .disposed(by: disposeBag)
    }
    
    private func showSearchView() {
        searchView.alpha = 0
        searchView.isHidden = false
        searchTextField.becomeFirstResponder()
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: { [weak self] in
            self?.searchView.alpha = 1
        })
    }
    
    private func hideSearchView() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) { [weak self] in
            self?.searchView.alpha = 0
        } completion: { [weak self] _ in
            self?.searchView.isHidden = true
            self?.resetSearchView()
        }

    }
    
    private func resetSearchView() {
        Observable.just("")
            .bind(to: searchTextField.rx.text)
            .disposed(by: disposeBag)
        searchTextField.resignFirstResponder()
    }
}
