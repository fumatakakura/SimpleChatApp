//
//  ChatViewController.swift
//  SimpleChatApp
//
//  Created by 高倉楓麻 on 2019/12/04.
//  Copyright © 2019 高倉楓麻. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var documentID: String = ""
    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        let db = Firestore.firestore()
        
        //コレクションに変更があったら始動
        db.collection("messages").order(by: "createdAt", descending: true).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                return
            }
            
            var results: [Message] = []
            for document in documents {
                let message = document.get("message") as! String
                let documentId = Message(documentId: document.documentID, text: message)
                
                results.append(documentId)
            }
            
            self.messages = results
        }
        
        
        
    }
    
    @IBAction func didClickButton(_ sender: UIButton) {
        
        //空文字チェック
        if textField.text!.isEmpty{
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("rooms").document("").collection("message").addDocument(data:["text": textField.text!,"sentDate": FieldValue.serverTimestamp()]){error in
            if let err = error {
                print(err.localizedDescription)
            } else {
                print("メッセージ投稿完了")
            }
            
        }
        
        textField.text = ""
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = messages[indexPath.row].text
        
        return cell
        
    }

}
