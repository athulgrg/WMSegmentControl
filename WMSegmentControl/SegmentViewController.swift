//
//  ViewController.swift
//  WMSegmentControl
//
//  Created by Wasim Malek on 27/05/19.
//  Copyright © 2019 Wasim Malek. All rights reserved.
//

import UIKit

class SegmentViewController: UITableViewController {
    @IBOutlet weak var sgTextOnlyBar: WMSegment!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Custom Segment"

        let att1 = "Athul1 (03)"
        let att2 = "Athul2 (15)"
        let att3 = "Athul3 (20)"

        sgTextOnlyBar.buttonTitles = [att1, att2, att3]

        sgTextOnlyBar.SelectedFont = UIFont(name: "ChalkboardSE-Bold", size: 17)!
        sgTextOnlyBar.normalFont = UIFont(name: "ChalkboardSE-Regular", size: 15)!

        sgTextOnlyBar.bottomBarHeight = 2
        sgTextOnlyBar.bottomBarPadding = 15
        sgTextOnlyBar.onValueChanged = { index in
            print(index)
        }
    }
    
    @IBAction func segmentValueChange(_ sender: WMSegment) {
        /*print("selected index = \(sender.selectedSegmentIndex)")
        switch sender.selectedSegmentIndex {
        case 0:
            print("first item")
        case 1:
            print("second item")
        case 2:
            print("Third item")
        default:
            print("default item")
        }*/
    }
}
