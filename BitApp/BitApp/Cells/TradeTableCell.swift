//
//  TradeTableCell.swift
//  BitApp
//
//  Created by ashokdy on 01/08/2021.
//

import UIKit

class TradeTableCell: UITableViewCell {
    @IBOutlet weak var amountInBTCLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var timeLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
