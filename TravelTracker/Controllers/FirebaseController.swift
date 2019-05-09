//
//  FirebaseController.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 3/31/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FirebaseController {
    
    static let shared = FirebaseController()
    
    var currentUser: User?
    var friends: [User] = []
    var friendUsernames: [String] = []
    var friendRequests: [String] = []
    var sentRequests: [String] = []
    
    enum UpdateType {
        case add
        case update
        case delete
    }
    
    func createUser(name: String, username: String, password: String, completion: @escaping (Bool) -> Void) {
        
        //checks if the their username is already taken otherwise creates a user
        Firestore.firestore().collection("users").whereField("username", isEqualTo: username).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                completion(false)
                return
            }
            
            guard snapshot.documents.count < 1 else {
                completion(false)
                return
            }
            
            Firestore.firestore().collection("users").document(username).setData([
                "name" : name,
                "username" : username,
                "password" : password,
                "friends" : [String](),
                "friendRequests" : [String](),
                "sentRequests" : [String]()
                ], completion: { (error) in
                    let user = User(name: name, username: username, password: password)
                    self.currentUser = user
                    self.saveCurrentUser(user: user)
                    completion(true)
            })
            
        }
        
    }
    
    func signIn(username: String, password: String, completion: @escaping (Bool) -> Void) {
        
        Firestore.firestore().collection("users").document(username).getDocument { (document, error) in
            if let document = document,
                let data = document.data(),
                password == data["password"] as? String,
                let name = data["name"] as? String,
                let usernames = data["friends"] as? [String],
                let yourRequests = data["friendRequests"] as? [String],
                let yourSentRequests = data["sentRequests"] as? [String] {
                
                let user = User(name: name, username: username, password: password)
                self.currentUser = user
                self.saveCurrentUser(user: user)
                
                self.friendUsernames = usernames
                self.friendRequests = yourRequests
                self.sentRequests = yourSentRequests
                
                self.generateFriendInfo(usernames: usernames, completion: {
                    completion(true)
                    return
                })
                
            } else {
                completion(false)
                return
            }
        }
        
    }
    
    // saves the current user for auto sign
    func saveCurrentUser(user: User) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(user.username, forKey: "username")
        userDefaults.set(user.password, forKey: "password")
    }
    
    func signInSavedUser(completion: @escaping (Bool) -> Void) {
        let userDefaults = UserDefaults.standard
        guard let username = userDefaults.string(forKey: "username"),
            let password = userDefaults.string(forKey: "password") else {
                completion(false)
                return
        }
        
        print("\nSigned in as \(username)\n")
        
        Firestore.firestore().collection("users").document(username).getDocument { (document, error) in
            if let document = document,
                let data = document.data(),
                password == data["password"] as? String,
                let name = data["name"] as? String,
                let usernames = data["friends"] as? [String],
                let yourRequests = data["friendRequests"] as? [String],
                let yourSentRequests = data["sentRequests"] as? [String] {
                
                self.currentUser = User(name: name, username: username, password: password)
                self.friendUsernames = usernames
                self.friendRequests = yourRequests
                self.sentRequests = yourSentRequests
                
                self.generateFriendInfo(usernames: usernames, completion: {
                    completion(true)
                    return
                })
                
            } else {
                completion(false)
                return
            }
        }
        
    }
    
    func signOutSavedUser() {
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(nil, forKey: "username")
        userDefaults.set(nil, forKey: "password")
    }
    
    func generateFriendInfo(usernames: [String], completion: @escaping () -> Void) {
        
        if usernames.count == 0 {
            completion()
            return
        }
        
        DispatchQueue.global().async {
            let group = DispatchGroup()
            
            group.enter()
            
            if let yourUsername = self.currentUser?.username {
                Firestore.firestore().collection("users").document(yourUsername).collection("markers").getDocuments(completion: { (snapshot, error) in
                    if let documents = snapshot?.documents {
                        for document in documents {
                            if let markerInfo = MarkerInfo(id: document.documentID, firebaseDict: document.data()) {
                                self.currentUser?.markers.append(markerInfo)
                            }
                        }
                        
                        group.leave()
                        
                    } else {
                        group.leave()
                    }
                })
            }
            
            for username in usernames {
                group.enter()
                
                Firestore.firestore().collection("users").document(username).getDocument(completion: { (document, error) in
                    if let name = document?.data()?["name"] as? String {
                        let user = User(name: name, username: username, password: "")
                        self.friends.append(user)
                        group.leave()
                    } else {
                        group.leave()
                    }
                })
            }
            
            group.wait()
            
            for friend in self.friends {
                group.enter()
                
                Firestore.firestore().collection("users").document(friend.username).collection("markers").getDocuments(completion: { (snapshot, error) in
                    if let documents = snapshot?.documents {
                        for document in documents {
                            if let markerInfo = MarkerInfo(id: document.documentID, firebaseDict: document.data()) {
                                friend.markers.append(markerInfo)
                            }
                        }
                        
                        group.leave()
                        
                    } else {
                        group.leave()
                    }
                })
                
            }
            
            group.wait()
            completion()
            return
        }
        
    }
    
    func updateMapMarkers(_ marker: MapMarker, type: UpdateType) {
        
        guard let username = currentUser?.username else { return }
        
        DispatchQueue.global().async {
            switch type {
            case .add:
                Firestore.firestore().collection("users").document(username).collection("markers").document(marker.info.id).setData([
                    "comment" : marker.info.comment as Any,
                    "date" : Timestamp(date: marker.info.date),
                    "xCoord" : marker.info.xCoord,
                    "yCoord" : marker.info.yCoord,
                    ])
            case .update:
                Firestore.firestore().collection("users").document(username).collection("markers").document(marker.info.id).updateData([
                    "comment" : marker.info.comment as Any,
                    ])
            case .delete:
                Firestore.firestore().collection("users").document(username).collection("markers").document(marker.info.id).delete()
            }
        }
    }
    
    func sendFriendRequest(username: String, completion: @escaping (Bool) -> Void) {
        
        //gets the friend requests of the user you requested
        Firestore.firestore().collection("users").document(username).getDocument { (document, error) in
            guard let usersFriendRequests = document?.data()?["friendRequests"] as? [String],
                let yourUsername = self.currentUser?.username else {
                completion(false)
                return
            }
            
            guard !usersFriendRequests.contains(yourUsername) else {
                print("\n\nUser was already sent a request\n\n")
                completion(false)
                return
            }
            
            var newFriendRequests: [String]
            newFriendRequests = usersFriendRequests
            newFriendRequests.append(yourUsername)
            
            //update that users friend requests now with your username
            Firestore.firestore().collection("users").document(username).updateData([
                "friendRequests" : newFriendRequests
                ], completion: { (error) in
                    if error == nil {
                        self.sentRequests.insert(username, at: 0)
                        
                        //updates your sent requests with that user
                        Firestore.firestore().collection("users").document(yourUsername).updateData([
                            "sentRequests" : self.sentRequests
                            ], completion: { (error) in
                                completion(true)
                                return
                        })
                    } else {
                        print(error!.localizedDescription)
                        completion(false)
                        return
                    }
            })
        }
    }
    
    func cancelFriendRequest(username: String, completion: @escaping (Bool) -> Void) {
        
        //gets the friend requests of the user you requested
        Firestore.firestore().collection("users").document(username).getDocument { (document, error) in
            guard let usersFriendRequests = document?.data()?["friendRequests"] as? [String],
                let yourUsername = self.currentUser?.username else {
                    completion(false)
                    return
            }
            
            //creates the new array of friend requests without your username
            var newFriendRequests: [String]
            newFriendRequests = usersFriendRequests
            for index in 0...newFriendRequests.count - 1 {
                let string = newFriendRequests[index]
                if string == yourUsername {
                    newFriendRequests.remove(at: index)
                    break
                }
            }
            
            //updates their friend requests with new array of requests
            Firestore.firestore().collection("users").document(username).updateData([
                "friendRequests" : newFriendRequests
                ], completion: { (error) in
                    if error == nil {
                        
                        //updates sent requests array
                        for index in 0...self.sentRequests.count - 1 {
                            let string = self.sentRequests[index]
                            if string == username {
                                self.sentRequests.remove(at: index)
                                break
                            }
                        }
                        
                        //updates your sent requests on firebase
                        Firestore.firestore().collection("users").document(yourUsername).updateData([
                            "sentRequests" : self.sentRequests
                            ], completion: { (error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                }
                                
                                completion(true)
                        })
                    } else {
                        completion(false)
                        return
                    }
            })
            
        }
    }
    
    func acceptFriendRequest(username: String, completion: @escaping () -> Void) {
        
        guard let yourUsername = currentUser?.username else { fatalError("current user did not exist") }
        
        //remove friend request from local array
        for index in 0...friendRequests.count - 1 {
            let string = friendRequests[index]
            if string == username {
                friendRequests.remove(at: index)
                break
            }
        }
        
        //updates your firebase without that friend request
        Firestore.firestore().collection("users").document(yourUsername).updateData([
            "friendRequests" : friendRequests
        ]) { (error) in
            guard error == nil else {
                completion()
                return
            }
            
            //gets the new friends info
            Firestore.firestore().collection("users").document(username).getDocument(completion: { (document, error) in
                if error == nil,
                    let data = document?.data(),
                    let name = data["name"] as? String,
                    let usersFriends = data["friends"] as? [String],
                    let usersSentRequests = data["sentRequests"] as? [String] {
                    
                    let newFriend = User(name: name, username: username, password: "")
                    
                    //fill out markers info for new friend
                    Firestore.firestore().collection("users").document(username).collection("markers").getDocuments(completion: { (snapshot, error) in
                        if let documents = snapshot?.documents {
                            for document in documents {
                                if let markerInfo = MarkerInfo(id: document.documentID, firebaseDict: document.data()) {
                                    newFriend.markers.append(markerInfo)
                                }
                            }
                            
                            self.friends.append(newFriend)
                            self.friendUsernames.append(username)
                            
                            //adds your new friend to your firestore
                            Firestore.firestore().collection("users").document(yourUsername).updateData([
                                "friends" : self.friendUsernames
                                ], completion: { (error) in
                                    
                                    var friendsArray = usersFriends
                                    friendsArray.append(yourUsername)
                                    
                                    //adds you the their friends list
                                    Firestore.firestore().collection("users").document(username).updateData([
                                        "friends" : friendsArray
                                        ], completion: { (error) in
                                            
                                            //removes your username
                                            var newSentRequests = usersSentRequests
                                            for index in 0...usersSentRequests.count - 1 {
                                                let string = usersSentRequests[index]
                                                if string == yourUsername {
                                                    newSentRequests.remove(at: index)
                                                    break
                                                }
                                            }
                                            
                                            //update new friend's sent requests without your username
                                            Firestore.firestore().collection("users").document(username).updateData([
                                                "sentRequests" : newSentRequests
                                                ], completion: { (error) in
                                                    completion()
                                                    return
                                            })
                                    })
                                    
                                    
                                    
                            })
                            
                            
                            
                        } else {
                            completion()
                            return
                        }
                    })
                    
                } else {
                    completion()
                    return
                }
            })
            
        }
        
    }
    
    func declineFriendRequest(username: String, completion: @escaping () -> Void) {
        
        guard let yourUsername = currentUser?.username else { fatalError("current user did not exist") }
        
        for index in 0...friendRequests.count - 1 {
            let string = friendRequests[index]
            if string == username {
                friendRequests.remove(at: index)
                break
            }
        }
        
        //updates your firestore without that friend request
        Firestore.firestore().collection("users").document(yourUsername).updateData([
            "friendRequests" : friendRequests
        ]) { (error) in
            guard error == nil else {
                completion()
                return
            }
            
            //gets users sent requests
            Firestore.firestore().collection("users").document(username).getDocument(completion: { (document, error) in
                if error == nil,
                    let data = document?.data(),
                    let usersSentRequests = data["sentRequests"] as? [String] {
                    
                    //removes your username
                    var newSentRequests = usersSentRequests
                    for index in 0...usersSentRequests.count - 1 {
                        let string = usersSentRequests[index]
                        if string == yourUsername {
                            newSentRequests.remove(at: index)
                            break
                        }
                    }
                    
                    //updates the user's sent requests without your username
                    Firestore.firestore().collection("users").document(username).updateData([
                        "sentRequests" : newSentRequests
                        ], completion: { (error) in
                            completion()
                            return
                    })
                }
            })
            
        }
        
    }
    
    func removeFriend(username: String, completion: @escaping () -> Void) {
        
        guard let yourUsername = currentUser?.username else { fatalError("current user did not exist") }
        
        for index in 0...friendUsernames.count - 1 {
            let string = friendUsernames[index]
            if string == username {
                friendUsernames.remove(at: index)
                break
            }
        }
        
        for index in 0...friends.count - 1 {
            let string = friends[index].username
            if string == username {
                friends.remove(at: index)
                break
            }
        }
        
        Firestore.firestore().collection("users").document(yourUsername).updateData([
            "friends" : friendUsernames
        ]) { (error) in
            if error == nil {
                
                Firestore.firestore().collection("users").document(username).getDocument(completion: { (document, error) in
                    if let usersFriends = document?.data()?["friends"] as? [String] {
                        var friendsArray = usersFriends
                        
                        for index in 0...usersFriends.count - 1 {
                            let string = usersFriends[index]
                            if string == yourUsername {
                                friendsArray.remove(at: index)
                                break
                            }
                        }
                        
                        Firestore.firestore().collection("users").document(username).updateData([
                            "friends" : friendsArray
                            ], completion: { (_) in
                                completion()
                                return
                        })
                        
                    } else {
                        completion()
                        return
                    }
                })
                
            } else {
                completion()
                return
            }
        }
    }
    
    
}
