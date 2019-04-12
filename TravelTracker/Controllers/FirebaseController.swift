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
    
    static func createUser(name: String, username: String, password: String, completion: @escaping (User?) -> Void) {
        Firestore.firestore().collection("users").whereField("username", isEqualTo: username).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                completion(nil)
                return
            }
            
            guard snapshot.documents.count < 1 else {
                completion(nil)
                return
            }
            
            Firestore.firestore().collection("users").addDocument(data: [
                "name" : name,
                "username" : username,
                "password" : password
                ])
            
            let user = User(name: name, username: username, password: password)
            
            completion(user)
            
            saveUserAsCurrent(user: user)
            
            return
            
        }
        
    }
    
    static func signIn(username: String, password: String, completion: @escaping (User?) -> Void) {
        
        Firestore.firestore().collection("users").whereField("username", isEqualTo: username).whereField("password", isEqualTo: password).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                completion(nil)
                return
            }
            
            if snapshot.documents.count > 0, let name = snapshot.documents.first?.data()["name"] as? String {
                let user = User(name: name, username: username, password: password)
                
                completion(user)
                
                saveUserAsCurrent(user: user)
            } else {
                completion(nil)
                return
            }
            
            
        }
        
    }
    
    static func saveUserAsCurrent(user: User) {
        FirebaseController.currentUser = user
    }
    
//    static func signInCurrentUser() -> User {
//        
//    }
    
}
