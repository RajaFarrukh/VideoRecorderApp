//
//  TagCollectionViewCell.swift
//  VideoRecorderApp
//
//  Created by Aamir Shehzad on 14/10/2022.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {

    @IBOutlet var selectedTagView: UIView!
    @IBOutlet var colorView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}


