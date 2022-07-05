//
//  FlickerSearchPage.swift
//  DTMvvm_Example
//
//  Created by Dao Duy Duong on 10/2/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import Action
//import DTMvvm

class FlickrSearchPage: CollectionPage<FlickrSearchPageViewModel> {
    
    let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 400, height: 30))
    let indicatorView = UIActivityIndicatorView(style: .gray)
    
    let loadMoreView = UIView()
    let loadMoreIndicator = UIActivityIndicatorView(style: .whiteLarge)
    
    let padding: CGFloat = 5

    override func initialize() {
        super.initialize()
        
        enableBackButton = true
        
        // setup search bar
        indicatorView.hidesWhenStopped = true
        searchBar.placeholder = "Search for Flickr images"
        navigationItem.titleView = searchBar
        
        // setup load more
        loadMoreView.isHidden = true
        loadMoreView.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0.5)
        view.addSubview(loadMoreView)
        loadMoreView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        loadMoreIndicator.hidesWhenStopped = false
        loadMoreIndicator.startAnimating()
        loadMoreView.addSubview(loadMoreIndicator)
        loadMoreIndicator.autoAlignAxis(toSuperviewAxis: .vertical)
        loadMoreIndicator.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        loadMoreIndicator.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        
        // setup collection view
        collectionView.register(FlickrImageCell.self, forCellWithReuseIdentifier: FlickrImageCell.identifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let textField = searchBar.subviews[0].subviews.last as? UITextField {
            textField.rightView = indicatorView
            textField.rightViewMode = .always
        }
        
        loadMoreView.transform = CGAffineTransform(translationX: 0, y: loadMoreView.frame.height)
        loadMoreView.isHidden = false
    }
    
    override func bindViewAndViewModel() {
        super.bindViewAndViewModel()
        
        guard let viewModel = viewModel else { return }
        
        viewModel.rxSearchText <~> searchBar.rx.text => disposeBag
        
        // toggle show/hide indicator next to search bar
        viewModel.rxIsSearching.subscribe(onNext: { value in
            if value {
                self.indicatorView.startAnimating()
            } else {
                self.indicatorView.stopAnimating()
            }
        }) => disposeBag
        
        // toggle load more indicator when scroll to bottom
        viewModel.rxIsLoadingMore.subscribe(onNext: { value in
            UIView.animate(withDuration: 0.5, animations: {
                if value {
                    self.loadMoreView.transform = .identity
                } else {
                    self.loadMoreView.transform = CGAffineTransform(translationX: 0, y: self.loadMoreView.frame.height)
                }
            })
        }) => disposeBag
        
        // call out load more when reach to end of collection view
        collectionView.rx.endReach(30).subscribe(onNext: {
            viewModel.loadMoreAction.execute(())
        }) => disposeBag
    }
    
    // this method is required
    override func cellIdentifier(_ cellViewModel: FlickrImageCellViewModel) -> String {
        return FlickrImageCell.identifier
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewWidth = collectionView.frame.width
        
        let numOfCols: CGFloat
        if viewWidth <= 375 {
            numOfCols = 2
        } else if viewWidth <= 568 {
            numOfCols = 3
        } else if viewWidth <= 768 {
            numOfCols = 4
        } else {
            numOfCols = 5
        }
        
        let contentWidth = viewWidth - ((numOfCols + 1) * padding)
        let width = contentWidth / numOfCols
        
        return CGSize(width: width, height: 4 * width / 3)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .all(padding)
    }
}











