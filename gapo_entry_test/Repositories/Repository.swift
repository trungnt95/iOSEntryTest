//
//  Repository.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import Foundation
import RxSwift

protocol Repository {
    associatedtype T
    
    func getList() -> Single<[T]>
}
