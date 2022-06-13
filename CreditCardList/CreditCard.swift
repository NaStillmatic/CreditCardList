//
//  CreditCard.swift
//  CreditCardList
//
//  Created by HwangByungJo  on 2022/06/13.
//

import Foundation

struct CreditCard: Codable {
  
  let id: Int
  let rank: Int
  let name: String
  let cardImageURL: String
  let promotionDetail: PromotionDetail
  
  let isSelected: Bool?
}

struct PromotionDetail: Codable {
  
  let companyName: String
  let amount: Int
  let period: String
  let condition: String
  let benefitCondition: String
  let benefitDetail: String
  let benefitDate: String
  
}
