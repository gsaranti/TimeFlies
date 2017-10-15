//
//  VideoWatchViewController.swift
//  Time Flies Beta
//
//  Created by George Sarantinos on 8/12/17.
//  Copyright © 2017 George Sarantinos. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoWatchViewController: UIViewController {
    
    var urlName:URL?
    let seekSlider = UISlider()
    var playerRateBeforeSeek: Float = 0
    let player = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let movieURL = urlName
        let movie: AVPlayerViewController = AVPlayerViewController()
        movie.view.frame = self.view.bounds
        
        let player: AVPlayer = AVPlayer(url: movieURL!)
        movie.player = player
        movie.showsPlaybackControls = false
        
        self.addChildViewController(movie)
        
        self.view.addSubview(movie.view)
        
        movie.didMove(toParentViewController: self)
        player.play()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
