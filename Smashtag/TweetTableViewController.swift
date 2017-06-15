//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Terrill Thorne on 5/18/17.
//  Copyright © 2017 Terrill Thorne. All rights reserved.
//
import UIKit
import Twitter


class TweetTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!{
        
        didSet {
            
            searchTextField.delegate = self 
        }
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        searchForTweets() // updates the timeline with most recent tweets
    }
    
    var tweets = [Array<Twitter.Tweet>]()  // places tweets in table then fetches more

    var searchText: String? { // once a user sets the searchText, the tweets will show
        didSet {
            
            searchTextField?.text = searchText
            searchTextField?.resignFirstResponder()  // keyboard disappears when a search is sent
            lastTwitterRequest = nil // if something changes, this invalidates the last twitter request 
            tweets.removeAll()  // removes the tweets that are already in the table
            tableView.reloadData() // reloads new data from tweets that have been removed
            searchForTweets()
            title = searchText // sets the title in a navigation controller to what is being searched
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            searchText = searchTextField.text
        }
        return true
    }

    func insertTweets(_ newTweets:[Twitter.Tweet]) {
        self.tweets.insert(newTweets, at: 0)
        self.tableView.insertSections([0], with: .fade)
        
    }

    private func twitterRequest() -> Twitter.Request? { // this function makes a searchText that will search for tweets
        if lastTwitterRequest == nil {
            if let query = searchText, !query.isEmpty {     // disregards a search for empty text
                return Twitter.Request(search: query + "-filter:retweets", count: 100) // grab 100 tweets at a time
            }
        }
        //    return lastTwitterRequest?.requestForNewer
        return nil // if the searchText is empty
    }
    
    private var lastTwitterRequest: Twitter.Request?

    private func searchForTweets() { // searches for the tweets
        if let request = lastTwitterRequest?.requestForNewer ?? twitterRequest() { // uses the last twitter request that has a newer version, if it doesn't then default back to twitter reviews
            lastTwitterRequest = request
            request.fetchTweets { [weak self] newTweets in
                DispatchQueue.main.async { // this makes the data load on the tableView once it has been updated
                    if request == self?.lastTwitterRequest {
                        
                        self?.insertTweets(newTweets)
                       // self?.tweets.insert(newTweets, at: 0) // makes new tweets come in at the top
                    // self?.tableView.insertSections([0], with: .fade) // line informs tableView that model changed so redo it again
                    }
                    self?.refreshControl?.endRefreshing()   //turns refresh control off
                }
            }
            
        } else {
            
            self.refreshControl?.endRefreshing()    // turned refreshing off if a request wasn't found
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight // gets the row height from the storyboard
        tableView.rowHeight = UITableViewAutomaticDimension // sets the width of the table to the length of the tweet
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count // returns the number of arrays that are in the model
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count // the number of rows there are in the tweets of sections
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet", for: indexPath)
        
        // Configure the cell...
        
        let tweet: Twitter.Tweet = tweets[indexPath.section][indexPath.row] // we now have the individuals tweet
        //       cell.textLabel?.text = tweet.text
        //       cell.detailTextLabel?.text = tweet.user.name
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
    // makes it more clear when each pull from twitter 
    // occurs in the table by setting section header titles 
        
        return "\(tweets.count-section)" // represents the count of the amount of pulls that you've made
    
        }
    
    }
    
    

