//
//  LYAutoAlbumCell.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2017/6/30.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit

class LYAutoAlbumCell: UITableViewCell {

    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumTitle: UILabel!
    @IBOutlet weak var albumCount: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
