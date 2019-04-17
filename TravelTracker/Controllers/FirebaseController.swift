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
                "friends" : []
                ])
            
            let user = User(name: name, username: username, password: password)
            currentUser = user
            saveCurrentUser(user: user)
            completion(true)
            
        }
        
    }
    
    static func signIn(username: String, password: String, completion: @escaping (Bool) -> Void) {
        
        Firestore.firestore().collection("users").whereField("username", isEqualTo: username).whereField("password", isEqualTo: password).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                completion(false)
                return
            }
            
            guard snapshot.documents.count > 0,
                let data = snapshot.documents.first?.data(),
                let name = data["name"] as? String,
                let usernames = data["friends"] as? [String] else {
                    
                    completion(false)
                    return
            }
            
            let user = User(name: name, username: username, password: password)
            currentUser = user
            saveCurrentUser(user: user)
            fetchFriendsInfo(usernames: usernames, completion: {
                
            })
            
            completion(true)
            return
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
        
        Firestore.firestore().collection("users").whereField("username", isEqualTo: username).whereField("password", isEqualTo: password).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                completion(false)
                return
            }
            
            guard snapshot.documents.count > 0,
                let data = snapshot.documents.first?.data(),
                let name = data["name"] as? String,
                let usernames = data["friends"] as? [String] else {
                    
                    completion(false)
                    return
            }
            
            currentUser = User(name: name, username: username, password: password)
//            fetchFriendsInfo(usernames: usernames, completion: {
//                <#code#>
//            })
            
            completion(true)
            return
            
        }
        
    }
    
    static func fetchFriendsInfo(usernames: [String], completion: @escaping () -> Void) {
        
        if usernames.count == 0 {
            return
        }
        
        func fetchUserForUsername(_ username: String, completion: @escaping (User?) -> Void) {
            Firestore.firestore().collection("users").whereField("username", isEqualTo: username).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot, snapshot.documents.count > 0 else {
                    completion(nil)
                    return
                }
                
                Firestore.firestore().collection("users").document("").collection("markers")
            }
        }
        
        let group = DispatchGroup()
        
        
        for username in usernames {
            
            fetchUserForUsername(username) { (user) in
              
            }
            
            
        }
        
        group.wait()
        
        
        
    }
    
}
