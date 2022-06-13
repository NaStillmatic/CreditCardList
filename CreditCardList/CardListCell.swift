//
//  CardListCell.swift
//  CreditCardList
//
//  Created by HwangByungJo  on 2022/06/13.
//

import UIKit
import Kingfisher

class CardListCell: UITableViewCell {
  
  @IBOutlet weak var cardNameLabel: UILabel!
  @IBOutlet weak var promotionLabel: UILabel!
  @IBOutlet weak var rankLabel: UILabel!
  @IBOutlet weak var cardImageView: UIImageView!

  
  func updateItems(data: CreditCard) {
        
    rankLabel.text = "\(data.rank)위"
    promotionLabel.text = "\(data.promotionDetail.amount)만원 증정"
    cardNameLabel.text =  "\(data.name)"
    
    let imgURL = URL(string: data.cardImageURL)
    cardImageView.kf.setImage(with: imgURL)
  }
  
}
