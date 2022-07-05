//
//  NewNotificationListVC.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 04/07/2022.
//

import UIKit
import DTMvvm
import RxSwift
import RxCocoa

final class NewNotificationListVC: Page<NewNotificationListVM> {
    
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
    
    // MARK: - Properties
    private var notificationsTableViewBinding: NotificationsVMTableBinding? = nil
    private var searchResultsTableViewBinding: NotificationsVMTableBinding? = nil
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initialize() {
        super.initialize()
        navigationController?.navigationBar.isHidden = true
        setupMainView()
        setupSearchView()
    }
    
    override func bindViewAndViewModel() {
        super.bindViewAndViewModel()
        
        let showSearchViewObs = searchButton.rx.tap
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
            .map { false }
        
        let hideSearchViewObs = closeSearchButton.rx.tap
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
            .map { true }

        Observable.merge(showSearchViewObs, hideSearchViewObs)
            .subscribe(onNext: { [weak self] in
                if $0 {
                    self?.resetSearchView()
                }
                self?.searchView.isHidden = $0
            })
        => disposeBag
        
        if let vm = viewModel {
            searchTextField.rx.text.orEmpty
                .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
                ~> vm.searchText
                => disposeBag
        }
    }
    
    private func resetSearchView() {
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
        viewModel?.searchText.accept("")
    }
    
    private func setupMainView() {
        titleLabel.textColor = Colors.primaryTextColor
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.text = "Thông báo"

        notificationsTableView.backgroundColor = Colors.screenBackgroundColor
        notificationsTableView.showsVerticalScrollIndicator = false
        notificationsTableView.separatorStyle = .none
        notificationsTableViewBinding = NotificationsVMTableBinding(tableView: notificationsTableView, viewModel: viewModel?.mainListVM)
    }
    
    private func setupSearchView() {
        searchView.isHidden = true
        searchBarView.clipsToBounds = true
        searchBarView.layer.cornerRadius = 20.0
        searchTextField.font = .systemFont(ofSize: 16, weight: .regular)
        searchTextField.textColor = Colors.primaryTextColor
        searchTextField.autocorrectionType = .no
        searchTextField.spellCheckingType = .no
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.placeholder = "Tìm kiếm"
        
        searchResultsTableView.showsVerticalScrollIndicator = false
        searchResultsTableView.separatorStyle = .none
        searchResultsTableViewBinding = NotificationsVMTableBinding(tableView: searchResultsTableView, viewModel: viewModel?.searchListVM)
    }
}

