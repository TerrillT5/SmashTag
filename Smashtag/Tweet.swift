//
//  Tweet.swift
//  Smashtag
//
//  Created by Terrill Thorne on 5/23/17.
//  Copyright © 2017 Terrill Thorne. All rights reserved.
//

import UIKit
import CoreData
//import Twitter

class Tweet: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tweet> {
        return NSFetchRequest<Tweet>(entityName: "Tweet")
    }
    
    class func findOrCreateTweet(matching twitterInfo: Twitter.Tweet, in context: NSManagedObjectContext) throws -> Tweet
    {
        
        // go find this tweet 
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest() // go find the tweet
        request.predicate = NSPredicate(format: "unique = %@ ", twitterInfo.identifier) // looking for an unique key for what the person passed in. "This refers to "ating" someone on twitter
        
        do {
            let matches = try context.fetch(request) // this throws. Matches in an array of tweet
            if matches.count > 0 { // if match is greater than 0, than you've found your tweet
            assert(matches.count == 1, "Tweet.findOrCreateTweet --  database inconsistency") // if matches.count is greater than 1, this makes sure 2 tweets aren't in the unique identifier
            return matches[0]
            
            }
        } catch { // catch is here if a request to the database fails
            
            throw error // this rethrows the findOrCreateTweet
        }
        
        let tweet = Tweet(context: context) // this creates a tweet in the database
        tweet.unique = twitterInfo.identifier // identifies the persons username
        tweet.text = twitterInfo.text // the text of the tweet
        tweet.created = twitterInfo.created as NSDate // the date the tweet was created
        tweet.tweeter =  try? TwitterUser.findOrCreateTweet(matching: twitterInfo.user, in: context)    // identifies the persons username that tweets 

        return tweet
        
    }
}
