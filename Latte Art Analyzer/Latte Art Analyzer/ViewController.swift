//
//  ViewController.swift
//  Latte Art Analyzer
//
//  Created by Cole Cofer on 2/1/19.
//  Copyright © 2019 Cole Cofer. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {

	@IBOutlet weak var startAnalyzingButton: UIButton!
	

	override func viewDidLoad() {
		super.viewDidLoad()
		startAnalyzingButton.layer.borderColor = UIColor.white.cgColor
		// Do any additional setup after loading the view, typically from a nib.
	}


}

