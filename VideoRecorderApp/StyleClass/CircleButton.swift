//
//  CircleButton.swift
//  VideoRecorderApp
//
//  Created by Aamir Shehzad on 12/10/2022.
//

import UIKit

class CircleButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    /*
     // Method: init(frame: CGRect)
     // Description: Use method to validate email format
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /*
     // Method: init?(coder aDecoder: NSCoder)
     // Description: Use method to validate email format
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    /*
     // Method: setupView()
     // Description: Use method to setupView
     */
    func setupView() -> Void {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.masksToBounds = true
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor
    }

}
