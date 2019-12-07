//
//  RoomViewController.swift
//  SimpleChatApp
//
//  Created by 高倉楓麻 on 2019/12/04.
//  Copyright © 2019 高倉楓麻. All rights reserved.
//

import UIKit
import Firebase

class RoomViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    var rooms: [Room] = [] {
        didSet{
            //値が書き換わったら更新
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //Firestoreのroomsコレクションを監視
        
        let db = Firestore.firestore()
        
        //コレクションに変更があったら始動
        db.collection("rooms").order(by: "createdAt", descending: true).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                return
            }
            
            var results: [Room] = []
            for document in documents {
                let name = document.get("name") as! String
                let room = Room(name: name, documentId: document.documentID)
                
                results.append(room)
            }
            
            self.rooms = results
        }
        
    }
    
    @IBAction func didClickButton(_ sender: UIButton) {
        
        if textField.text!.isEmpty {
            return
        }
        
        let db = Firestore.firestore()
        
        //連想配列で追加
        db.collection("rooms").addDocument(data: ["name": textField.text!, "createdAt": FieldValue.serverTimestamp()]){error in
            if let err = error {
                //エラー発生時
                print(err.localizedDescription)
            } else {
                print("チャット部屋作成完了")
            }
        }
        
        textField.text = ""

    }
    

}

extension RoomViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rooms.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = rooms[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var room = rooms[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "toRoom", sender: room.documentId)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let nextVC = segue.destination as! ChatViewController
        nextVC.documentID = sender as! String

    }
    
    
    
    
}
