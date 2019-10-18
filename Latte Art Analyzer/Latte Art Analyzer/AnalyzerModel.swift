//
//  AnalyzerModel.swift
//  Latte Art Analyzer
//
//  Created by Cole Cofer on 2/1/19.
//  Copyright © 2019 Cole Cofer. All rights reserved.
//

import Foundation

//Enumerations to hold latte art design types
enum ArtDesign {
	case heart
	case tulip
	case rossetta
}

//Model to store data
class AnalyzerModel {
	
	static let model = AnalyzerModel()  //Singelton
	
	//Type of design
	var design:ArtDesign
	
	var fullResImage:UIImage?
	var reducedResImage:UIImage?
	
	//Symmetry Ratings
	var topSymmetry:Double
	var bottomSymmetry:Double
	var overallSymmetry:Double
	
	//Framing Ratings
	var overallFraming:Double

	//Contrast Ratings
	var overallContrast:Double
	
	//Default Constructor
	init() {
		design = .heart
		topSymmetry = 0.0
		bottomSymmetry = 0.0
		overallSymmetry = 0.0
		overallFraming = 0.0
		overallContrast = 0.0
		fullResImage = nil
		reducedResImage = nil
	}
}

