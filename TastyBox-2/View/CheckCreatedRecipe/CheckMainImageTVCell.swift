//
//  CheckMainImageTVCell.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-24.
//

import UIKit
import AVFoundation

class CheckMainImageTVCell: UITableViewCell {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playVideoView: PlayVideoInsideTVCellView!
    
    
    var imgData: Data! 
    var videoURL: URL!
    
    var tap: UITapGestureRecognizer!

    var playerItem: AVPlayerItem!
    var playerLooper: AVPlayerLooper!
    var player: AVQueuePlayer!
    var layerPlayer: AVPlayerLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpImageView(data: Data) {
        
        let imgView = UIImageView()
       
        self.playVideoView.addSubview(imgView)
        
        imgView.topAnchor.constraint(equalTo: self.playVideoView.topAnchor).isActive = true
        imgView.bottomAnchor.constraint(equalTo: self.playVideoView.bottomAnchor).isActive = true
        imgView.leadingAnchor.constraint(equalTo: self.playVideoView.leadingAnchor).isActive = true
        imgView.trailingAnchor.constraint(equalTo: self.playVideoView.trailingAnchor).isActive = true
        imgView.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        imgView.heightAnchor.constraint(equalToConstant: 80.0).isActive = true

//        if let image = UIImage(data: imgData), let temp = UIImage(systemName: "suit.heart.fill") {
//
//            imgView.image = image
//
//        }
       
        guard let temp = UIImage(systemName: "suit.heart.fill") else { return }
        guard let imgView = self.playVideoView.subviews.first as? UIImageView else { return }
        imgView.image = temp
      
    }

}
