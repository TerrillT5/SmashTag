//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Terrill Thorne on 5/22/17.
//  Copyright © 2017 Terrill Thorne. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetProfileImageview: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    var tweet: Twitter.Tweet? // get the twitter tweet that you want then load them up
    {
        didSet { updateUI() }
    }
    
    private func updateUI() {
        tweetTextLabel.text = tweet?.text
        tweetUserLabel.text = tweet?.user.description
        
        if let profileImageURL = tweet?.user.profileImageURL {
            // blocks the main thread
            if let imageData = try? Data(contentsOf: profileImageURL) { // blocks the main thread
                tweetProfileImageview.image = UIImage(data: imageData)
            }
            
        } else {
            tweetProfileImageview.image = nil
        }
        
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 { // represents the hours & mins
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel.text = formatter.string(from: created)
        } else {
            
            tweetCreatedLabel.text = nil
        }
    }
    
}


