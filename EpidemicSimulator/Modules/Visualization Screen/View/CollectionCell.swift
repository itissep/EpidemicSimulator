//
//  CollectionCell.swift
//  EpidemicSimulator
//
//  Created by Someone on 08.05.2023.
//

import UIKit

final class CollectionCell: UICollectionViewCell {
    class var identifier: String { return String(describing: self) }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = Styles.Color.mustard
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func select() {
        contentView.backgroundColor = Styles.Color.black
    }
    
    func deselect() {
        contentView.backgroundColor = Styles.Color.mustard
    }
    
    func configureAppearance(with size: CGFloat) {
        contentView.layer.cornerRadius = size / 2
        contentView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
