//
//  ChannelsCell.swift
//  ExploreMine
//
//  Created by Silstone on 02/12/19.
//  Copyright © 2019 SilstoneGroup. All rights reserved.
//

import UIKit

class ChannelsCell: UITableViewCell {
    
    @IBOutlet weak var circelView: UIView!
    @IBOutlet weak var viewLineUp: UIView!
    @IBOutlet weak var viewLinedown: UIView!
    @IBOutlet weak var lblNameTopConstant: NSLayoutConstraint!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNoExpirence: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var imgViewChannel: UIImageView!
    @IBOutlet weak var lblAdd: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        circelView.setBorder(radius: 8, color: UIColor.gray)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
