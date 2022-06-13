//
//  CardListViewController.swift
//  CreditCardList
//
//  Created by HwangByungJo  on 2022/06/13.
//

import UIKit

import FirebaseDatabase

class CardListViewController: UITableViewController {
  
  var ref: DatabaseReference! // firebase Realtime Database
  var creditCardList: [CreditCard] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
        
    let nibName = UINib(nibName: "CardListCell", bundle: nil)
    tableView.register(nibName, forCellReuseIdentifier: "CardListCell")
    
    ref = Database.database().reference()
    
    ref.observe(.value) { snapshot in
      guard let value = snapshot.value as? [String : [String: Any]] else { return }
      
      do {
        
        let jsonData = try JSONSerialization.data(withJSONObject: value)
        let cardData = try JSONDecoder().decode([String : CreditCard].self, from: jsonData)
        let cardList = Array(cardData.values)
        self.creditCardList = cardList.sorted{ $0.rank < $1.rank }
        
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
        
      } catch let error {
        print("Error JSON parsing: \(error.localizedDescription)")
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return creditCardList.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardListCell", for: indexPath) as? CardListCell else { return UITableViewCell() }
                    
    let data = creditCardList[indexPath.row]
    cell.updateItems(data: data)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    guard let detailVC = storyboard.instantiateViewController(withIdentifier: "CardDetailViewController") as? CardDetailViewController else { return }
    
    detailVC.promotionDatail = creditCardList[indexPath.row].promotionDetail
    self.show(detailVC, sender: nil)
    
    // option 1
    let cardID = creditCardList[indexPath.row].id
    ref.child("Item\(cardID)/isSelected").setValue(true)
    
    // option 2
    ref.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value) { [weak self] snapshot in
      
      guard let self = self,
            let value = snapshot.value as? [String : [String : Any]],
            let key = value.keys.first else { return }
      
      self.ref.child("\(key)/isSelected").setValue(true)
              
    }
  }
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
    if editingStyle == .delete {
      
      // option 1
      
      let cardID = creditCardList[indexPath.row].id
//      ref.child("Item\(cardID)").removeValue()
      
      // option 2
      
      ref.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value) { [weak self] snapshot in
        guard let self = self,
              let value = snapshot.value as? [String : [String : Any]],
              let key = value.keys.first else { return }
        
        self.ref.child(key).removeValue()
        
      }
    }
  }
}
