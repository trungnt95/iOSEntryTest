//
//  TableBindingHelper.swift
//  DTMvvm
//
//  Created by apolo2 on 18/08/2021.
//

/*
 This class is using for tableView binding helper without generic View or ViewController
 We can create View or ViewController from xib or storyboard, then binding with helper
 */

import UIKit
import RxSwift
import RxCocoa

open class TableBindingHelper<VM: IListViewModel>: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    public typealias CVM = VM.CellViewModelElement
    
    public var disposeBag: DisposeBag? = DisposeBag()
    
    private var _viewModel: VM?
    public var viewModel: VM? {
        get { return _viewModel }
        set {
            if _viewModel != newValue {
                disposeBag = DisposeBag()
                
                _viewModel = newValue
                viewModelChanged()
            }
        }
    }
    
    public var tableView: UITableView
    
    public required init(tableView: UITableView, viewModel: VM? = nil) {
        self.tableView = tableView
        super.init()
        initialize()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.viewModel = viewModel
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        }
    }
    
    open func initialize() {}
    
    private func viewModelChanged() {
        bindViewAndViewModel()
        (_viewModel as? IReactable)?.reactIfNeeded()
    }
    
    open func bindViewAndViewModel() {
        tableView.rx.itemSelected.asObservable()
            .subscribe(onNext: { [weak self] indexPath in
                self?.onItemSelected(indexPath)
            }) => disposeBag
        viewModel?.itemsSource.collectionChanged
            .subscribe(onNext: { [weak self] changeSet in
                self?.onDataSourceChanged(changeSet)
            }) => disposeBag
    }
    
    private func onItemSelected(_ indexPath: IndexPath) {
        guard let viewModel = self.viewModel else { return }
        let cellViewModel = viewModel.itemsSource[indexPath.row, indexPath.section]
        
        viewModel.rxSelectedItem.accept(cellViewModel)
        viewModel.rxSelectedIndex.accept(indexPath)
        
        viewModel.selectedItemDidChange(cellViewModel)
        
        selectedItemDidChange(cellViewModel)
    }
    
    open func datasourceDidUpdate(_ changeSet: ChangeSet) {}
    
    private func onDataSourceChanged(_ changeSet: ChangeSet) {
        if changeSet.animated {
            switch changeSet {
                case let data as ModifySection:
                    switch data.type {
                        case .insert:
                            tableView.insertSections([data.section], with: .top)
                            
                        case .delete:
                            if data.section < 0 {
                                if tableView.numberOfSections > 0 {
                                    let sections = IndexSet(0...tableView.numberOfSections - 1)
                                    tableView.deleteSections(sections, with: .bottom)
                                } else {
                                    tableView.reloadData()
                                }
                            } else {
                                tableView.deleteSections([data.section], with: .bottom)
                            }
                            
                        default:
                            if data.section < 0 {
                                if tableView.numberOfSections > 0 {
                                    let sections = IndexSet(0...tableView.numberOfSections - 1)
                                    tableView.reloadSections(sections, with: .automatic)
                                } else {
                                    tableView.reloadData()
                                }
                            } else {
                                tableView.reloadSections(IndexSet([data.section]), with: .automatic)
                            }
                    }
                case let data as ModifyElements:
                    switch data.type {
                        case .insert:
                            tableView.insertRows(at: data.indexPaths, with: .top)
                            
                        case .delete:
                            tableView.deleteRows(at: data.indexPaths, with: .bottom)
                            
                        default:
                            tableView.reloadRows(at: data.indexPaths, with: .automatic)
                    }
                    
                case let data as MoveElements:
                    tableView.beginUpdates()
                    
                    for (i, fromIndexPath) in data.fromIndexPaths.enumerated() {
                        let toIndexPath = data.toIndexPaths[i]
                        tableView.moveRow(at: fromIndexPath, to: toIndexPath)
                    }
                    
                    tableView.endUpdates()
                default:
                    tableView.reloadData()
            }
            datasourceDidUpdate(changeSet)
        } else {
            tableView.reloadData()
            datasourceDidUpdate(changeSet)
        }
    }
    
    // MARK: - Abstract for subclasses
    
    /**
     Subclasses have to override this method to return correct cell identifier based `CVM` type.
     */
    open func cellIdentifier(_ cellViewModel: CVM) -> String {
        fatalError("Subclasses have to implement this method.")
    }
    
    /**
     Subclasses override this method to handle cell pressed action.
     */
    open func selectedItemDidChange(_ cellViewModel: CVM) { }
    
    // MARK: - Table view datasources
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.itemsSource.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.itemsSource.countElements(at: section) ?? 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else {
            return UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        
        let cellViewModel = viewModel.itemsSource[indexPath.row, indexPath.section]
        
        // set index for each cell
        (cellViewModel as? IIndexable)?.indexPath = indexPath
        
        let identifier = cellIdentifier(cellViewModel)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let cell = cell as? IAnyView {
            cell.anyViewModel = cellViewModel
        }
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // MARK: - Table view delegates
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil
    }
}
