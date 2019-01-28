//
//  SwipeableTableViewCell.swift
//  swipablecell
//
//  Created by Kristoffer Matsson on 2019-01-26.
//  Copyright © 2019 Happanero Development. All rights reserved.
//

import Foundation
import UIKit

enum SwipeableTableViewCellState {
    case open
    case moving
    case closed
}

protocol SwipeableTableViewCellDelegate: AnyObject {
    func swipeableTableCell(_ cell: SwipeableTableViewCell, didChangeStateTo state: SwipeableTableViewCellState)
}

class SwipeableTableViewCell: UITableViewCell {
    
    var backSideView: BackSideView?
    
    var state: SwipeableTableViewCellState = .closed {
        didSet {
            if state == .closed {
                self.removeBackSideView()
            }
            
            if state != oldValue {
                self.delegate?.swipeableTableCell(self, didChangeStateTo: state)
            }
        }
    }
    
    weak var delegate: SwipeableTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    private func initialize() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        gestureRecognizer.delegate = self
        
        contentView.addGestureRecognizer(gestureRecognizer)
        contentView.isUserInteractionEnabled = true
        
        selectionStyle = .none
    }
    
    func closeCell() {
        settleView(contentView, currentX: 0)
    }
    
    @objc
    private func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: contentView)
        
        if let view = recognizer.view {
            
            switch recognizer.state {
            case .began:
                addBackSideView()
            case .changed:
                moveView(view, currentX: view.frame.origin.x, translationX: translation.x)
            default:
                settleView(view, currentX: view.frame.origin.x, translationX: translation.x, velocityX: recognizer.velocity(in: view).x)
            }
        }
        
        recognizer.setTranslation(CGPoint.zero, in: contentView)
    }
    
    private func moveView(_ view: UIView, currentX: CGFloat, translationX: CGFloat = 0) {
        
        guard let backView = backSideView else {
            return
        }
        
        // Add some resistance to the motion when the full back side view is revealed
        let newX: CGFloat
        
        if abs(currentX) > backView.contentWidth {
            newX = ((backView.contentWidth / abs(currentX)) / 1.8 * translationX) + currentX
        } else {
            newX = min(currentX + translationX, 0)
        }
        
        if view.frame.origin.x != newX {
            view.frame.origin = CGPoint(x: newX, y: 0)
            
            self.state = .moving
            
            animateBackSideView(newX: newX)
        }
    }
    
    private func settleView(_ view: UIView, currentX: CGFloat, translationX: CGFloat = 0, velocityX: CGFloat = 0) {
        
        guard let backView = backSideView else {
            return
        }
        
        let openCell = shouldOpenCell(
            backView: backView,
            newX: min(currentX + translationX, 0),
            velocityX: velocityX
        )
        
        let newX = openCell ? backView.contentWidth * -1 : 0
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 3,
            options: .curveEaseInOut,
            animations: {
                self.moveView(view, currentX: newX)
            }, completion: { _ in
                self.state = abs(newX) > 0 ? .open : .closed
            })
    }
    
    private func addBackSideView() {
        guard let backView = backSideView, state == .closed else {
            return
        }
        
    
        insertSubview(backView, at: 0)
        
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    private func removeBackSideView() {
        guard let backView = backSideView else {
            return
        }
        
        backView.removeFromSuperview()
    }
    
    private func animateBackSideView(newX: CGFloat) {
        guard let backView = backSideView else {
            return
        }
        
        let translation = abs(newX)
        let fullTranslation = backView.contentWidth
        
        let scaleFactor = min(1, max(0, (translation / fullTranslation) + 0.3))
        
        backView.contentView.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        backView.contentView.alpha = scaleFactor
    }
    
    private func shouldOpenCell(backView: BackSideView, newX: CGFloat, velocityX: CGFloat) -> Bool {
        let velocity = velocityX / 3
        
        if abs(velocity) > backView.contentWidth {
            if velocityX < 0 {
                return true
            } else {
                return false
            }
        } else {
            return abs(newX) > (backView.contentWidth / 2)
        }
    }
}

extension SwipeableTableViewCell {
    
    /// Avoid pan of the cell at the same time we scroll the table view vertically
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview)
            if abs(translation.x) > abs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
}

/// A custom view to show when the table view cell is swiped away.
/// Add your content to the contentView since the BackSideView will span the full cell width.
/// How long the cell will be swiped is determined by the content views content width.
class BackSideView: UIView {
    
    let contentView = UIView()
    
    var contentWidth: CGFloat {
        return contentView.bounds.size.width
    }
    
    var contentHeight: CGFloat {
        return contentView.bounds.size.height
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
