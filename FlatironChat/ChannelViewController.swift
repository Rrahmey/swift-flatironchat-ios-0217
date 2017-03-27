//
//  InboxViewController.swift
//
//
//  Created by Johann Kerr on 3/23/17.
//
//

import UIKit
import Firebase
import FirebaseDatabase

class ChannelViewController: UITableViewController {
    
    
    
    var channels = [Channel]()
    var channelNames:[String] {
        get {
            var names = [String]()
            for channel in channels {
                names.append(channel.name)
            }
            return names
        }
    }
    
    let user = UserDefaults.standard.string(forKey: "screenName")!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getChannels()
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "msgSegue" {
            
            if let dest = segue.destination as? MessageViewController {
                if let index = self.tableView.indexPathForSelectedRow?.row {
                    let channel = self.channels[index].name
                    dest.channelId = channel
                    dest.senderId = user
                    print("The user is", user)
                    dest.senderDisplayName = user
                }
            }
        }
    }
    
    func getChannels() {
        
        self.channels.removeAll()
        
        FIRDatabase.database().reference().child("channels").observe(.childAdded, with: {snapshot in
            
            
            let channelName = snapshot.key
            
            if let channelDict = snapshot.value as? [String: Any] {
                
                if let participants = channelDict["participants"] as? [String:Any] {
                    let participantCount = participants.count
                    if let lastMessage = channelDict["lastMessage"] as? String {
                        let newChannel = Channel(name: channelName, lastMsg: lastMessage, numberOfParticipants: participantCount)
                        self.channels.append(newChannel)
                    } else {
                        let newChannel = Channel(name: channelName, lastMsg: nil, numberOfParticipants: participantCount)
                        self.channels.append(newChannel)
                    }
                }
            }
            
            
            
            self.tableView.reloadData()
            
        }
        
        )}
        
        
        
        
        
        


@IBAction func createBtnPressed(_ sender: Any) {
    
    let alertController = UIAlertController(title: "Create Channel", message: "Create a new channel", preferredStyle: .alert)
    alertController.addTextField { (textField) in
        textField.placeholder = "Channel Name"
    }
    
    let create = UIAlertAction(title: "Create", style: .default) { (action) in
        if let channelName = alertController.textFields?[0].text {
            if self.channelNames.contains(channelName) {
                self.duplicateChatAlert()
            } else {
            let channel = Channel(name: channelName, lastMsg: nil, numberOfParticipants: 1)
            self.channels.append(channel)
            FIRDatabase.database().reference().child("channels").child(channel.name).setValue(true)
            FIRDatabase.database().reference().child("messages").child(channel.name).setValue(true)
            
            let preferences = UserDefaults.standard
            guard let name = preferences.string(forKey: "screenName") else { return }
            FIRDatabase.database().reference().child("users").child(name).child("channels").setValue([channel.name: true])
            FIRDatabase.database().reference().child("channels").child(channel.name).child("participants").setValue([name: true])
            print(name)
            
            self.tableView.reloadData()
            
        }
        }
    }
    
    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        
    }
    
    alertController.addAction(create)
    alertController.addAction(cancel)
    
    self.present(alertController, animated: true, completion: {
        self.tableView.reloadData()
    })
    
}


}


extension ChannelViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return channels.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath)
        
        cell.textLabel?.text = channels[indexPath.row].name
        cell.detailTextLabel?.text = channels[indexPath.row].lastMsg
        
        
        return cell
    }
    
    
    func duplicateChatAlert() {
    let alert = UIAlertController(title: "ALERT", message: "Chat already exists! Please choose new name", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
}
