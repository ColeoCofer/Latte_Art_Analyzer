//
//  HomeScreenViewController.swift
//  Latte Art Analyzer
//
//  Created by Cole Cofer on 2/1/19.
//  Copyright © 2019 Cole Cofer. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController {

	@IBOutlet weak var startAnalyzingButton: UIButton!
	
	@IBOutlet weak var openCVVersion: UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		startAnalyzingButton.layer.borderColor = UIColor.white.cgColor
        // Do any additional setup after loading the view.
		openCVVersion.text = OpenCVWrapper.openCVVersionString();
    }
	
	


}
