//
//  CollectionBindingHelper.swift
//  DTMvvm
//
//  Created by apolo2 on 09/09/2021.
//

import UIKit
import RxSwift
import RxCocoa

open class CollectionBindingHelper<VM: IListViewModel>: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public typealias CVM = VM.CellViewModelElement
    
    private var counter = [Int: Int]()

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
    
    public var collectionView: UICollectionView
    
    public required init(collectionView: UICollectionView, viewModel: VM? = nil) {
        self.collectionView = collectionView
        super.init()
        initialize()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.collectionViewLayout = collectionViewLayout()
        self.viewModel = viewModel
    }
    
    /**
     Subclasses override this method to create its own collection view layout.
     
     By default, flow layout will be used.
     */
    open func collectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewFlowLayout()
    }

    open func initialize() {}

    private func viewModelChanged() {
        bindViewAndViewModel()
        (_viewModel as? IReactable)?.reactIfNeeded()
    }
    
    /// Every time the viewModel changed, this method will be called again, so make sure to call super for CollectionPage to work
    open func bindViewAndViewModel() {
        updateCounter()
        collectionView.rx.itemSelected.asObservable()
            .subscribe(onNext: { [weak self] indexPath in
                self?.onItemSelected(indexPath)
            }) => disposeBag
        viewModel?.itemsSource.collectionChanged
            .subscribe(onNext: { [weak self] changeSet in
                self?.onDataSourceChanged(changeSet)
            }) => disposeBag
    }
    
    open func datasourceDidUpdate(_ changeSet: ChangeSet) {}

    private func onItemSelected(_ indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        let cellViewModel = viewModel.itemsSource[indexPath.row, indexPath.section]
        
        viewModel.rxSelectedItem.accept(cellViewModel)
        viewModel.rxSelectedIndex.accept(indexPath)
        
        viewModel.selectedItemDidChange(cellViewModel)
        selectedItemDidChange(cellViewModel)
    }
    
    private func onDataSourceChanged(_ changeSet: ChangeSet) {
        if !changeSet.animated || (changeSet.type == .reload && collectionView.numberOfSections == 0) {
            updateCounter()
            collectionView.reloadData()
            datasourceDidUpdate(changeSet)
        } else {
            collectionView.performBatchUpdates({
                switch changeSet {
                case let data as ModifySection:
                    switch data.type {
                    case .insert:
                        collectionView.insertSections(IndexSet([data.section]))
                    
                    case .delete:
                        if data.section < 0 {
                            let sections = Array(0...collectionView.numberOfSections - 1)
                            collectionView.deleteSections(IndexSet(sections))
                        } else {
                            collectionView.deleteSections(IndexSet([data.section]))
                        }
                        
                    default:
                        if data.section < 0 {
                            let sections = Array(0...collectionView.numberOfSections - 1)
                            collectionView.reloadSections(IndexSet(sections))
                        } else {
                            collectionView.reloadSections(IndexSet([data.section]))
                        }
                    }
                    
                case let data as ModifyElements:
                    switch data.type {
                    case .insert:
                        collectionView.insertItems(at: data.indexPaths)
                        
                    case .delete:
                        collectionView.deleteItems(at: data.indexPaths)
                        
                    default:
                        collectionView.reloadItems(at: data.indexPaths)
                    }
                    
                case let data as MoveElements:
                    for (i, fromIndexPath) in data.fromIndexPaths.enumerated() {
                        let toIndexPath = data.toIndexPaths[i]
                        collectionView.moveItem(at: fromIndexPath, to: toIndexPath)
                    }
                    
                default:
                    updateCounter()
                    collectionView.reloadData()
                }
                
                // update counter
                updateCounter()
                datasourceDidUpdate(changeSet)
            }, completion: nil)
        }
    }
    
    private func updateCounter() {
        counter.removeAll()
        viewModel?.itemsSource.forEach { counter[$0] = $1.count }
    }
    
    // MARK: - Abstract for subclasses
    
    /**
     Subclasses have to override this method to return correct cell identifier based `CVM` type.
     */
    open func cellIdentifier(_ cellViewModel: CVM) -> String {
        fatalError("Subclasses have to implemented this method.")
    }
    
    /**
     Subclasses override this method to handle cell pressed action.
     */
    open func selectedItemDidChange(_ cellViewModel: CVM) { }
    
    // MARK: - Collection view datasources
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return counter.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return counter[section] ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel else {
            return UICollectionViewCell(frame: .zero)
        }
        
        let cellViewModel = viewModel.itemsSource[indexPath.row, indexPath.section]
        
        // set index for each cell
        (cellViewModel as? IIndexable)?.indexPath = indexPath
        
        let identifier = cellIdentifier(cellViewModel)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        if let cell = cell as? IAnyView {
            cell.anyViewModel = cellViewModel
        }
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return (nil as UICollectionReusableView?)!
    }
    
    // MARK: - Collection view delegates
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .zero
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
