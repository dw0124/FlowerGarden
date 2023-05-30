//
//  HomeDetailTableViewCell.swift
//  FlowerGarden
//
//  Created by 박지용 on 2022/09/16.
//

import UIKit

class HomeDetailTableViewCell: UITableViewCell {
    
    
    @IBOutlet var menuImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

