//
//  TweetTableViewController.swift
//  Tags
//
//  Created by Nick on 2015-12-09.
//  Copyright © 2015 Nicholas Ivanecky. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    var tweets = [[Tweet]]()
    var searchText: String? = "realDonaldTrump" { //jason
        didSet {
            self.lastSuccessfulRequest = nil
            self.searchTextField?.text = searchText
            tweets.removeAll()
            tableView.reloadData()
            refresh()
        }
    }
    var lastSuccessfulRequest: TwitterRequest?
    var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                return TwitterRequest(search: self.searchText!, count: 200)
            } else {
                return nil
            }
        } else {
            return lastSuccessfulRequest?.requestForNewer
        }
    }
    
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        if let _ = searchText {
            if let request = nextRequestToAttempt {
                
                //off the main queue
                request.fetchTweets({ (newTweets) -> Void in
                    
                    //successfully fetched some new tweets
                    //go back to the main queue
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        //do UI Stuff here
                        
                        if newTweets.count > 0 {
                            self.lastSuccessfulRequest = request
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView.reloadData()
                            sender?.endRefreshing()
                        }
                        
                    })
                    
                })
            }
        } else {
            sender?.endRefreshing()
        }
    }
    
    func refresh() {
        
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl)
    }

    //MARK: View Controller LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //change status bar
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black 
        
        refresh()
    }
    
    //MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  tweets[section].count
    }
    
    private struct Storyboard {
        static let TweetWithImage = "TweetCellWithImage"
        static let TweetWithoutImage = "TweetCellWithoutImage"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
        let tweet = tweets[indexPath.section][indexPath.row]
        
        if tweet.media.first?.url != nil {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetWithImage, forIndexPath: indexPath) as! TweetTableViewCell
            cell.tweet = tweet
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetWithoutImage, forIndexPath: indexPath) as! TweetTableViewCell
            cell.tweet = tweet
            return cell
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchTextField.text = textField.text
            
        }
        return true
    }

    
    
    
    
    
    
}

