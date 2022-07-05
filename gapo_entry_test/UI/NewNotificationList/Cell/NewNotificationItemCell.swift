//
//  NewNotificationItemCell.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 04/07/2022.
//

import UIKit
import DTMvvm
import RxCocoa
import RxSwift
import Kingfisher

private extension NotificationStatus {
    var bgColor: UIColor {
        switch self {
        case .unread:
            return Colors.unreadNotificationBackgroundColor
        case .read:
            return Colors.readNotificationBackgroundColor
        }
    }
}

final class NewNotificationItemCellVM: CellViewModel<DomainNotification> {
    private let rxAvatar = BehaviorRelay<UIImage?>(value: nil)
    private let rxReactionIcon = BehaviorRelay<UIImage?>(value: nil)
    private let rxContent = BehaviorRelay<DomainNotificationMessage?>(value: nil)
    private let rxCreatedAt = BehaviorRelay<Date?>(value: nil)
    private let rxState = BehaviorRelay<NotificationStatus>(value: .unread)
    
    private(set) lazy var avatarObservable: Observable<UIImage?> = {
        return rxAvatar.share(replay: 1)
    }()
    
    private(set) lazy var reactionIconObservable: Observable<UIImage?> = {
        return rxReactionIcon.share(replay: 1)
    }()
    
    private(set) lazy var contentObservable: Observable<DomainNotificationMessage?> = {
        return rxContent.share(replay: 1)
    }()
    
    private(set) lazy var createdAtObservable: Observable<Date?> = {
        return rxCreatedAt.share(replay: 1)
    }()
    
    private(set) lazy var stateObservable: Observable<NotificationStatus> = {
        return rxState.share(replay: 1)
    }()
    
    func updateState() {
        if let modelState = model?.status, modelState != rxState.value {
            rxState.accept(modelState)
        }
    }
    
    override func react() {
        guard let domainModel = model else { return }
        
        loadImage(with: URL(string: domainModel.imageUrl), storage: rxAvatar)
        loadImage(with: URL(string: domainModel.iconUrl), storage: rxReactionIcon)
        rxContent.accept(domainModel.message)
        rxCreatedAt.accept(domainModel.createdAt)
        rxState.accept(domainModel.status)
    }
    
    private func loadImage(with url: URL?, storage: BehaviorRelay<UIImage?>) {
        guard let imgUrl = url else { return }
        KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: imgUrl, cacheKey: imgUrl.absoluteString)) { result in
            switch result {
            case .success(let resultImage):
                storage.accept(resultImage.image)
            case .failure(_):
                break
            }
        }
    }
}

final class NewNotificationItemCell: TableCell<NewNotificationItemCellVM> {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var avatarImageview: UIImageView!
    @IBOutlet private weak var reactionImageView: UIImageView!
    @IBOutlet private weak var createdTimeLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        selectionStyle = .none
        reactionImageView.image = nil
        
        avatarImageview.image = nil
        avatarImageview.layer.cornerRadius = 28.0
        avatarImageview.clipsToBounds = true
        
        createdTimeLabel.font = .systemFont(ofSize: 12, weight: .regular)
        createdTimeLabel.textColor = Colors.secondaryTextColor
    }
    
    override func bindViewAndViewModel() {
        super.bindViewAndViewModel()
        guard let vm = viewModel else { return }
        
        vm.avatarObservable
            .observe(on: MainScheduler.instance)
            ~> avatarImageview.rx.image
            => disposeBag
        
        vm.reactionIconObservable
            .observe(on: MainScheduler.instance)
            ~> reactionImageView.rx.image
            => disposeBag
        
        vm.createdAtObservable
            .map { $0?.toDateTime() }
            ~> createdTimeLabel.rx.text
            => disposeBag
        
        vm.stateObservable
            .map { $0.bgColor }
            ~> containerView.rx.backgroundColor
            => disposeBag
        
        vm.contentObservable
            .map { msg -> NSAttributedString in
                guard let msg = msg else {
                    return NSAttributedString(string: "")
                }
                
                return NewNotificationItemCell.getHighlightedMessage(msg.text, highlights: msg.highlights)
            }
            ~> messageLabel.rx.attributedText
            => disposeBag
        
    }
    
    private static func getHighlightedMessage(_ text: String, highlights: [DomainMessageHighlight]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.setAttributes([.foregroundColor: Colors.primaryTextColor,
                                        .font: UIFont.systemFont(ofSize: 14, weight: .regular)],
                                       range: NSRange(location: 0, length: attributedString.length))
        
        highlights.forEach { highlight in
            attributedString.setAttributes([.font: UIFont.systemFont(ofSize: 14, weight: .semibold)],
                                           range: NSRange(location: highlight.offset, length: highlight.length))
        }
        
        return attributedString
    }
}
