//
//  FactorCollectionCell.swift
//  EpidemicSimulator
//
//  Created by Someone on 08.05.2023.
//

import UIKit

final class FactorCollectionCell: UICollectionViewCell {
    class var identifier: String { return String(describing: self) }
    
    private lazy var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNumber(for indexPath: IndexPath) {
        label.text = "\(indexPath.row + 1)"
    }
    
    func select() {
        contentView.backgroundColor = Styles.Color.yellow
    }
    
    func deselect() {
        contentView.backgroundColor = Styles.Color.mustardWithAlpha
    }
    
    private func layout() {
        contentView.backgroundColor = Styles.Color.mustardWithAlpha
        contentView.layer.cornerRadius = contentView.frame.width / 2
        contentView.layer.masksToBounds = true
        
        contentView.addSubviews([label])
        label.textColor = Styles.Color.black
        label.font = Styles.inputFont
        label.textAlignment = .center
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
}
