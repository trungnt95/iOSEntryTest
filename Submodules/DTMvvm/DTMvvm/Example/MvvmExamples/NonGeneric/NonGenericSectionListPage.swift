//
//  NonGenericSectionListPage.swift
//  DTMvvm_Example
//
//  Created by ToanDK on 8/15/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
//import DTMvvm
import Action
import RxSwift
import RxCocoa

class NonGenericSectionListPage: BaseListPage {
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var sortBtn: UIButton!
    
    var viewModel: SectionListPageViewModel!
    
    override func destroy() {
        super.destroy()
        viewModel.destroy()
    }
    
    override func setupTableView(_ tableView: UITableView) {
        super.setupTableView(tableView)
        tableView.register(SectionTextCell.self, forCellReuseIdentifier: SectionTextCell.identifier)
        tableView.register(SectionImageCell.self, forCellReuseIdentifier: SectionImageCell.identifier)
    }
    
    override func bindViewAndViewModel() {
        super.bindViewAndViewModel()
        
        guard let viewModel = viewModel else { return }
        viewModel.react()
        
        addBtn.rx.bind(to: viewModel.addAction, input: ())
        sortBtn.rx.bind(to: viewModel.sortAction, input: ())
    }
    
    override func getItemSource() -> RxCollection? {
        return self.viewModel!.itemsSource
    }
    
    // Based on type to return correct identifier for cells
    override func cellIdentifier(_ cellViewModel: Any) -> String {
        if cellViewModel is SectionImageCellViewModel {
            return SectionImageCell.identifier
        }
        
        return SectionTextCell.identifier
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let vm = viewModel?.itemsSource[section].key as? SectionHeaderViewViewModel {
            let headerView = SectionHeaderView(viewModel: vm)
            return headerView
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let _ = viewModel?.itemsSource[section].key as? SectionHeaderViewViewModel {
            return 30
        }
        
        return 0
    }
}
