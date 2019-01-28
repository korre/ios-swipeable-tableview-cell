//
//  TableViewCell.swift
//  swipablecell
//
//  Created by Kristoffer Matsson on 2019-01-26.
//  Copyright © 2019 Happanero Development. All rights reserved.
//

import UIKit

class TableViewCell: SwipeableTableViewCell {
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        contentView.backgroundColor = .white
        setupBackview()
    }
    
    private func setupBackview() {
        let view = BackSideView(frame: .zero)
        
        view.backgroundColor = UIColor(red: 0.9373, green: 0.9373, blue: 0.9373, alpha: 1.0)
        
        let button1 = createButton(iconName: "bookmark")
        let button2 = createButton(iconName: "heart")
        
        view.contentView.addSubview(button1)
        view.contentView.addSubview(button2)
        
        button1.trailingAnchor.constraint(equalTo: view.contentView.trailingAnchor, constant: -10).isActive = true
        button1.topAnchor.constraint(equalTo: view.contentView.topAnchor).isActive = true
        button1.bottomAnchor.constraint(equalTo: view.contentView.bottomAnchor).isActive = true
        button1.leadingAnchor.constraint(equalTo: button2.trailingAnchor, constant: 10) .isActive = true
        
        button2.topAnchor.constraint(equalTo: view.contentView.topAnchor).isActive = true
        button2.bottomAnchor.constraint(equalTo: view.contentView.bottomAnchor).isActive = true
        button2.leadingAnchor.constraint(equalTo: view.contentView.leadingAnchor, constant: 10) .isActive = true
        
        backSideView = view
    }
    
    private func createButton(iconName: String) -> UIButton {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.blue, for: .normal)
        button.setImage(UIImage(named: iconName), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        return button
    }
}
