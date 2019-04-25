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
    
    enum UpdateType {
        case add
        case update
        case delete
    }
    
    //for the sign up view controller
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
                "friends" : [String]()
                ], completion: { (error) in
                    let user = User(name: name, username: username, password: password)
                    currentUser = user
                    saveCurrentUser(user: user)
                    completion(true)
            })
            
        }
        
    }
    
    //for the sign in view controller
    static func signIn(username: String, password: String, completion: @escaping (Bool) -> Void) {
        
        Firestore.firestore().collection("users").document(username).getDocument { (document, error) in
            if let document = document,
                let data = document.data(),
                password == data["password"] as? String,
                let name = data["name"] as? String,
                let usernames = data["friends"] as? [String] {
                
                let user = User(name: name, username: username, password: password)
                currentUser = user
                saveCurrentUser(user: user)
                fetchFriendsInfo(usernames: usernames, completion: {
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
    
    // auto sign in function
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
                let usernames = data["friends"] as? [String] {
                
                currentUser = User(name: name, username: username, password: password)
                fetchFriendsInfo(usernames: usernames, completion: {
                    completion(true)
                    return
                })
                
            } else {
                completion(false)
                return
            }
        }
        
    }
    
    static func fetchFriendsInfo(usernames: [String], completion: @escaping () -> Void) {
        
        if usernames.count == 0 {
            completion()
            return
        }
        
        DispatchQueue.global().async {
            let group = DispatchGroup()
            
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
        
        guard let name = FirebaseController.currentUser?.name else { return }
        
        DispatchQueue.global().async {
            switch type {
            case .add:
                Firestore.firestore().collection("users").document(name).collection("markers").document(marker.info.id).setData([
                    "comment" : marker.info.comment as Any,
                    "date" : Timestamp(date: marker.info.date),
                    "xCoord" : marker.info.xCoord,
                    "yCoord" : marker.info.yCoord
                    ])
            case .update:
                Firestore.firestore().collection("users").document(name).collection("markers").document(marker.info.id).updateData([
                    "comment" : marker.info.comment as Any
                    ])
            case .delete:
                Firestore.firestore().collection("users").document(marker.info.id).delete()
            }
        }
    }
    
}
