//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase
class ChatViewController: UIViewController {

    
    let db = Firestore.firestore();
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    
    var messages:[Message] = [
        Message(sender:"gg@gmail.com", body:"hi!"),
        Message(sender:"a@gmail.com", body:"yup?"),
        Message(sender:"gg@gmail.com",body:"Lay low my G")]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        title = K.productTitle
        navigationItem.hidesBackButton = true
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier:K.cellIdentifier)
        
        
        loadMessage()
    }
    func loadMessage(){
        
      
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { (querySnapshot, err) in
            self.messages = []
            print("Before: \(self.messages)")
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let messageSender = data[K.FStore.senderField] as? String , let messageBody = data[K.FStore.bodyField] as? String{
                        let newMessage = Message(sender: messageSender, body: messageBody)
                        self.messages.append(newMessage)
                        print("After: \(self.messages)")
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            let indexPath = IndexPath(row: self.messages.count-1, section: 0)
                            self .tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                        }
                    }
                    
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
       if let messageBody = messageTextfield.text , let messageSender = Auth.auth().currentUser?.email{
           db.collection(K.FStore.collectionName).addDocument(data: [
            K.FStore.senderField : messageSender,
            K.FStore.bodyField : messageBody,
            K.FStore.dateField : Date().timeIntervalSince1970
           ]) { (error) in
                if let e = error{
                    print("There is an error occured saving the message,\(e)")
                }else{
                    print("Message saved successfully.")
                    self.messageTextfield.text = " "
                }
            }
            
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
        
          try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
}

extension ChatViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier:K.cellIdentifier, for: indexPath) as! MessageCell
        
        cell.label.text = messages[indexPath.row].body
        
        
        if(message.sender == Auth.auth().currentUser?.email){
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }  else{
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)

        }
        return cell
        
        
        
    }
    
    
    
}

extension ChatViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
