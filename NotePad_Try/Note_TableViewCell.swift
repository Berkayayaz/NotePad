//
//  Note_TableViewCell.swift
//  NotePad_Try
//
//  Created by Berkay AYAZ on 2016-07-27.
//  Copyright © 2016 Berkay AYAZ. All rights reserved.
//

import UIKit

class Note_TableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

