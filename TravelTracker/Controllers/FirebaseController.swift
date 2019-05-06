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
    
    static var currentUser: User?
    static var friends: [User] = []
    static var friendUsernames: [String] = []
    static var friendRequests: [String] = []
    static var sentRequests: [String] = []
    
    enum UpdateType {
        case add
        case update
        case delete
    }
    
    static func createUser(name: String, username: String, password: String, completion: @escaping (Bool) -> Void) {
        
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
                    currentUser = user
                    saveCurrentUser(user: user)
                    completion(true)
            })
            
        }
        
    }
    
    static func signIn(username: String, password: String, completion: @escaping (Bool) -> Void) {
        
        Firestore.firestore().collection("users").document(username).getDocument { (document, error) in
            if let document = document,
                let data = document.data(),
                password == data["password"] as? String,
                let name = data["name"] as? String,
                let usernames = data["friends"] as? [String],
                let yourRequests = data["friendRequests"] as? [String],
                let yourSentRequests = data["sentRequests"] as? [String] {
                
                let user = User(name: name, username: username, password: password)
                currentUser = user
                saveCurrentUser(user: user)
                
                friendUsernames = usernames
                friendRequests = yourRequests
                sentRequests = yourSentRequests
                
                fetchMarkerInfo(usernames: usernames, completion: {
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
    static func saveCurrentUser(user: User) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(user.username, forKey: "username")
        userDefaults.set(user.password, forKey: "password")
    }
    
    static func signInSavedUser(completion: @escaping (Bool) -> Void) {
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
                
                currentUser = User(name: name, username: username, password: password)
                friendUsernames = usernames
                friendRequests = yourRequests
                sentRequests = yourSentRequests
                
                fetchMarkerInfo(usernames: usernames, completion: {
                    completion(true)
                    return
                })
                
            } else {
                completion(false)
                return
            }
        }
        
    }
    
    static func signOutSavedUser() {
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(nil, forKey: "username")
        userDefaults.set(nil, forKey: "password")
    }
    
    static func fetchMarkerInfo(usernames: [String], completion: @escaping () -> Void) {
        
        if usernames.count == 0 {
            completion()
            return
        }
        
        DispatchQueue.global().async {
            let group = DispatchGroup()
            
            group.enter()
            
            if let yourUsername = FirebaseController.currentUser?.username {
                Firestore.firestore().collection("users").document(yourUsername).collection("markers").getDocuments(completion: { (snapshot, error) in
                    if let documents = snapshot?.documents {
                        for document in documents {
                            if let markerInfo = MarkerInfo(id: document.documentID, firebaseDict: document.data()) {
                                FirebaseController.currentUser?.markers.append(markerInfo)
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
                        FirebaseController.friends.append(user)
                        group.leave()
                    } else {
                        group.leave()
                    }
                })
            }
            
            group.wait()
            
            for friend in FirebaseController.friends {
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
    
    static func updateMapMarkers(_ marker: MapMarker, type: UpdateType) {
        
        guard let username = FirebaseController.currentUser?.username else { return }
        
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
    
    static func sendFriendRequest(username: String, completion: @escaping (Bool) -> Void) {
        
        //gets the friend requests of the user you requested
        Firestore.firestore().collection("users").document(username).getDocument { (document, error) in
            guard let usersFriendRequests = document?.data()?["friendRequests"] as? [String],
                let yourUsername = currentUser?.username else {
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
                        sentRequests.insert(username, at: 0)
                        
                        //updates your sent requests with that user
                        Firestore.firestore().collection("users").document(yourUsername).updateData([
                            "sentRequests" : sentRequests
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
    
    static func cancelFriendRequest(username: String, completion: @escaping (Bool) -> Void) {
        
        //gets the friend requests of the user you requested
        Firestore.firestore().collection("users").document(username).getDocument { (document, error) in
            guard let usersFriendRequests = document?.data()?["friendRequests"] as? [String],
                let yourUsername = currentUser?.username else {
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
                        for index in 0...sentRequests.count - 1 {
                            let string = sentRequests[index]
                            if string == username {
                                sentRequests.remove(at: index)
                                break
                            }
                        }
                        
                        //updates your sent requests on firebase
                        Firestore.firestore().collection("users").document(yourUsername).updateData([
                            "sentRequests" : sentRequests
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
    
    
    
}
