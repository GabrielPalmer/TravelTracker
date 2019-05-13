//
//  SearchViewController.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 3/26/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit

class RequestFriendsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    //set up tab bar delegate and animation
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.navigationItem.title = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        
        loadingIndicator.isHidden = true
        loadingIndicator.color = UIColor.black
    }
    
    @objc func cellCancelButtonTapped(_ sender: UIButton) {
        let username = FirebaseController.shared.sentRequests[sender.tag]
        
        searchBar.isUserInteractionEnabled = false
        tableView.isUserInteractionEnabled = false
        loadingIndicator.isHidden = false
        
        FirebaseController.shared.cancelFriendRequest(username: username) { (success) in
            DispatchQueue.main.async {
                if success {
                    self.tableView.reloadData()
                } else {
                    let alertController = UIAlertController(title: "Failed to remove friend request", message: nil, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alertController, animated: true)
                }
                
                self.searchBar.isUserInteractionEnabled = true
                self.tableView.isUserInteractionEnabled = true
                self.loadingIndicator.isHidden = true
            }
        }
    }
    
    //===========================================
    // MARK: - Table View Data Source
    //===========================================
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 25))
        view.backgroundColor = #colorLiteral(red: 0.6392156863, green: 0.6784313725, blue: 0.7215686275, alpha: 1)
        let friendsRequestLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        friendsRequestLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(friendsRequestLabel)
        friendsRequestLabel.font = UIFont(name: "Futura", size: 17)
        friendsRequestLabel.text = "Sent Requests"
        friendsRequestLabel.textColor = #colorLiteral(red: 0.2509803922, green: 0.3098039216, blue: 0.1411764706, alpha: 1)
        view.addConstraints([NSLayoutConstraint(item: friendsRequestLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: friendsRequestLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
                             NSLayoutConstraint(item: friendsRequestLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 8)])
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FirebaseController.shared.sentRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sentRequestCell", for: indexPath) as! SentRequestTableViewCell
        cell.usernameLabel.text = "\(FirebaseController.shared.sentRequests[indexPath.row]) was sent a friend request"
        cell.cancelButton.addTarget(self, action: #selector(cellCancelButtonTapped(_:)), for: .touchUpInside)
        cell.cancelButton.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    //===========================================
    // MARK: - Search Bar Delegate
    //===========================================
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.isUserInteractionEnabled = false
        tableView.isUserInteractionEnabled = false
        loadingIndicator.isHidden = false
        
        guard let searchTerm = searchBar.text, !searchTerm.isEmpty else { return }
        
        guard !FirebaseController.shared.friendUsernames.contains(searchTerm) else {
            let alertController = UIAlertController(title: "That user is already your friend", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alertController, animated: true)
            return
        }
        
        guard !FirebaseController.shared.sentRequests.contains(searchTerm) else {
            let alertController = UIAlertController(title: "You have already sent a friend request to that user", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alertController, animated: true)
            return
        }
        
        guard !FirebaseController.shared.friendRequests.contains(searchTerm) else {
            let alertController = UIAlertController(title: "You already have a friend request from that user", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alertController, animated: true)
            return
        }
        
        guard searchTerm != FirebaseController.shared.currentUser?.username else {
            let alertController = UIAlertController(title: "This app does not support users with multiple personality disorder", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Go make some friends", style: .default, handler: nil))
            present(alertController, animated: true)
            return
        }
        
        FirebaseController.shared.sendFriendRequest(username: searchTerm) { (success) in
            
            DispatchQueue.main.async {
                if success {
                    self.tableView.reloadData()
                    self.searchBar.text = ""
                } else {
                    let alertController = UIAlertController(title: "Could not find anyone with that username", message: nil, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alertController, animated: true)
                }
                
                self.searchBar.isUserInteractionEnabled = true
                self.tableView.isUserInteractionEnabled = true
                self.loadingIndicator.isHidden = true
            }
        }
        
    }
    
    

}
