//
//  UITableView+EmptyView.swift
//  NordicDemoApp
//
//  Created by Eliseo on 7/27/22.
//

import UIKit

struct UIButtonAction {
    let title: String
    let handler: () -> ()
}

extension UIView {
    
    /// Sets an empty view, initially hidden.
    func setEmptyView(title: String, message: String, messageImage: UIImage,
                      action: UIButtonAction? = nil) {
        var emptyView: UIView! = subviews.first(where: { $0.tag == 100 })
        
        if emptyView == nil {
            emptyView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 340))
            emptyView.tag = .emptyView
            emptyView.alpha = 0
            
            let messageImageView = UIImageView()
            let titleLabel = UILabel()
            let messageLabel = UILabel()
            
            messageImageView.backgroundColor = .clear
            messageImageView.alpha = 0.6
            messageImageView.tag   = .image
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            messageImageView.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            
            if #available(iOS 13.0, *) {
                messageImageView.tintColor = .secondaryLabel
                messageLabel.textColor = .secondaryLabel
            } else {
                messageImageView.tintColor = .darkText
                messageLabel.textColor = .darkText
            }
            messageLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
            
            emptyView.addSubview(titleLabel)
            emptyView.addSubview(messageImageView)
            emptyView.addSubview(messageLabel)
            
            NSLayoutConstraint.activate([
                messageImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
                messageImageView.topAnchor.constraint(equalTo: emptyView.topAnchor, constant: 10),
                messageImageView.widthAnchor.constraint(equalToConstant: 100),
                messageImageView.heightAnchor.constraint(equalToConstant: 100),
                
                titleLabel.topAnchor.constraint(equalTo: messageImageView.bottomAnchor, constant: 10),
                titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
                
                messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
                messageLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor)
            ])
            
            messageImageView.image = messageImage
                        
            titleLabel.text = title.uppercased()
            titleLabel.textColor = .gray
            titleLabel.font = .systemFont(ofSize: 15.0, weight: .semibold)
            titleLabel.tag = .title
            
            messageLabel.text = message
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.tag = .message
            
            emptyView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(emptyView)
            
            NSLayoutConstraint.activate([
                emptyView.centerXAnchor.constraint(equalTo: centerXAnchor),
                NSLayoutConstraint(item: emptyView!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 0.8, constant: 0),
                emptyView.leadingAnchor.constraint(equalTo: leadingAnchor),
                emptyView.trailingAnchor.constraint(equalTo: trailingAnchor),
                emptyView.heightAnchor.constraint(equalToConstant: 340)
            ])
            
            updateEmptyView(title: title, message: message, action: action)
        }
    }
    
    func updateEmptyView(title: String, message: String, action: UIButtonAction? = nil) {
        guard let emptyView = subviews.first(where: { $0.tag == .emptyView }),
              let titleLabel = emptyView.subviews.first(where: { $0.tag == .title }) as? UILabel,
              let messageLabel = emptyView.subviews.first(where: { $0.tag == .message }) as? UILabel else {
            return
        }
        titleLabel.text = title
        messageLabel.text = message
        
        guard let actionButton = emptyView.subviews.first(where: { $0.tag == .action }) as? UIButton else {
            guard let action = action else { return }
            
            let actionButton = UIButton(type: .custom)
            actionButton.setTitle(action.title, for: .normal)
            actionButton.setTitleColor(.white, for: .normal)
            actionButton.backgroundColor = .gray
            actionButton.layer.cornerRadius = 4
            actionButton.layer.masksToBounds = true
            actionButton.setAction(closure: action.handler)
            actionButton.tag = .action
            actionButton.translatesAutoresizingMaskIntoConstraints = false
            
            emptyView.addSubview(actionButton)
            NSLayoutConstraint.activate([
                actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
                actionButton.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
                actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 120)
            ])
            return
        }
        if let action = action {
            actionButton.setTitle(action.title, for: .normal)
            actionButton.setAction(closure: action.handler)
        } else {
            actionButton.removeFromSuperview()
            actionButton.tag = 0
        }
    }
    
    func showEmptyView() {
        if let emptyView = subviews.first(where: { $0.tag == .emptyView }) {
            UIView.animate(withDuration: 0.5, animations: {
                emptyView.alpha = 1.0
            }, completion: { _ in
                if let messageImageView = emptyView.subviews.first(where: { $0.tag == .image }) {
                    UIView.animate(withDuration: 1.0, delay: 0.4, animations: {
                        messageImageView.transform = CGAffineTransform(rotationAngle: .pi / 10)
                    }, completion: { _ in
                        UIView.animate(withDuration: 1.0, animations: {
                            messageImageView.transform = CGAffineTransform(rotationAngle: -1 * (.pi / 10))
                        }, completion: { _ in
                            UIView.animate(withDuration: 1.0, animations: {
                                messageImageView.transform = CGAffineTransform.identity
                            })
                        })
                    })
                }
            })
        }
    }
    
    func hideEmptyView(_ animated: Bool = true) {
        if let emptyView = subviews.first(where: { $0.tag == 100 }) {
            if animated {
                UIView.animate(withDuration: 0.5) {
                    emptyView.alpha = 0.0
                }
            } else {
                emptyView.alpha = 0.0
            }
        }
    }
    
}

protocol Editable {
    var tableView: UITableView! { get set }
    
    /// Shows the 'Empty View'.
    func showEmptyView()
    /// Hides the 'Empty View'.
    func hideEmptyView(_ animated: Bool)
}

extension Editable where Self: UIViewController {
    
    func showEmptyView() {
        if navigationItem.rightBarButtonItems!.contains(editButtonItem) {
            navigationItem.rightBarButtonItems!.removeAll {
                $0 == self.editButtonItem
            }
        }
        tableView.showEmptyView()
        setEditing(false, animated: false)
        tableView.setEditing(false, animated: false)
    }
    
    func hideEmptyView(_ animated: Bool = true) {
        if !navigationItem.rightBarButtonItems!.contains(editButtonItem) {
            navigationItem.rightBarButtonItems!.append(editButtonItem)
        }
        tableView.hideEmptyView(animated)
    }
    
}

private extension UIButton {
    
    private func setOrTriggerClosure(closure: (() -> ())? = nil) {
        // Struct to keep track of current closure
        struct __ {
            static var closure: (() -> ())?
        }

        // if closure has been passed in, set the struct to use it
        if closure != nil {
            __.closure = closure
        } else {
            // Otherwise trigger the closure
            __.closure?()
        }
    }
    
    @objc private func triggerActionClosure() {
        self.setOrTriggerClosure()
    }

    func setAction(closure: @escaping () -> ()) {
        self.setOrTriggerClosure(closure: closure)
        self.addTarget(self, action: #selector(UIButton.triggerActionClosure),
                       for: .touchUpInside)
    }
    
}

private extension Int {
    
    static let emptyView = 100
    static let image = 101
    static let title = 102
    static let message = 103
    static let action = 104
    
}
