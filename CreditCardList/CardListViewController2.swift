//
//  CardListViewController2.swift
//  CreditCardList
//
//  Created by HwangByungJo  on 2022/06/13.
//

import UIKit
import FirebaseDatabase
import FirebaseFirestore


class CardListViewController2: UITableViewController {
  
  let db = Firestore.firestore()
  
  var creditCardList: [CreditCard] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
        
    let nibName = UINib(nibName: "CardListCell", bundle: nil)
    tableView.register(nibName, forCellReuseIdentifier: "CardListCell")
    
    
    db.collection("creditCardList").addSnapshotListener { snapshot, error in
      
      guard let documents = snapshot?.documents else {
        return print("Error Firesotre fetching document: \(String(describing: error))")
      }
      
      self.creditCardList = documents.compactMap { doc -> CreditCard? in
        do {
          let jsonData = try JSONSerialization.data(withJSONObject: doc.data(), options: [])
          let creditCard = try JSONDecoder().decode(CreditCard.self, from: jsonData)
          return creditCard
        } catch let error {
          print("Error JSON parsing: \(error)")
          return nil
        }
      }.sorted { $0.rank < $1.rank}
      
      DispatchQueue.main.async {
        self.tableView.reloadData()
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
//    db.collection("creditCardList").document("card\(cardID)").updateData(["isSelected": true])
        
    // option 2
    db.collection("creditCardList").whereField("id", isEqualTo: cardID).getDocuments { snapshot, _ in
      
      guard let document = snapshot?.documents.first else {
        print("Error Firestore fetching document")
        return
      }
      document.reference.updateData(["isSelected": true])
    }
  }
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
    if editingStyle == .delete {
      
      // option 1
      let cardID = creditCardList[indexPath.row].id
      db.collection("creditCardList").document("card\(cardID)").delete()
      
      // option 2
      db.collection("creditCardList").whereField("id", isEqualTo: cardID).getDocuments { snapshot, _ in
        
        guard let document = snapshot?.documents.first else {
          print("Error Firestore fetching document")
          return
        }
        document.reference.delete()
      }
    }
  }
}
