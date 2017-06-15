//
//  SmashTweetersTableViewController.swift
//  Smashtag
//
//  Created by Terrill Thorne on 5/24/17.
//  Copyright © 2017 Terrill Thorne. All rights reserved.
//

import UIKit
import CoreData

// to clear out the database, delete the app on the simulator then run it

class SmashTweetersTableViewController: FetchedResultsTableViewController {

    var mention: String? // the search term that is suppose to show to the tweeters
    { didSet { updateUI() } }
    
    var container: NSPersistentContainer? = // looks into the database and finds tweeters who mentioned a specific word in their tweets
    (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
        { didSet { updateUI() } }
    
    var fetchedResultsController: NSFetchedResultsController<TwitterUser>? // emphasizes that this controller fetches twitterUsers 

    private func updateUI() {
        
        if let context = container?.viewContext, mention != nil {   // deals with the user interface
            let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "handle", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]    // all twitter users that mentioned something that has the search term in it & order them by there "@" sign,  makes the tweeters results show in abc order
            request.predicate = NSPredicate(format: "any tweets.text contains[c] %@" , mention!)  // any twitter users that contain the search term or mention
            fetchedResultsController = NSFetchedResultsController<TwitterUser>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil, // name of the var
                cacheName: nil)
         
            fetchedResultsController?.delegate = self // sets ourself as the NSFetchedResultsController delegate
            try? fetchedResultsController?.performFetch()
            tableView.reloadData() // calls all the UI data source methods
        
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TwitterUser Cell", for: indexPath)
        
        if  let twitterUser = fetchedResultsController?.object(at: indexPath) { 
        cell.textLabel?.text = twitterUser.handle
        let tweetCount = tweetCountWithMentionBy(twitterUser) // tweet count of the twitter user
        cell.detailTextLabel?.text = "\(tweetCount) tweet\((tweetCount == 1) ? "s" : "" )"
            
        }
        return cell
    }
    
    private func tweetCountWithMentionBy(_ twitterUser: TwitterUser) -> Int {
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        request.predicate = NSPredicate(format: "text contains[c] %@ and tweeter = %@", mention!, twitterUser) // notifies to tell the twitterUser name & who mentioned the tweet
        return (try? twitterUser.managedObjectContext!.count(for: request)) ?? 0 // if the request fails then we say there are 0 tweets 
    }
}
