//
//  NotificationItemCell.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import UIKit
import Kingfisher

final class NotificationItemCell: BaseTableViewCell {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var avatarImageview: UIImageView!
    @IBOutlet private weak var reactionImageView: UIImageView!
    @IBOutlet private weak var createdTimeLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageview.kf.cancelDownloadTask()
        avatarImageview.kf.setImage(with: URL(string: ""))
        avatarImageview.image = nil
        
        reactionImageView.kf.cancelDownloadTask()
        reactionImageView.kf.setImage(with: URL(string: ""))
        reactionImageView.image = nil
    }
    
    override func setupUI() {
        selectionStyle = .none
        reactionImageView.image = nil
        
        avatarImageview.image = nil
        avatarImageview.layer.cornerRadius = 28.0
        avatarImageview.clipsToBounds = true
        
        createdTimeLabel.font = .systemFont(ofSize: 12, weight: .regular)
        createdTimeLabel.textColor = Colors.secondaryTextColor
    }
    
    func bindItem(_ item: NotificationItem) {
        let data = item.notificationData
        let attributedText = getHighlightedMessage(data.message.text, highlights: data.message.highlights)
        messageLabel.attributedText = attributedText
        createdTimeLabel.text = data.createdAt.toDateTime()
        containerView.backgroundColor = (data.status == .unread) ? Colors.unreadNotificationBackgroundColor : Colors.readNotificationBackgroundColor
        
        avatarImageview.kf.setImage(with: URL(string: data.imageUrl),
                                    options: [.scaleFactor(UIScreen.main.scale), .transition(.fade(0.5))])
        reactionImageView.kf.setImage(with: URL(string: data.iconUrl),
                                    options: [.scaleFactor(UIScreen.main.scale), .transition(.fade(0.5))])
    }

    private func getHighlightedMessage(_ text: String, highlights: [DomainMessageHighlight]) -> NSAttributedString {
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

